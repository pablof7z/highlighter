import SwiftUI
import NDKSwift

/// Manages home-specific data streaming and state, composing with DataStreamManager
/// This class focuses on home view specific data while delegating common data to DataStreamManager
@MainActor
class HomeDataManager: ObservableObject {
    // MARK: - Published State
    // Home-specific data only
    @Published var highlightedArticles: [HighlightedArticle] = []
    @Published var discussions: [NDKEvent] = []
    @Published var zappedArticles: [NDKEvent] = []
    @Published var userHighlights: [HighlightEvent] = []
    @Published var suggestedUsers: [NDKUserProfile] = []
    @Published var suggestedUserPubkeys: [String] = []
    @Published var isRefreshing = false
    
    // Common data from DataStreamManager
    var highlights: [HighlightEvent] { appState?.highlights ?? [] }
    var curations: [ArticleCuration] { appState?.curations ?? [] }
    
    // MARK: - Private Properties
    private var streamingTasks: [Task<Void, Never>] = []
    var appState: AppState? { // Made non-weak and internal for setting from view
        didSet {
            // Set up bindings to DataStreamManager when appState is set
            setupDataStreamBindings()
        }
    }
    
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
    
    private func setupDataStreamBindings() {
        // DataStreamManager already handles highlights and curations
        // We only need to manage home-specific data
    }
    
    // MARK: - Public Methods
    
    /// Start streaming home-specific data sources
    func startStreaming() async {
        guard let ndk = appState?.ndk else { return }
        
        stopAllStreams()
        
        // Start home-specific streams only
        // Common data (highlights, curations) is handled by DataStreamManager
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchRecentlyHighlightedArticles(ndk: ndk) }
            group.addTask { await self.streamUserHighlights(ndk: ndk) }
            group.addTask { await self.streamDiscussions(ndk: ndk) }
            group.addTask { await self.streamZappedArticles(ndk: ndk) }
            group.addTask { await self.fetchSuggestedUsers(ndk: ndk) }
        }
    }
    
    /// Refresh all content by clearing and re-streaming
    func refresh() async {
        isRefreshing = true
        HapticManager.shared.impact(HapticManager.ImpactStyle.light)
        
        // Clear home-specific data only
        highlightedArticles.removeAll()
        discussions.removeAll()
        zappedArticles.removeAll()
        userHighlights.removeAll()
        suggestedUsers.removeAll()
        suggestedUserPubkeys.removeAll()
        
        // Trigger refresh on DataStreamManager for common data
        await appState?.dataStreamManager.refresh()
        
        // Restart home-specific streaming
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
    
    /// Fetch recently highlighted articles using highlights from DataStreamManager
    private func fetchRecentlyHighlightedArticles(ndk: NDK) async {
        // Use highlights from DataStreamManager
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let recentHighlights = highlights.filter { $0.createdAt > sevenDaysAgo }
        
        var articleReferences: Set<String> = []
        var highlightsByArticle: [String: [HighlightEvent]] = [:]
        
        // Process recent highlights
        for highlight in recentHighlights {
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
        
        // Now fetch the referenced articles
        if !articleReferences.isEmpty {
            await fetchHighlightedArticles(
                ndk: ndk,
                references: Array(articleReferences),
                highlightsByArticle: highlightsByArticle
            )
        }
    }
    
    // Removed streamHighlights - now handled by DataStreamManager
    
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
                    )
                }
            } else {
                // This is an "e" tag reference (event ID)
                articleFilters.append(NDKFilter(ids: [reference])
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
                                        highlightedArticles = Array(highlightedArticles.prefix(10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Removed streamCurations - now handled by DataStreamManager
    
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
                profilesWithPubkeys.append((profile: profile, pubkey: event.pubkey)
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