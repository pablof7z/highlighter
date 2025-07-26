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
        print("DEBUG: Fetching recently highlighted articles")
        
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
                    print("DEBUG: Found highlight for article: \(ref)")
                }
            }
        }
        
        print("DEBUG: Collected \(allHighlights.count) highlights referencing \(articleReferences.count) unique articles")
        
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
            print("DEBUG: Starting to stream highlights")
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
                                
                                print("DEBUG: Added highlight: \(highlight.content.prefix(50))")
                                
                                // Track article references for highlighted articles
                                if let ref = highlight.referencedEvent {
                                    articleReferences.insert(ref)
                                    if highlightsByArticle[ref] != nil {
                                        highlightsByArticle[ref]?.append(highlight)
                                    } else {
                                        highlightsByArticle[ref] = [highlight]
                                    }
                                    print("DEBUG: Added highlight reference: \(ref)")
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
                print("Failed to get user pubkey: \(error)")
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
                    print("DEBUG: Creating filter for article - kind: \(kind), author: \(parts[1]), d-tag: \(dTag)")
                }
            } else {
                // This is an "e" tag reference (event ID)
                articleFilters.append(NDKFilter(ids: [reference]))
                print("DEBUG: Creating filter for event ID: \(reference)")
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
                    
                    print("DEBUG: Found article - ID: \(event.id), identifier: \(article.identifier ?? "nil"), aTagReference: \(aTagReference)")
                    print("DEBUG: Looking for highlights with keys: \(event.id) or \(aTagReference)")
                    print("DEBUG: Available highlight keys: \(highlightsByArticle.keys)")
                    
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
    
    // MARK: - Cleanup
    deinit {
        Task { @MainActor [weak self] in
            self?.stopAllStreams()
        }
    }
}