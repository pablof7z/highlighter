import SwiftUI
import NDKSwift

struct HighlightDiscoveryView: View {
    let searchText: String
    @EnvironmentObject var appState: AppState
    @State private var highlights: [HighlightEvent] = []
    
    var filteredHighlights: [HighlightEvent] {
        if searchText.isEmpty {
            return highlights
        }
        return highlights.filter { highlight in
            highlight.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredHighlights) { highlight in
                    DiscoveryHighlightCard(highlight: highlight)
                }
            }
            .padding()
        }
        .task {
            await loadHighlights()
        }
    }
    
    private func loadHighlights() async {
        let ndk = appState.ndk
        
        let highlightSource = ndk.subscribe(
            filter: NDKFilter(kinds: [9802]),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in highlightSource.events {
            if let highlight = try? HighlightEvent(from: event) {
                await MainActor.run {
                    if !highlights.contains(where: { $0.id == highlight.id }) {
                        highlights.append(highlight)
                        highlights.sort { $0.createdAt > $1.createdAt }
                    }
                }
            }
        }
    }
}

// MARK: - Discovery Highlight Card

struct DiscoveryHighlightCard: View {
    let highlight: HighlightEvent
    @State private var author: NDKUserMetadata?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Highlight content with quote styling
            Text(highlight.content)
                .font(DesignSystem.Typography.highlighterQuote)
                .foregroundColor(.ds.text)
                .lineLimit(6)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.ds.secondary)
                        .frame(width: 3)
                        .offset(x: -12)
                }
            
            // Context if available
            if let context = highlight.context {
                Text("from: \(context)")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            // Author and interaction row
            HStack {
                // Author info
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.ds.primaryDark.opacity(0.2))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if let picture = author?.picture, let url = URL(string: picture) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .font(.ds.callout)
                                        .foregroundColor(.ds.primaryDark)
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.ds.callout)
                                    .foregroundColor(.ds.primaryDark)
                            }
                        }
                    
                    Text(author?.displayName ?? String(highlight.author.prefix(16)))
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.text)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Zap button
                    Button {
                        HapticManager.shared.impact(HapticManager.ImpactStyle.light)
                    } label: {
                        Label("21", systemImage: "bolt.fill")
                            .font(.ds.caption)
                            .foregroundColor(.ds.secondary)
                    }
                    
                    // Share button
                    Button {
                        HapticManager.shared.triggerSelection()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
            }
        }
        .padding()
        .modernCard()
        .task {
            await loadAuthor()
        }
    }
    
    private func loadAuthor() async {
        let ndk = appState.ndk
        
        let profileDataSource = ndk.subscribe(
            filter: NDKFilter(
                authors: [highlight.author],
                kinds: [0]
            ),
            maxAge: 3600,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileDataSource.events {
            if event.kind == 0 {
                await MainActor.run {
                    self.author = NDKUserMetadata(event: event)
                }
                break
            }
        }
    }
}