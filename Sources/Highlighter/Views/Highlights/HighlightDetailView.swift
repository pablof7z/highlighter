import SwiftUI
import NDKSwift

struct HighlightDetailView: View {
    let highlight: HighlightEvent
    
    var body: some View {
        ImmersiveHighlightDetailView(highlight: highlight)
    }
}

struct RelatedHighlightPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 60)
                .shimmer()
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)
                .shimmer()
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

struct CompactRelatedHighlightCard: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @State private var author: NDKUserProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Highlight content
            Text("\"\(String(highlight.content.prefix(100)))...\"")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Author info
            HStack(spacing: 8) {
                // Author avatar
                Group {
                    if let profileImage = author?.picture,
                       let url = URL(string: profileImage) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
                                )
                        }
                    } else {
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
                            )
                    }
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(author?.name ?? author?.displayName ?? "Anonymous")
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(1)
                    
                    Text(RelativeTimeFormatter.shortRelativeTime(from: highlight.createdAt))
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(height: 140)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(DesignSystem.Colors.border, lineWidth: 0.5)
        )
        .shadow(color: DesignSystem.Shadow.subtle.color, radius: DesignSystem.Shadow.subtle.radius)
        .task {
            await loadAuthorProfile()
        }
    }
    
    private func loadAuthorProfile() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: highlight.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
}

struct ReplyComposerView: View {
    let highlight: HighlightEvent
    @Binding var replyText: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var isPublishing = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Quote preview
                Text("\"\(String(highlight.content.prefix(100)))...\"")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.small)
                    .padding(.horizontal)
                
                // Reply input
                TextEditor(text: $replyText)
                    .font(DesignSystem.Typography.body)
                    .padding(8)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.small)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        sendReply()
                    }
                    .disabled(replyText.isEmpty || isPublishing)
                }
            }
        }
    }
    
    private func sendReply() {
        isPublishing = true
        HapticManager.shared.impact(.light)
        // Note: Reply functionality would create a new event referencing this highlight
        // This demo focuses on core highlight features
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HighlightDetailView(
        highlight: HighlightEvent(
            id: "1",
            event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 9802, tags: [], content: "", sig: ""),
            content: PreviewData.highlightTexts[2],
            author: "npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m",
            createdAt: Date(),
            context: PreviewData.highlightContexts[2],
            url: PreviewData.articleURLs[2],
            referencedEvent: nil,
            attributedAuthors: [],
            comment: "The future of value exchange is fascinating"
        )
    )
    .environmentObject(AppState())
}
