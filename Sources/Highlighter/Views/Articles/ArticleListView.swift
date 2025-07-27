import SwiftUI
import NDKSwift

struct ArticleListView: View {
    @EnvironmentObject var appState: AppState
    @State private var articles: [Article] = []
    @State private var featuredArticles: [Article] = []
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    if articles.isEmpty {
                        emptyState
                    } else {
                        // Featured Articles Section
                        if !featuredArticles.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                                Text("Featured")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DesignSystem.Spacing.medium) {
                                        ForEach(featuredArticles.prefix(3)) { article in
                                            ArticleFeaturedCard(article: article)
                                                .onTapGesture {
                                                    selectedArticle = article
                                                    HapticManager.shared.impact(.light)
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Regular Articles Section
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                            if !featuredArticles.isEmpty {
                                Text("Recent Articles3")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                    .padding(.horizontal)
                            }
                            
                            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(articles.filter { article in
                                    !featuredArticles.contains(where: { $0.id == article.id })
                                }) { article in
                                    ArticleRowCard(article: article)
                                        .onTapGesture {
                                            selectedArticle = article
                                            HapticManager.shared.impact(.light)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Articles")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadArticles()
            }
            .sheet(item: $selectedArticle) { article in
                ArticleView(article: article)
            }
        }
        .task {
            await loadArticles()
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("No articles yet")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Long-form articles will appear here")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private func loadArticles() async {
        guard let ndk = appState.ndk else { return }
        
        let articleSource = await ndk.outbox.observe(
            filter: NDKFilter(kinds: [30023], limit: 50),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in articleSource.events {
            if let article = try? Article(from: event) {
                await MainActor.run {
                    if !articles.contains(where: { $0.id == article.id }) {
                        articles.append(article)
                        articles.sort { $0.createdAt > $1.createdAt }
                        
                        // Select featured articles (first 3 with images)
                        featuredArticles = articles
                            .filter { $0.image != nil }
                            .prefix(3)
                            .map { $0 }
                    }
                }
            }
        }
    }
}

// MARK: - Article Card

struct ArticleListCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            // Image
            if let imageURL = article.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 180)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                // Title
                Text(article.title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                
                // Summary
                if let summary = article.summary {
                    Text(summary)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                // Metadata
                HStack {
                    // Author
                    HStack(spacing: DesignSystem.Spacing.mini) {
                        Circle()
                            .fill(DesignSystem.Colors.primaryDark.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if let picture = author?.picture, let url = URL(string: picture) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(DesignSystem.Colors.primaryDark)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.primaryDark)
                                }
                            }
                        
                        Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Reading time
                    Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    // Date
                    if let publishedAt = article.publishedAt {
                        Text("•")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text(publishedAt.formatted(.relative(presentation: .named)))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
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
        guard let ndk = appState.ndk else { return }
        
        // Load individual profile using declarative data source
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

// MARK: - Featured Card (Portrait)

struct ArticleFeaturedCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            if let imageURL = article.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 200)
                            .clipped()
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primaryDark.opacity(0.2),
                                        DesignSystem.Colors.primary.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 280, height: 200)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                // Title
                Text(article.title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Summary
                if let summary = article.summary {
                    Text(summary)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Author and metadata
                HStack {
                    // Author
                    HStack(spacing: DesignSystem.Spacing.mini) {
                        Circle()
                            .fill(DesignSystem.Colors.primaryDark.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if let picture = author?.picture, let url = URL(string: picture) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(DesignSystem.Colors.primaryDark)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.primaryDark)
                                }
                            }
                        
                        Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Reading time
                    Text("\(article.estimatedReadingTime) min")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding()
        }
        .frame(width: 280, height: 380)
        .modernCard()
        .task {
            await loadAuthor()
        }
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

// MARK: - Row Card (Horizontal)

struct ArticleRowCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Small image on the left
            if let imageURL = article.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure(_), .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primaryDark.opacity(0.1),
                                        DesignSystem.Colors.primary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Content on the right
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                // Title
                Text(article.title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Summary
                if let summary = article.summary {
                    Text(summary)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Metadata
                HStack(spacing: DesignSystem.Spacing.small) {
                    // Author
                    HStack(spacing: 4) {
                        Circle()
                            .fill(DesignSystem.Colors.primaryDark.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .overlay {
                                if let picture = author?.picture, let url = URL(string: picture) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(DesignSystem.Colors.primaryDark)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(DesignSystem.Colors.primaryDark)
                                }
                            }
                        
                        Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Text("•")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    // Reading time
                    Text("\(article.estimatedReadingTime) min read")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    // Date
                    if let publishedAt = article.publishedAt {
                        Text("•")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text(publishedAt.formatted(.relative(presentation: .named)))
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .modernCard()
        .task {
            await loadAuthor()
        }
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

#Preview {
    ArticleListView()
        .environmentObject(AppState())
}
