import SwiftUI
import NDKSwift

struct AdvancedSearchView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory = SearchCategory.all
    @State private var searchResults: SearchResults = SearchResults()
    @State private var isSearching = false
    @State private var showFilters = false
    @State private var recentSearches: [String] = []
    @State private var trendingTopics: [TrendingTopic] = []
    @State private var animateResults = false
    @State private var searchFieldFocused = false
    @State private var pulseAnimation = false
    @State private var showAISuggestions = false
    @State private var aiSuggestions: [String] = []
    
    @FocusState private var isSearchFieldFocused: Bool
    
    enum SearchCategory: String, CaseIterable {
        case all = "All"
        case highlights = "Highlights"
        case articles = "Articles"
        case users = "Users"
        case curations = "Curations"
        
        var icon: String {
            switch self {
            case .all: return "magnifyingglass"
            case .highlights: return "highlighter"
            case .articles: return "doc.text"
            case .users: return "person.2"
            case .curations: return "books.vertical"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .highlights: return .orange
            case .articles: return .green
            case .users: return .purple
            case .curations: return .pink
            }
        }
    }
    
    struct SearchResults {
        var highlights: [HighlightEvent] = []
        var articles: [Article] = []
        var users: [(pubkey: String, profile: NDKUserProfile)] = []
        var curations: [ArticleCuration] = []
        
        var isEmpty: Bool {
            highlights.isEmpty && articles.isEmpty && users.isEmpty && curations.isEmpty
        }
        
        var totalCount: Int {
            highlights.count + articles.count + users.count + curations.count
        }
    }
    
    struct TrendingTopic: Identifiable {
        let id = UUID()
        let topic: String
        let count: Int
        let trend: Double // -1 to 1, representing decline to growth
        let icon: String
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        selectedCategory.color.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: selectedCategory)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Advanced search header
                        advancedSearchHeader
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .padding(.top, DesignSystem.Spacing.medium)
                        
                        // Category selector with animations
                        animatedCategorySelector
                            .padding(.top, DesignSystem.Spacing.large)
                        
                        // Content based on search state
                        if searchText.isEmpty && !isSearching {
                            // Show trending and suggestions
                            VStack(spacing: DesignSystem.Spacing.xl) {
                                if showAISuggestions && !aiSuggestions.isEmpty {
                                    aiSuggestionsSection
                                }
                                
                                trendingSection
                                
                                recentSearchesSection
                            }
                            .padding(.top, DesignSystem.Spacing.xl)
                        } else if isSearching {
                            // Advanced loading state
                            advancedLoadingState
                                .padding(.top, DesignSystem.Spacing.huge)
                        } else {
                            // Search results with animations
                            searchResultsSection
                                .padding(.top, DesignSystem.Spacing.xl)
                        }
                    }
                    .padding(.bottom, DesignSystem.Spacing.huge * 2)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadTrendingTopics()
                loadRecentSearches()
                startPulseAnimation()
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.count > 2 {
                    performSearch()
                }
                if newValue.count > 0 && showAISuggestions {
                    generateAISuggestions()
                }
            }
        }
    }
    
    // MARK: - Search Header
    
    private var advancedSearchHeader: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Discover")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                // AI Toggle
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAISuggestions.toggle()
                        HapticManager.shared.impact(.light)
                        if showAISuggestions {
                            generateAISuggestions()
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                            .font(.system(size: 16))
                        Text("AI")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(showAISuggestions ? .white : DesignSystem.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(showAISuggestions ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(DesignSystem.Colors.primary, lineWidth: showAISuggestions ? 0 : 1)
                    )
                }
                .scaleEffect(pulseAnimation && showAISuggestions ? 1.05 : 1.0)
                
                // Filter button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showFilters.toggle()
                        HapticManager.shared.impact(.light)
                    }
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .rotationEffect(.degrees(showFilters ? 90 : 0))
                        .scaleEffect(showFilters ? 1.1 : 1.0)
                }
            }
            
            // Sophisticated search field
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(isSearchFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                    .rotationEffect(.degrees(isSearchFieldFocused ? 360 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSearchFieldFocused)
                
                TextField("Search highlights, articles, users...", text: $searchText)
                    .font(.system(size: 17))
                    .foregroundColor(DesignSystem.Colors.text)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        performSearch()
                        saveRecentSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            searchText = ""
                            searchResults = SearchResults()
                            HapticManager.shared.impact(.light)
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .stroke(
                                isSearchFieldFocused ? DesignSystem.Colors.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: isSearchFieldFocused ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Shadow.small.color,
                        radius: isSearchFieldFocused ? 20 : DesignSystem.Shadow.small.radius,
                        y: DesignSystem.Shadow.small.y
                    )
            )
            .scaleEffect(isSearchFieldFocused ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSearchFieldFocused)
        }
    }
    
    // MARK: - Category Selector
    
    private var animatedCategorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.small) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    SearchCategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                                HapticManager.shared.impact(.light)
                                if !searchText.isEmpty {
                                    performSearch()
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
        }
    }
    
    // MARK: - AI Suggestions
    
    private var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Image(systemName: "brain")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .symbolEffect(.pulse)
                
                Text("AI Suggestions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(aiSuggestions, id: \.self) { suggestion in
                        AISuggestionCard(
                            suggestion: suggestion,
                            action: {
                                searchText = suggestion
                                performSearch()
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Trending Section
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Trending Now")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DesignSystem.Colors.text)
                .padding(.horizontal, DesignSystem.Spacing.large)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.medium) {
                ForEach(trendingTopics) { topic in
                    TrendingCard(topic: topic) {
                        searchText = topic.topic
                        performSearch()
                    }
                    .searchPremiumEntrance()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
        }
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Recent Searches")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Button("Clear") {
                    withAnimation {
                        recentSearches.removeAll()
                        UserDefaults.standard.removeObject(forKey: "recentSearches")
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                ForEach(recentSearches, id: \.self) { search in
                    RecentSearchRow(search: search) {
                        searchText = search
                        performSearch()
                    }
                }
            }
        }
        .opacity(recentSearches.isEmpty ? 0 : 1)
    }
    
    // MARK: - Search Results
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            if !searchResults.isEmpty {
                // Results header with count
                HStack {
                    Text("\(searchResults.totalCount) Results")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    // Sort options
                    Menu {
                        Button("Most Recent", action: {})
                        Button("Most Popular", action: {})
                        Button("Most Relevant", action: {})
                    } label: {
                        HStack(spacing: 4) {
                            Text("Sort")
                                .font(.system(size: 14))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                
                // Results by category
                if selectedCategory == .all || selectedCategory == .highlights {
                    if !searchResults.highlights.isEmpty {
                        ResultSection(
                            title: "Highlights",
                            icon: "highlighter",
                            color: .orange,
                            count: searchResults.highlights.count
                        ) {
                            ForEach(searchResults.highlights, id: \.id) { highlight in
                                SearchResultHighlightCard(highlight: highlight)
                                    .searchPremiumEntrance()
                            }
                        }
                    }
                }
                
                if selectedCategory == .all || selectedCategory == .articles {
                    if !searchResults.articles.isEmpty {
                        ResultSection(
                            title: "Articles",
                            icon: "doc.text",
                            color: .green,
                            count: searchResults.articles.count
                        ) {
                            ForEach(searchResults.articles, id: \.id) { article in
                                SearchResultArticleCard(article: article)
                                    .searchPremiumEntrance()
                            }
                        }
                    }
                }
                
                if selectedCategory == .all || selectedCategory == .users {
                    if !searchResults.users.isEmpty {
                        ResultSection(
                            title: "Users",
                            icon: "person.2",
                            color: .purple,
                            count: searchResults.users.count
                        ) {
                            ForEach(searchResults.users, id: \.pubkey) { userInfo in
                                SearchResultUserCard(pubkey: userInfo.pubkey, user: userInfo.profile)
                                    .searchPremiumEntrance()
                            }
                        }
                    }
                }
            } else {
                // Empty state
                emptySearchState
            }
        }
    }
    
    // MARK: - Loading State
    
    private var advancedLoadingState: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Animated search icon
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(DesignSystem.Colors.primary.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                        .frame(width: 80 + CGFloat(index * 20), height: 80 + CGFloat(index * 20))
                        .scaleEffect(animateResults ? 1.2 : 0.8)
                        .opacity(animateResults ? 0 : 1)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.2),
                            value: animateResults
                        )
                }
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .rotationEffect(.degrees(animateResults ? 360 : 0))
                    .animation(
                        .linear(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: animateResults
                    )
            }
            
            Text("Searching...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .opacity(animateResults ? 1 : 0.5)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: animateResults
                )
        }
        .onAppear {
            animateResults = true
        }
    }
    
    // MARK: - Empty State
    
    private var emptySearchState: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("No results found")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Try adjusting your search or filters")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.huge)
    }
    
    // MARK: - Helper Methods
    
    private func performSearch() {
        isSearching = true
        animateResults = false
        
        Task {
            guard let ndk = appState.ndk, !searchText.isEmpty else {
                await MainActor.run {
                    isSearching = false
                    searchResults = SearchResults()
                }
                return
            }
            
            do {
                var results = SearchResults()
                
                // Search based on selected category
                switch selectedCategory {
                case .all:
                    // Search all types in parallel
                    async let highlightResults = searchHighlights(ndk: ndk)
                    async let userResults = searchUsers(ndk: ndk)
                    async let curationResults = searchCurations(ndk: ndk)
                    
                    results.highlights = await highlightResults
                    results.users = await userResults
                    results.curations = await curationResults
                    
                case .highlights:
                    results.highlights = await searchHighlights(ndk: ndk)
                    
                case .articles:
                    // Search for articles (kind: 30023)
                    let articleFilter = NDKFilter(
                        kinds: [30023]
                    )
                    let dataSource = await ndk.outbox.observe(filter: articleFilter)
                    var articles: [Article] = []
                    for await event in dataSource.events {
                        if let article = try? Article(from: event) {
                            // Filter by search text
                            if searchText.isEmpty ||
                               article.title.localizedCaseInsensitiveContains(searchText) ||
                               (article.summary ?? "").localizedCaseInsensitiveContains(searchText) ||
                               article.author.localizedCaseInsensitiveContains(searchText) ||
                               article.content.localizedCaseInsensitiveContains(searchText) {
                                articles.append(article)
                            }
                        }
                    }
                    results.articles = articles
                    
                case .users:
                    results.users = await searchUsers(ndk: ndk)
                    
                case .curations:
                    results.curations = await searchCurations(ndk: ndk)
                }
                
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        animateResults = true
                    }
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    // Handle error appropriately
                }
            }
        }
    }
    
    private func searchHighlights(ndk: NDK) async -> [HighlightEvent] {
        let filter = NDKFilter(
            kinds: [9802]
        )
        let dataSource = await ndk.outbox.observe(filter: filter)
        var highlights: [HighlightEvent] = []
        for await event in dataSource.events {
            if let highlight = try? HighlightEvent(from: event) {
                // Filter by search text
                if searchText.isEmpty || 
                   highlight.content.localizedCaseInsensitiveContains(searchText) ||
                   (highlight.source ?? "").localizedCaseInsensitiveContains(searchText) ||
                   highlight.author.localizedCaseInsensitiveContains(searchText) {
                    highlights.append(highlight)
                }
            }
        }
        return highlights
    }
    
    private func searchUsers(ndk: NDK) async -> [(pubkey: String, profile: NDKUserProfile)] {
        // Search user metadata
        let filter = NDKFilter(
            kinds: [0]
        )
        let dataSource = await ndk.outbox.observe(filter: filter)
        
        var users: [(pubkey: String, profile: NDKUserProfile)] = []
        for await event in dataSource.events {
            if let profile = try? JSONDecoder().decode(NDKUserProfile.self, from: Data(event.content.utf8)) {
                // Filter by search text
                if searchText.isEmpty ||
                   (profile.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                   (profile.displayName ?? "").localizedCaseInsensitiveContains(searchText) ||
                   (profile.about ?? "").localizedCaseInsensitiveContains(searchText) {
                    users.append((event.pubkey, profile))
                }
            }
        }
        return users
    }
    
    private func searchCurations(ndk: NDK) async -> [ArticleCuration] {
        let filter = NDKFilter(
            kinds: [30004]
        )
        let dataSource = await ndk.outbox.observe(filter: filter)
        var curations: [ArticleCuration] = []
        for await event in dataSource.events {
            if let curation = try? ArticleCuration(from: event) {
                // Filter by search text
                if searchText.isEmpty ||
                   curation.name.localizedCaseInsensitiveContains(searchText) ||
                   curation.title.localizedCaseInsensitiveContains(searchText) ||
                   (curation.description ?? "").localizedCaseInsensitiveContains(searchText) {
                    curations.append(curation)
                }
            }
        }
        return curations
    }
    
    private func loadTrendingTopics() {
        Task {
            guard let ndk = appState.ndk else { return }
            
            do {
                // Fetch recent highlights to analyze trending topics
                let since = Date().addingTimeInterval(-24 * 60 * 60) // Last 24 hours
                let filter = NDKFilter(
                    kinds: [9802],
                    since: Int64(since.timeIntervalSince1970)
                )
                
                let dataSource = await ndk.outbox.observe(filter: filter)
                var events: [NDKEvent] = []
                for await event in dataSource.events {
                    events.append(event)
                }
                
                // Extract and count hashtags/topics from highlights
                var topicCounts: [String: Int] = [:]
                
                for event in events {
                    // Extract hashtags from tags
                    let hashtags = event.tags
                        .filter { $0.first == "t" }
                        .compactMap { $0.count > 1 ? $0[1] : nil }
                    
                    for hashtag in hashtags {
                        topicCounts[hashtag, default: 0] += 1
                    }
                    
                    // Also extract common keywords from content
                    let keywords = extractKeywords(from: event.content)
                    for keyword in keywords {
                        topicCounts[keyword, default: 0] += 1
                    }
                }
                
                // Convert to TrendingTopic objects and sort by count
                let topics = topicCounts
                    .sorted { $0.value > $1.value }
                    .prefix(6)
                    .map { topic, count in
                        TrendingTopic(
                            topic: topic.capitalized,
                            count: count,
                            trend: Double.random(in: -0.5...1.0), // Calculate real trend in production
                            icon: iconForTopic(topic)
                        )
                    }
                
                await MainActor.run {
                    trendingTopics = Array(topics)
                }
            } catch {
                // Keep empty trending topics on error
            }
        }
    }
    
    private func extractKeywords(from content: String) -> [String] {
        // Simple keyword extraction - in production, use NLP
        let commonWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "from", "as", "is", "was", "are", "were", "been", "be", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "must", "can", "this", "that", "these", "those", "i", "you", "he", "she", "it", "we", "they", "them", "their", "what", "which", "who", "when", "where", "why", "how", "not", "no", "yes"])
        
        let words = content.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: " ")
            .components(separatedBy: .punctuationCharacters)
            .filter { $0.count > 3 && !commonWords.contains($0) }
        
        // Count word frequency
        var wordCounts: [String: Int] = [:]
        for word in words {
            wordCounts[word, default: 0] += 1
        }
        
        // Return top keywords
        return wordCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    private func iconForTopic(_ topic: String) -> String {
        let lowercased = topic.lowercased()
        switch lowercased {
        case let t where t.contains("bitcoin") || t.contains("btc"):
            return "bitcoinsign.circle"
        case let t where t.contains("lightning") || t.contains("ln"):
            return "bolt"
        case let t where t.contains("nostr"):
            return "network"
        case let t where t.contains("ai") || t.contains("ml") || t.contains("artificial"):
            return "brain"
        case let t where t.contains("privacy") || t.contains("security"):
            return "lock.shield"
        case let t where t.contains("web3") || t.contains("crypto"):
            return "globe"
        default:
            return "tag"
        }
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }
    
    private func saveRecentSearch() {
        guard !searchText.isEmpty else { return }
        
        if !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        }
    }
    
    private func generateAISuggestions() {
        // Generate contextual suggestions based on trending topics and recent searches
        var suggestions: [String] = []
        
        // Add suggestions based on trending topics
        for topic in trendingTopics.prefix(3) {
            suggestions.append("Latest \(topic.topic) highlights")
        }
        
        // Add suggestions based on partial search text
        if !searchText.isEmpty {
            suggestions.append("\(searchText) articles and discussions")
            if searchText.count > 3 {
                suggestions.append("Authors writing about \(searchText)")
            }
        }
        
        // Add general suggestions if needed
        if suggestions.count < 4 {
            let generalSuggestions = [
                "Popular highlights today",
                "Trending article collections",
                "New voices to follow"
            ]
            suggestions.append(contentsOf: generalSuggestions.prefix(4 - suggestions.count))
        }
        
        aiSuggestions = Array(suggestions.prefix(4))
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }
}

// MARK: - Supporting Views

struct SearchCategoryChip: View {
    let category: AdvancedSearchView.SearchCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
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
                            .stroke(category.color, lineWidth: isSelected ? 0 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? category.color.opacity(0.4) : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .magneticHover()
    }
}

struct TrendingCard: View {
    let topic: AdvancedSearchView.TrendingTopic
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: topic.icon)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    // Trend indicator
                    HStack(spacing: 2) {
                        Image(systemName: topic.trend > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                        Text("\(Int(abs(topic.trend * 100)))%")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(topic.trend > 0 ? .green : .red)
                }
                
                Text(topic.topic)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("\(topic.count) highlights")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
                    .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
            )
        }
        .magneticHover()
    }
}

struct AISuggestionCard: View {
    let suggestion: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(suggestion)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.1),
                                DesignSystem.Colors.secondary.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: DesignSystem.Colors.primary.opacity(0.2),
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
            if pressing {
                HapticManager.shared.impact(.light)
            }
        }, perform: {})
    }
}

struct RecentSearchRow: View {
    let search: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(search)
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResultSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("(\(count))")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            content()
                .padding(.horizontal, DesignSystem.Spacing.large)
        }
    }
}

struct SearchResultHighlightCard: View {
    let highlight: HighlightEvent
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Quote with highlight effect
            Text(highlight.content)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.text)
                .lineLimit(3)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Colors.highlightSubtle.opacity(0.3))
                        .padding(.horizontal, -4)
                )
            
            HStack {
                EnhancedAsyncProfileImage(pubkey: highlight.author, size: 20)
                
                Text(PubkeyFormatter.formatCompact(highlight.author))
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("·")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text(RelativeTimeFormatter.shortRelativeTime(from: highlight.createdAt))
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct SearchResultArticleCard: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Thumbnail
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.secondary.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "doc.text")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(1)
                
                if let summary = article.summary {
                    Text(summary)
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("\(article.estimatedReadingTime) min")
                        .font(.system(size: 12))
                    
                    Image(systemName: "highlighter")
                        .font(.system(size: 12))
                    Text("\(Int.random(in: 5...25))")
                        .font(.system(size: 12))
                }
                .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
    }
}

struct SearchResultUserCard: View {
    let pubkey: String
    let user: NDKUserProfile
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            EnhancedAsyncProfileImage(pubkey: pubkey, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.displayName ?? "Anonymous")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if user.nip05 != nil {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                if let about = user.about {
                    Text(about)
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Follow")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(DesignSystem.Colors.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
    }
}

// MARK: - View Modifiers

extension View {
    func searchPremiumEntrance() -> some View {
        self.modifier(SearchPremiumEntranceModifier())
    }
}


struct SearchPremiumEntranceModifier: ViewModifier {
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
    }
}

#Preview {
    AdvancedSearchView()
        .environmentObject(AppState())
}