import SwiftUI
import NDKSwift

/// Manages data streaming and state for the Home view
/// This class follows SRP by focusing solely on data management and streaming
@MainActor
class HomeDataManager: ObservableObject {
    // MARK: - Published State
    @Published var highlights: [HighlightEvent] = []
    @Published var highlightedArticles: [HighlightedArticle] = []
    @Published var discussions: [NDKEvent] = []
    @Published var zappedArticles: [NDKEvent] = []
    @Published var userHighlights: [HighlightEvent] = []
    @Published var curations: [ArticleCuration] = []
    @Published var suggestedUsers: [NDKUserProfile] = []
    @Published var suggestedUserPubkeys: [String] = []
    @Published var isRefreshing = false
    
    // MARK: - Private Properties
    private var streamingTasks: [Task<Void, Never>] = []
    var appState: AppState? // Made non-weak and internal for setting from view
    
    // MARK: - Models
    struct HighlightedArticle {
        let article: Article
        let highlights: [HighlightEvent]
        let lastHighlightTime: Date
    }
    
    // MARK: - Initialization
    init() {
        // AppState will be set by the view that creates this manager
    }
    
    // MARK: - Public Methods
    
    /// Start streaming all data sources
    func startStreaming() async {
        guard let ndk = appState?.ndk else { return }
        
        stopAllStreams()
        
        // Start all streams concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchRecentlyHighlightedArticles(ndk: ndk) }
            group.addTask { await self.streamHighlights(ndk: ndk) }
            group.addTask { await self.streamUserHighlights(ndk: ndk) }
            group.addTask { await self.streamDiscussions(ndk: ndk) }
            group.addTask { await self.streamZappedArticles(ndk: ndk) }
            group.addTask { await self.streamCurations(ndk: ndk) }
            group.addTask { await self.fetchSuggestedUsers(ndk: ndk) }
        }
    }
    
    /// Refresh all content by clearing and re-streaming
    func refresh() async {
        isRefreshing = true
        HapticManager.shared.impact(HapticManager.ImpactStyle.light)
        
        // Clear all data
        highlights.removeAll()
        highlightedArticles.removeAll()
        discussions.removeAll()
        zappedArticles.removeAll()
        userHighlights.removeAll()
        curations.removeAll()
        suggestedUsers.removeAll()
        suggestedUserPubkeys.removeAll()
        
        // Restart streaming
        await startStreaming()
        
        HapticManager.shared.notification(.success)
        isRefreshing = false
    }
    
    /// Stop all streaming tasks
    func stopAllStreams() {
        for task in streamingTasks {
            task.cancel()
        }
        streamingTasks.removeAll()
    }
    
    // MARK: - Private Streaming Methods
    
    /// Fetch recently highlighted articles - waits for EOSE then fetches articles
    private func fetchRecentlyHighlightedArticles(ndk: NDK) async {
        
        // Create subscription for recent highlights
        let sevenDaysAgo = Timestamp(Date().addingTimeInterval(-7 * 24 * 60 * 60).timeIntervalSince1970)
        let highlightFilter = NDKFilter(
            kinds: [9802],
            since: sevenDaysAgo,
            limit: 100
        )
        
        let dataSource = NDKDataSource(
            ndk: ndk,
            filter: highlightFilter,
            maxAge: 0,
            cachePolicy: .networkOnly,
            closeOnEose: true
        )
        
        var articleReferences: Set<String> = []
        var highlightsByArticle: [String: [HighlightEvent]] = [:]
        var allHighlights: [HighlightEvent] = []
        
        // Collect all highlights until EOSE
        for await event in dataSource.events {
            if let highlight = try? HighlightEvent(from: event) {
                allHighlights.append(highlight)
                
                // Track article references
                if let ref = highlight.referencedEvent {
                    articleReferences.insert(ref)
                    if highlightsByArticle[ref] != nil {
                        highlightsByArticle[ref]?.append(highlight)
                    } else {
                        highlightsByArticle[ref] = [highlight]
                    }
                }
            }
        }
        
        
        // Now fetch the referenced articles
        if !articleReferences.isEmpty {
            await fetchHighlightedArticles(
                ndk: ndk,
                references: Array(articleReferences),
                highlightsByArticle: highlightsByArticle
            )
        }
    }
    
    private func streamHighlights(ndk: NDK) async {
        let task = Task {
            let highlightSource = await ndk.outbox.observe(
                filter: NDKFilter(kinds: [9802], limit: 50),
                maxAge: CachePolicies.shortTerm,
                cachePolicy: .cacheWithNetwork
            )
            
            var articleReferences: Set<String> = []
            var highlightsByArticle: [String: [HighlightEvent]] = [:]
            
            for await event in highlightSource.events {
                if let highlight = try? HighlightEvent(from: event) {
                    await MainActor.run {
                        withAnimation(DesignSystem.Animation.quick) {
                            if !highlights.contains(where: { $0.id == highlight.id }) {
                                highlights.append(highlight)
                                highlights.sort { $0.createdAt > $1.createdAt }
                                
                                // Also add to userHighlights for display
                                if !userHighlights.contains(where: { $0.id == highlight.id }) {
                                    userHighlights.append(highlight)
                                    userHighlights.sort { $0.createdAt > $1.createdAt }
                                }
                                
                                
                                // Track article references for highlighted articles
                                if let ref = highlight.referencedEvent {
                                    articleReferences.insert(ref)
                                    if highlightsByArticle[ref] != nil {
                                        highlightsByArticle[ref]?.append(highlight)
                                    } else {
                                        highlightsByArticle[ref] = [highlight]
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Fetch referenced articles if any
            if !articleReferences.isEmpty {
                await fetchHighlightedArticles(
                    ndk: ndk,
                    references: Array(articleReferences),
                    highlightsByArticle: highlightsByArticle
                )
            }
        }
        streamingTasks.append(task)
    }
    
    private func streamUserHighlights(ndk: NDK) async {
        guard let signer = appState?.activeSigner else { return }
        
        let task = Task {
            do {
                let userPubkey = try await signer.pubkey
                let userHighlightSource = await ndk.outbox.observe(
                    filter: NDKFilter(
                        authors: [userPubkey],
                        kinds: [9802],
                        limit: 5
                    ),
                    maxAge: CachePolicies.mediumTerm
                )
                
                for await event in userHighlightSource.events {
                    if let highlight = try? HighlightEvent(from: event) {
                        await MainActor.run {
                            withAnimation(DesignSystem.Animation.quick) {
                                if !userHighlights.contains(where: { $0.id == highlight.id }) {
                                    userHighlights.append(highlight)
                                    userHighlights.sort { $0.createdAt > $1.createdAt }
                                }
                            }
                        }
                    }
                }
            } catch {
            }
        }
        streamingTasks.append(task)
    }
    
    private func streamDiscussions(ndk: NDK) async {
        let task = Task {
            let discussionSource = await ndk.outbox.observe(
                filter: NDKFilter(kinds: [1], limit: 10, tags: ["t": Set(["bookstr"])]),
                maxAge: CachePolicies.shortTerm,
                cachePolicy: .cacheWithNetwork
            )
            
            for await event in discussionSource.events {
                await MainActor.run {
                    withAnimation(DesignSystem.Animation.quick) {
                        if !discussions.contains(where: { $0.id == event.id }) {
                            discussions.append(event)
                            discussions.sort { $0.createdAt > $1.createdAt }
                        }
                    }
                }
            }
        }
        streamingTasks.append(task)
    }
    
    private func streamZappedArticles(ndk: NDK) async {
        let task = Task {
            let zapSource = await ndk.outbox.observe(
                filter: NDKFilter(kinds: [9735], limit: 10),
                maxAge: CachePolicies.shortTerm,
                cachePolicy: .cacheWithNetwork
            )
            
            for await event in zapSource.events {
                await MainActor.run {
                    withAnimation(DesignSystem.Animation.quick) {
                        if !zappedArticles.contains(where: { $0.id == event.id }) {
                            zappedArticles.append(event)
                            zappedArticles.sort { $0.createdAt > $1.createdAt }
                        }
                    }
                }
            }
        }
        streamingTasks.append(task)
    }
    
    
    private func fetchHighlightedArticles(
        ndk: NDK,
        references: [String],
        highlightsByArticle: [String: [HighlightEvent]]
    ) async {
        // Parse references to extract article IDs
        var articleFilters: [NDKFilter] = []
        
        for reference in references {
            if reference.contains(":") {
                // This is an "a" tag reference (kind:pubkey:d-tag)
                let parts = reference.split(separator: ":")
                if parts.count >= 3,
                   let kind = Int(parts[0]) {
                    let dTag = parts[2...].joined(separator: ":") // Handle d-tags with colons
                    articleFilters.append(NDKFilter(
                        authors: [String(parts[1])],
                        kinds: [kind],
                        tags: ["d": Set([dTag])]
                    ))
                }
            } else {
                // This is an "e" tag reference (event ID)
                articleFilters.append(NDKFilter(ids: [reference]))
            }
        }
        
        // Fetch articles for each filter
        for filter in articleFilters {
            let dataSource = NDKDataSource(
                ndk: ndk,
                filter: filter,
                maxAge: 0,
                cachePolicy: .networkOnly,
                closeOnEose: true
            )
            
            for await event in dataSource.events {
                if event.kind == 30023,
                   let article = try? Article(from: event) {
                    // Check both formats: event ID and "a" tag format
                    let aTagReference = "\(event.kind):\(event.pubkey):\(article.identifier ?? "")"
                    let highlights = highlightsByArticle[event.id] ?? highlightsByArticle[aTagReference]
                    
                    
                    if let highlights = highlights {
                        let lastHighlight = highlights.max(by: { $0.createdAt < $1.createdAt })
                        
                        await MainActor.run {
                            withAnimation(DesignSystem.Animation.quick) {
                                let highlightedArticle = HighlightedArticle(
                                    article: article,
                                    highlights: highlights,
                                    lastHighlightTime: lastHighlight?.createdAt ?? Date()
                                )
                                
                                if !highlightedArticles.contains(where: { $0.article.id == article.id }) {
                                    highlightedArticles.append(highlightedArticle)
                                    highlightedArticles.sort { $0.lastHighlightTime > $1.lastHighlightTime }
                                    
                                    // Limit to top 10 most recently highlighted articles
                                    if highlightedArticles.count > 10 {
                                        highlightedArticles = Array(highlightedArticles.prefix(10))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func streamCurations(ndk: NDK) async {
        let task = Task {
            let curationSource = await ndk.outbox.observe(
                filter: NDKFilter(kinds: [30004], limit: 20),
                maxAge: CachePolicies.mediumTerm,
                cachePolicy: .cacheWithNetwork
            )
            
            for await event in curationSource.events {
                if let curation = try? ArticleCuration(from: event) {
                    await MainActor.run {
                        withAnimation(DesignSystem.Animation.quick) {
                            if !curations.contains(where: { $0.id == curation.id }) {
                                curations.append(curation)
                                // Sort by creation date, newest first
                                curations.sort { $0.createdAt > $1.createdAt }
                                // Keep top 10 curations
                                if curations.count > 10 {
                                    curations = Array(curations.prefix(10))
                                }
                            }
                        }
                    }
                }
            }
        }
        streamingTasks.append(task)
    }
    
    private func fetchSuggestedUsers(ndk: NDK) async {
        // Fetch users who are actively creating highlights
        let highlightersFilter = NDKFilter(
            kinds: [9802],
            limit: 50
        )
        
        let dataSource = NDKDataSource(
            ndk: ndk,
            filter: highlightersFilter,
            maxAge: CachePolicies.mediumTerm,
            cachePolicy: .cacheOnly,
            closeOnEose: true
        )
        
        var userPubkeys = Set<String>()
        
        // Collect unique pubkeys from recent highlights
        for await event in dataSource.events {
            userPubkeys.insert(event.pubkey)
            if userPubkeys.count >= 20 {
                break
            }
        }
        
        // Fetch profiles for these users
        guard !userPubkeys.isEmpty else { return }
        
        let profileFilter = NDKFilter(
            authors: Array(userPubkeys),
            kinds: [0]
        )
        
        let profileSource = NDKDataSource(
            ndk: ndk,
            filter: profileFilter,
            maxAge: 0,
            cachePolicy: .cacheWithNetwork,
            closeOnEose: true
        )
        
        var profilesWithPubkeys: [(profile: NDKUserProfile, pubkey: String)] = []
        
        for await event in profileSource.events {
            if event.kind == 0,
               let profile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                profilesWithPubkeys.append((profile: profile, pubkey: event.pubkey))
            }
        }
        
        // Update suggested users - we'll need to handle this differently
        await MainActor.run {
            withAnimation(DesignSystem.Animation.quick) {
                // For now, store pubkeys separately
                suggestedUserPubkeys = profilesWithPubkeys.map { $0.pubkey }
                suggestedUsers = profilesWithPubkeys
                    .filter { $0.profile.displayName != nil || $0.profile.name != nil } // Only users with names
                    .prefix(10)
                    .map { $0.profile }
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        Task { @MainActor [weak self] in
            self?.stopAllStreams()
        }
    }
}