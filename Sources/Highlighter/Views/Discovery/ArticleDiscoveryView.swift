import SwiftUI
import NDKSwift

struct ArticleDiscoveryView: View {
    let searchText: String
    @EnvironmentObject var appState: AppState
    @State private var articles: [Article] = []
    @State private var articleEngagements: [String: EngagementService.EngagementMetrics] = [:]
    
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return articles
        }
        return articles.filter { article in
            article.title.localizedCaseInsensitiveContains(searchText) ||
            article.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Featured Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Featured Articles")
                    
                    LazyVStack(spacing: 16) {
                        ForEach(filteredArticles.prefix(10)) { article in
                            ArticleCardView(
                                article: article,
                                engagement: articleEngagements[article.id] ?? EngagementService.EngagementMetrics()
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 24)
        }
        .task {
            await loadArticles()
        }
        .onChange(of: articles) { _ in
            Task {
                await fetchArticleEngagements()
            }
        }
    }
    
    private func loadArticles() async {
        guard let ndk = appState.ndk else { return }
        
        let articleSource = await ndk.outbox.observe(
            filter: NDKFilter(kinds: [30023], limit: 50),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in articleSource.events {
            do {
                let article = try Article(from: event)
                print("DEBUG: Article loaded - Title: \(article.title), Content length: \(article.content.count)")
                await MainActor.run {
                    if !articles.contains(where: { $0.id == article.id }) {
                        articles.append(article)
                        articles.sort { $0.createdAt > $1.createdAt }
                    }
                }
            } catch {
                print("DEBUG: Failed to create article from event: \(error)")
            }
        }
    }
    
    private func fetchArticleEngagements() async {
        let eventIds = articles.map { $0.id }
        guard !eventIds.isEmpty else { return }
        
        let engagements = await appState.engagementService.fetchEngagementBatch(for: eventIds)
        await MainActor.run {
            articleEngagements = engagements
        }
    }
}

// MARK: - Article Card View

struct ArticleCardView: View {
    let article: Article
    let engagement: EngagementService.EngagementMetrics
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationLink(destination: ArticleView(article: article)) {
            VStack(alignment: .leading, spacing: 12) {
            // Header image
            if let imageURL = article.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                }
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                
                if let summary = article.summary {
                    Text(summary)
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(3)
                }
                
                HStack {
                    // Author info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.ds.primaryDark.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if let picture = author?.picture, let url = URL(string: picture) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.ds.primaryDark)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.ds.primaryDark)
                                }
                            }
                        
                        VStack(alignment: .leading) {
                            Text(author?.displayName ?? formatPubkey(article.author))
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.text)
                            Text(timeAgo(from: article.createdAt))
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Engagement metrics
                    HStack(spacing: 12) {
                        if engagement.likes > 0 {
                            Label("\(engagement.likes)", systemImage: "heart")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                        }
                        if engagement.comments > 0 {
                            Label("\(engagement.comments)", systemImage: "bubble.right")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                        }
                        
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
            }
            .padding()
        }
        }
        .buttonStyle(PlainButtonStyle()) // Prevent default button styling
        .modernCard()
        .contentShape(Rectangle()) // Make entire card tappable
        .task {
            await loadAuthor()
        }
    }
    
    private func formatPubkey(_ pubkey: String) -> String {
        String(pubkey.prefix(8)) + "..."
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        let profileDataSource = await ndk.outbox.observe(
            filter: NDKFilter(
                authors: [article.author],
                kinds: [0]
            ),
            maxAge: 3600,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileDataSource.events {
            if let fetchedProfile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                await MainActor.run {
                    self.author = fetchedProfile
                }
                break
            }
        }
    }
}