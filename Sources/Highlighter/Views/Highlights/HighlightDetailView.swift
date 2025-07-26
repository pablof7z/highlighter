import SwiftUI
import NDKSwift

struct HighlightDetailView: View {
    let highlight: HighlightEvent
    
    var body: some View {
        ImmersiveHighlightDetailView(highlight: highlight)
    }
}

struct HighlightDetailView_Legacy: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var isZapped = false
    @State private var showShareSheet = false
    @State private var showComments = false
    @State private var author: NDKUserProfile?
    @State private var showAudioPlayer = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Highlight content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\"\(highlight.content)\"")
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.text)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.1),
                                        DesignSystem.Colors.secondary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                        
                        // Context if available
                        if let context = highlight.context {
                            Text(context)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .padding(.horizontal)
                        }
                        
                        // Author's comment if available
                        if let comment = highlight.comment {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Author's Note", systemImage: "bubble.left.fill")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                
                                Text(comment)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.text)
                            }
                            .padding()
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Author info
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(author?.name ?? author?.displayName ?? "Anonymous")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.medium)
                            
                            Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Follow button
                        Button(action: followAuthor) {
                            Text("Follow")
                                .font(DesignSystem.Typography.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Source link
                    if let url = highlight.url {
                        Link(destination: URL(string: url)!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("View Source")
                                        .font(DesignSystem.Typography.body)
                                        .fontWeight(.medium)
                                    
                                    Text(url)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            .padding()
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Audio Player Section
                    if showAudioPlayer {
                        AudioPlayerView(highlight: highlight)
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .push(from: .bottom).combined(with: .opacity),
                                removal: .push(from: .top).combined(with: .opacity)
                            ))
                    }
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: toggleZap) {
                            VStack(spacing: 4) {
                                Image(systemName: isZapped ? "bolt.fill" : "bolt")
                                    .font(.title2)
                                    .foregroundColor(isZapped ? DesignSystem.Colors.secondary : DesignSystem.Colors.textSecondary)
                                
                                Text("Zap")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(isZapped ? DesignSystem.Colors.secondary : DesignSystem.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { 
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showAudioPlayer.toggle()
                            }
                            HapticManager.shared.impact(.light)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: showAudioPlayer ? "speaker.wave.3.fill" : "speaker.wave.2")
                                    .font(.title2)
                                    .foregroundColor(showAudioPlayer ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                                    .symbolEffect(.variableColor.iterative, value: showAudioPlayer)
                                
                                Text("Listen")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(showAudioPlayer ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(showAudioPlayer ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showAudioPlayer ? DesignSystem.Colors.primary : Color.clear, lineWidth: 1)
                            )
                        }
                        
                        Button(action: { 
                            // Scroll to comments section
                            HapticManager.shared.impact(.light)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text("Comments")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showShareSheet = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text("Share")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Comments section
                    CommentsSection(highlightId: highlight.id)
                        .padding(.top)
                    
                    // Related highlights section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Related Highlights")
                            .font(DesignSystem.Typography.headline)
                            .padding(.horizontal)
                        
                        // Placeholder for related highlights
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3) { _ in
                                    RelatedHighlightPlaceholder()
                                        .frame(width: 250)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Highlight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .task {
            await loadAuthorProfile()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [highlight.content])
        }
    }
    
    private func loadAuthorProfile() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: highlight.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break // Only need current value
        }
    }
    
    private func toggleZap() {
        isZapped.toggle()
        HapticManager.shared.impact(.light)
        // Note: Actual zapping requires wallet integration (NIP-57/NIP-60)
        // This demo app only simulates the UI interaction
    }
    
    private func followAuthor() {
        HapticManager.shared.impact(.light)
        // Note: Follow functionality requires contact list management (NIP-02)
        // This demo focuses on highlight display features
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
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Reply input
                TextEditor(text: $replyText)
                    .font(DesignSystem.Typography.body)
                    .padding(8)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(8)
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
            content: "The best way to predict the future is to invent it.",
            author: "test",
            createdAt: Date(),
            context: nil,
            url: "https://example.com",
            referencedEvent: nil,
            attributedAuthors: [],
            comment: "This is a profound insight about innovation."
        )
    )
    .environmentObject(AppState())
}
