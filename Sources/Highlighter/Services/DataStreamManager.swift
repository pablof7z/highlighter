import Foundation
import NDKSwift
import Combine

/// Manages centralized data streaming for the entire app
/// Follows SRP by focusing solely on data stream coordination and management
@MainActor
class DataStreamManager: ObservableObject {
    // MARK: - Published State
    @Published private(set) var highlights: [HighlightEvent] = []
    @Published private(set) var curations: [ArticleCuration] = []
    @Published private(set) var followPacks: [FollowPack] = []
    
    // MARK: - Private Properties
    private weak var ndk: NDK?
    private var streamingTasks: [Task<Void, Never>] = []
    private var dataSourceRefs: [NDKDataSource<NDKEvent>] = []
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Configuration
    func configure(with ndk: NDK) {
        self.ndk = ndk
    }
    
    // MARK: - Stream Management
    
    /// Start all data streams with optimized concurrent execution
    func startAllStreams() async {
        guard let ndk = ndk else { return }
        
        // Stop existing streams first
        stopAllStreams()
        
        // Start all streams concurrently for better performance
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.startHighlightStream(ndk: ndk) }
            group.addTask { await self.startCurationStream(ndk: ndk) }
            group.addTask { await self.startFollowPackStream(ndk: ndk) }
        }
    }
    
    /// Stop all active streams and clean up resources
    func stopAllStreams() {
        for task in streamingTasks {
            task.cancel()
        }
        streamingTasks.removeAll()
        dataSourceRefs.removeAll()
    }
    
    /// Clear all cached data and restart streams
    func refresh() async {
        highlights.removeAll()
        curations.removeAll()
        followPacks.removeAll()
        
        await startAllStreams()
    }
    
    // MARK: - Individual Stream Methods
    
    private func startHighlightStream(ndk: NDK) async {
        let highlightFilter = NDKFilter(kinds: [9802], limit: 100)
        let dataSource = await ndk.outbox.observe(
            filter: highlightFilter,
            maxAge: CachePolicies.shortTerm,
            cachePolicy: .cacheWithNetwork
        )
        dataSourceRefs.append(dataSource)
        
        let task = Task {
            for await event in dataSource.events {
                if let highlight = try? HighlightEvent(from: event) {
                    await addHighlight(highlight)
                }
            }
        }
        streamingTasks.append(task)
    }
    
    private func startCurationStream(ndk: NDK) async {
        let curationFilter = NDKFilter(kinds: [30004], limit: 50)
        let dataSource = await ndk.outbox.observe(
            filter: curationFilter,
            maxAge: CachePolicies.mediumTerm,
            cachePolicy: .cacheWithNetwork
        )
        dataSourceRefs.append(dataSource)
        
        let task = Task {
            for await event in dataSource.events {
                if let curation = try? ArticleCuration(from: event) {
                    await addCuration(curation)
                }
            }
        }
        streamingTasks.append(task)
    }
    
    private func startFollowPackStream(ndk: NDK) async {
        let followPackFilter = NDKFilter(kinds: [39089], limit: 20)
        let dataSource = await ndk.outbox.observe(
            filter: followPackFilter,
            maxAge: CachePolicies.mediumTerm,
            cachePolicy: .cacheWithNetwork
        )
        dataSourceRefs.append(dataSource)
        
        let task = Task {
            for await event in dataSource.events {
                if let pack = try? FollowPack(from: event) {
                    await addFollowPack(pack)
                }
            }
        }
        streamingTasks.append(task)
    }
    
    // MARK: - Data Management
    
    @MainActor
    private func addHighlight(_ highlight: HighlightEvent) {
        if !highlights.contains(where: { $0.id == highlight.id }) {
            highlights.append(highlight)
            highlights.sort { $0.createdAt > $1.createdAt }
        }
    }
    
    @MainActor
    private func addCuration(_ curation: ArticleCuration) {
        if !curations.contains(where: { $0.id == curation.id }) {
            curations.append(curation)
            curations.sort { $0.updatedAt > $1.updatedAt }
        }
    }
    
    @MainActor
    private func addFollowPack(_ pack: FollowPack) {
        if !followPacks.contains(where: { $0.id == pack.id }) {
            followPacks.append(pack)
        }
    }
    
    // MARK: - Cleanup
    deinit {
        Task { @MainActor in
            stopAllStreams()
        }
    }
}