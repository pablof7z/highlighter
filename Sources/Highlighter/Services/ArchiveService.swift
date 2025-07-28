import Foundation
import NDKSwift

@MainActor
class ArchiveService: ObservableObject {
    @Published private(set) var archivedHighlights: [String: HighlightEvent] = [:]
    @Published private(set) var archivedArticles: [String: Article] = [:]
    @Published private(set) var isLoading = false
    
    private var ndk: NDK?
    private var signer: NDKSigner?
    private var currentUserPubkey: String?
    private var loadingTask: Task<Void, Never>?
    private var archiveEventId: String?
    
    // MARK: - Configuration
    
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
        
        Task {
            if let signer = signer {
                currentUserPubkey = try? await signer.pubkey
                await loadArchives()
            }
        }
    }
    
    // MARK: - Highlight Archives
    
    func isHighlightArchived(_ highlightId: String) -> Bool {
        archivedHighlights[highlightId] != nil
    }
    
    func archiveHighlight(_ highlight: HighlightEvent) async throws {
        guard let _ = ndk, let _ = signer else {
            throw ArchiveError.notConfigured
        }
        
        if !isHighlightArchived(highlight.id) {
            archivedHighlights[highlight.id] = highlight
            saveToLocalStorage()
            
            // Publish updated archive list
            try await publishArchiveList()
        }
    }
    
    func unarchiveHighlight(_ highlightId: String) async throws {
        guard let _ = ndk, let _ = signer else {
            throw ArchiveError.notConfigured
        }
        
        archivedHighlights.removeValue(forKey: highlightId)
        saveToLocalStorage()
        
        // Publish updated archive list
        try await publishArchiveList()
    }
    
    // MARK: - Article Archives
    
    func isArticleArchived(_ articleId: String) -> Bool {
        archivedArticles[articleId] != nil
    }
    
    func archiveArticle(_ article: Article) async throws {
        guard let _ = ndk, let _ = signer else {
            throw ArchiveError.notConfigured
        }
        
        if !isArticleArchived(article.id) {
            archivedArticles[article.id] = article
            saveToLocalStorage()
            
            try await publishArchiveList()
        }
    }
    
    func unarchiveArticle(_ articleId: String) async throws {
        guard let _ = ndk, let _ = signer else {
            throw ArchiveError.notConfigured
        }
        
        archivedArticles.removeValue(forKey: articleId)
        saveToLocalStorage()
        
        try await publishArchiveList()
    }
    
    // MARK: - Publishing
    
    private func publishArchiveList() async throws {
        guard let ndk = ndk, let signer = signer else {
            throw ArchiveError.notConfigured
        }
        
        // Create archive list event (kind: 30001, d-tag: "archive")
        var tags: [[String]] = [
            ["d", "archive"],
            ["title", "Archived Items"],
            ["description", "Archived highlights and articles"]
        ]
        
        // Add highlight references
        for (highlightId, _) in archivedHighlights {
            tags.append(["e", highlightId, "wss://relay.damus.io", "highlight"])
        }
        
        // Add article references
        for (_, article) in archivedArticles {
            if let identifier = article.identifier {
                tags.append(["a", "\(identifier)::\(article.author)", "wss://relay.damus.io", article.title])
            }
        }
        
        // Build and sign the event
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(30001)
            .content("")
            .tags(tags)
            .build(signer: signer)
        
        // Publish the event
        _ = try await ndk.publish(event)
        
        // Store the event ID for future updates
        archiveEventId = event.id
    }
    
    // MARK: - Loading
    
    func loadArchives() async {
        guard let ndk = ndk,
              let currentUserPubkey = currentUserPubkey else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let filter = NDKFilter(
            authors: [currentUserPubkey],
            kinds: [30001],
            tags: ["d": Set(["archive"])]
        )
        
        var events: [NDKEvent] = []
        
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheOnly
        )
        
        for await event in dataSource.events.prefix(100) {
            events.append(event)
        }
        
        // Process the most recent archive event
        if let archiveEvent = events
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first {
            
            archiveEventId = archiveEvent.id
            
            // Process highlight archives
            let highlightIds = archiveEvent.tags
                .filter { tag in 
                    tag.count >= 4 && tag[0] == "e" && tag[3] == "highlight" 
                }
                .map { tag in tag[1] }
            
            await loadHighlights(ids: highlightIds)
            
            // Process article archives
            let articleTags = archiveEvent.tags
                .filter { $0.count >= 4 && $0[0] == "a" }
            
            await processArchivedArticles(from: articleTags)
        }
        
        // Load from local storage as fallback
        loadFromLocalStorage()
    }
    
    private func loadHighlights(ids: [String]) async {
        guard let ndk = ndk else { return }
        
        let filter = NDKFilter(
            ids: ids,
            kinds: [9802]
        )
        
        var events: [NDKEvent] = []
        
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheOnly
        )
        
        for await event in dataSource.events.prefix(100) {
            events.append(event)
        }
        
        for event in events {
            do {
                let highlight = try HighlightEvent(from: event)
                archivedHighlights[highlight.id] = highlight
            } catch {
                // Skip invalid highlight events
            }
        }
    }
    
    private func processArchivedArticles(from tags: [[String]]) async {
        guard let ndk = ndk else { return }
        
        for tag in tags where tag.count >= 4 {
            let identifier = tag[1]
            let _ = tag[3] // title for reference
            
            // Parse identifier (format: "kind:pubkey:d-tag")
            let parts = identifier.split(separator: ":")
            if parts.count >= 3 {
                let kind = Int(parts[0]) ?? 30023
                let pubkey = String(parts[1])
                let dTag = parts[2...].joined(separator: ":")
                
                let filter = NDKFilter(
                    authors: [pubkey],
                    kinds: [kind],
                    tags: ["d": Set([dTag])]
                )
                
                let dataSource = ndk.observe(
                    filter: filter,
                    maxAge: 300,
                    cachePolicy: .cacheOnly
                )
                
                for await event in dataSource.events.prefix(1) {
                    do {
                        let article = try Article(from: event)
                        archivedArticles[article.id] = article
                    } catch {
                        // Skip invalid article events
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Local Storage
    
    private func saveToLocalStorage() {
        let archiveData = ArchivedItems(
            highlightIds: Array(archivedHighlights.keys),
            articleIds: Array(archivedArticles.keys)
        )
        
        if let encoded = try? JSONEncoder().encode(archiveData) {
            UserDefaults.standard.set(encoded, forKey: "archived_items")
        }
    }
    
    private func loadFromLocalStorage() {
        guard let data = UserDefaults.standard.data(forKey: "archived_items"),
              let _ = try? JSONDecoder().decode(ArchivedItems.self, from: data) else {
            return
        }
        
        // Only load IDs, actual content will be fetched from Nostr
        // This serves as a cache hint for offline mode
    }
}

// MARK: - Supporting Types

private struct ArchivedItems: Codable {
    let highlightIds: [String]
    let articleIds: [String]
}

enum ArchiveError: LocalizedError {
    case notConfigured
    case publishFailed
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Archive service not configured"
        case .publishFailed:
            return "Failed to publish archive event"
        }
    }
}