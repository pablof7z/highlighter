import SwiftUI
import NDKSwift

struct EnhancedArticleDiscoveryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ArticleDiscoveryViewModel()
    let searchText: String
    
    @State private var selectedCategory: ArticleCategory = .all
    @State private var showFilters = false
    @State private var refreshID = UUID()
    
    enum ArticleCategory: String, CaseIterable {
        case all = "All"
        case technology = "Technology"
        case bitcoin = "Bitcoin"
        case philosophy = "Philosophy"
        case science = "Science"
        case culture = "Culture"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.3x3"
            case .technology: return "cpu"
            case .bitcoin: return "bitcoinsign.circle"
            case .philosophy: return "brain"
            case .science: return "atom"
            case .culture: return "theatermasks"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .ds.primary
            case .technology: return .blue
            case .bitcoin: return .orange
            case .philosophy: return .purple
            case .science: return .green
            case .culture: return .pink
            }
        }
        
        var hashtags: [String] {
            switch self {
            case .all: return []
            case .technology: return ["tech", "programming", "ai", "software"]
            case .bitcoin: return ["bitcoin", "btc", "lightning", "nostr"]
            case .philosophy: return ["philosophy", "wisdom", "thoughts", "ideas"]
            case .science: return ["science", "research", "physics", "biology"]
            case .culture: return ["culture", "art", "music", "literature"]
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Category selector with animation
                categorySelectorView
                
                // Featured article carousel
                if viewModel.featuredArticle != nil {
                    featuredArticleSection
                        .transition(.asymmetric(
                            insertion: .push(from: .bottom).combined(with: .opacity),
                            removal: .push(from: .top).combined(with: .opacity)
                        ))
                }
                
                // Trending articles
                if !viewModel.trendingArticles.isEmpty {
                    trendingArticlesSection
                }
                
                // Main article grid
                articleGridSection
            }
            .padding(.bottom, 100)
        }
        .refreshable {
            HapticManager.shared.impact(.medium)
            await viewModel.refreshArticles()
            refreshID = UUID()
            HapticManager.shared.notification(.success)
        }
        .task(id: refreshID) {
            if let ndk = appState.ndk {
                viewModel.configure(with: ndk)
                await viewModel.loadArticles(category: selectedCategory, searchText: searchText)
            }
        }
        .onChange(of: selectedCategory) { _, newCategory in
            Task {
                await viewModel.loadArticles(category: newCategory, searchText: searchText)
            }
        }
        .onChange(of: searchText) { _, newText in
            Task {
                await viewModel.searchArticles(query: newText, category: selectedCategory)
            }
        }
    }
    
    // MARK: - Components
    
    private var categorySelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ArticleCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
                
                // Filter button
                Button(action: { showFilters = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filters")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.ds.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.ds.primary.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.ds.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var featuredArticleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Featured Article", systemImage: "star.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                Text("AI Recommended")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.purple.opacity(0.1))
                    )
            }
            .padding(.horizontal)
            
            if let featured = viewModel.featuredArticle {
                FeaturedArticleCard(article: featured)
                    .padding(.horizontal)
            }
        }
    }
    
    private var trendingArticlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Trending Now", systemImage: "flame.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                Text("\(viewModel.trendingArticles.count) articles")
                    .font(.system(size: 14))
                    .foregroundColor(.ds.textSecondary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.trendingArticles) { article in
                        TrendingArticleCard(article: article)
                            .frame(width: 300)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var articleGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Discover Articles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            
            if viewModel.articles.isEmpty && !viewModel.isLoading {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("No articles found")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Try adjusting your search terms")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                    .padding(.horizontal)
                    .padding(.vertical, 60)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.articles) { article in
                        ArticleGridCard(article: article)
                    }
                }
                .padding(.horizontal)
            }
            
            // Load more button
            if viewModel.hasMoreArticles && !viewModel.isLoading {
                Button(action: {
                    Task {
                        await viewModel.loadMoreArticles()
                    }
                }) {
                    HStack {
                        Text("Load More")
                        Image(systemName: "arrow.down.circle")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.ds.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.ds.primary.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - View Model

@MainActor
class ArticleDiscoveryViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var trendingArticles: [Article] = []
    @Published var featuredArticle: Article?
    @Published var isLoading = false
    @Published var hasMoreArticles = true
    
    private var ndk: NDK?
    private var loadedEventIds = Set<String>()
    private var lastLoadedTimestamp: Timestamp?
    
    func configure(with ndk: NDK) {
        self.ndk = ndk
    }
    
    func loadArticles(category: EnhancedArticleDiscoveryView.ArticleCategory, searchText: String) async {
        guard let ndk = ndk else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // Clear previous results
        articles.removeAll()
        loadedEventIds.removeAll()
        lastLoadedTimestamp = nil
        
        // Build filter
        var filter = NDKFilter(kinds: [30023]) // Long-form content
        
        if !category.hashtags.isEmpty {
            // Create a new filter with the category tags
            filter = NDKFilter(
                kinds: [30023],
                limit: 20,
                tags: ["t": Set(category.hashtags)]
            )
        }
        
        filter.limit = 50
        
        // Subscribe with closeOnEose to get all matching events then close
        let dataSource = NDKDataSource(
            ndk: ndk,
            filter: filter,
            maxAge: 0,
            cachePolicy: .networkOnly,
            closeOnEose: true
        )
        
        var collectedEvents: [NDKEvent] = []
        for await event in dataSource.events {
            collectedEvents.append(event)
        }
        
        processArticleEvents(collectedEvents)
        
        // Load trending and featured
        await loadTrendingArticles()
        await loadFeaturedArticle(category: category)
    }
    
    func searchArticles(query: String, category: EnhancedArticleDiscoveryView.ArticleCategory) async {
        guard !query.isEmpty else {
            await loadArticles(category: category, searchText: "")
            return
        }
        
        // Filter existing articles first
        let filtered = articles.filter { article in
            article.title.localizedCaseInsensitiveContains(query) ||
            article.summary?.localizedCaseInsensitiveContains(query) == true ||
            article.hashtags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        
        withAnimation {
            articles = filtered
        }
        
        // Then search for more
        await loadArticles(category: category, searchText: query)
    }
    
    func loadMoreArticles() async {
        guard let ndk = ndk, !isLoading, hasMoreArticles else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        var filter = NDKFilter(kinds: [30023])
        filter.limit = 30
        
        if let lastTimestamp = lastLoadedTimestamp {
            filter.until = lastTimestamp
        }
        
        // Subscribe with closeOnEose to get all matching events then close
        let dataSource = NDKDataSource(
            ndk: ndk,
            filter: filter,
            maxAge: 0,
            cachePolicy: .networkOnly,
            closeOnEose: true
        )
        
        var collectedEvents: [NDKEvent] = []
        for await event in dataSource.events {
            collectedEvents.append(event)
        }
        
        if collectedEvents.count < 30 {
            hasMoreArticles = false
        }
        
        processArticleEvents(collectedEvents)
    }
    
    func refreshArticles() async {
        articles.removeAll()
        trendingArticles.removeAll()
        featuredArticle = nil
        loadedEventIds.removeAll()
        hasMoreArticles = true
        
        await loadArticles(category: .all, searchText: "")
    }
    
    private func processArticleEvents(_ events: [NDKEvent]) {
        let newArticles = events.compactMap { event -> Article? in
            guard !loadedEventIds.contains(event.id) else { return nil }
            loadedEventIds.insert(event.id)
            
            // Update last timestamp
            if lastLoadedTimestamp == nil || event.createdAt < lastLoadedTimestamp! {
                lastLoadedTimestamp = event.createdAt
            }
            
            return parseArticleEvent(event)
        }
        
        withAnimation {
            articles.append(contentsOf: newArticles)
        }
    }
    
    private func parseArticleEvent(_ event: NDKEvent) -> Article? {
        // Extract article data from tags
        var title = ""
        var summary: String?
        var image: String?
        var publishedAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
        var hashtags: [String] = []
        
        for tag in event.tags {
            guard let tagName = tag.first else { continue }
            
            switch tagName {
            case "title":
                title = tag[safe: 1] ?? ""
            case "summary":
                summary = tag[safe: 1]
            case "image":
                image = tag[safe: 1]
            case "published_at":
                if let timestamp = tag[safe: 1], let time = TimeInterval(timestamp) {
                    publishedAt = Date(timeIntervalSince1970: time)
                }
            case "t":
                if let hashtag = tag[safe: 1] {
                    hashtags.append(hashtag)
                }
            default:
                break
            }
        }
        
        guard !title.isEmpty else { return nil }
        
        return Article(
            id: event.id,
            identifier: event.id,
            title: title,
            summary: summary,
            content: event.content,
            author: event.pubkey,
            publishedAt: publishedAt,
            image: image,
            hashtags: hashtags,
            createdAt: event.createdAt
        )
    }
    
    private func loadTrendingArticles() async {
        // For now, take top articles
        // In production, this would analyze zaps, comments, and highlights
        trendingArticles = Array(articles.prefix(5))
    }
    
    private func loadFeaturedArticle(category: EnhancedArticleDiscoveryView.ArticleCategory) async {
        // For now, pick a random article
        // In production, this would use AI to recommend based on user preferences
        featuredArticle = articles.randomElement()
    }
}

// MARK: - Card Components

struct CategoryChip: View {
    let category: EnhancedArticleDiscoveryView.ArticleCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
                    .overlay(
                        Capsule()
                            .strokeBorder(category.color.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturedArticleCard: View {
    let article: Article
    @EnvironmentObject var appState: AppState
    @State private var isBookmarked = false
    
    var body: some View {
        NavigationLink(destination: ArticleView(article: article)) {
            VStack(alignment: .leading, spacing: 16) {
                // Image with gradient overlay
                ZStack(alignment: .bottomLeading) {
                    if let imageUrl = article.image {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 220)
                                    .clipped()
                            case .empty, .failure:
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 220)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 220)
                    }
                    
                    // Gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // Title on image
                    Text(article.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .padding()
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    if let summary = article.summary {
                        Text(summary)
                            .font(.system(size: 16))
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(3)
                    }
                    
                    HStack {
                        // Author
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.ds.surfaceSecondary)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(PubkeyFormatter.formatForAvatar(article.author))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.ds.text)
                                )
                            
                            Text(PubkeyFormatter.formatShort(article.author))
                                .font(.system(size: 14))
                                .foregroundColor(.ds.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Actions
                        HStack(spacing: 16) {
                            Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                                .font(.system(size: 13))
                                .foregroundColor(.ds.textTertiary)
                            
                            Button(action: {
                                Task {
                                    isBookmarked.toggle()
                                    try? await appState.bookmarkService.toggleArticleBookmark(article)
                                    HapticManager.shared.impact(.light)
                                }
                            }) {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(isBookmarked ? .ds.primary : .ds.textSecondary)
                            }
                        }
                    }
                    
                    // Tags
                    if !article.hashtags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(article.hashtags.prefix(5), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.purple.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.ds.surface)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isBookmarked = appState.bookmarkService.isArticleBookmarked(article.id)
        }
    }
}

struct TrendingArticleCard: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleView(article: article)) {
            HStack(spacing: 16) {
                // Thumbnail
                if let imageUrl = article.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        case .empty, .failure:
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.ds.surfaceSecondary)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.ds.textTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.ds.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let summary = article.summary {
                        Text(summary)
                            .font(.system(size: 14))
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.ds.textTertiary)
                        
                        Spacer()
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ds.surface)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ArticleGridCard: View {
    let article: Article
    @EnvironmentObject var appState: AppState
    @State private var isPressed = false
    @State private var isBookmarked = false
    
    var body: some View {
        NavigationLink(destination: ArticleView(article: article)) {
            VStack(alignment: .leading, spacing: 12) {
                // Thumbnail
                if let imageUrl = article.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        case .empty, .failure:
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.ds.surfaceSecondary)
                                .frame(height: 120)
                                .overlay(
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 24))
                                        .foregroundColor(.ds.textTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.ds.primary.opacity(0.2),
                                    Color.ds.secondary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.ds.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.ds.textTertiary)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                isBookmarked.toggle()
                                try? await appState.bookmarkService.toggleArticleBookmark(article)
                                HapticManager.shared.impact(.light)
                            }
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14))
                                .foregroundColor(isBookmarked ? .ds.primary : .ds.textTertiary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ds.surface)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .scaleEffect(isPressed ? 0.95 : 1)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            isBookmarked = appState.bookmarkService.isArticleBookmarked(article.id)
        }
    }
}

