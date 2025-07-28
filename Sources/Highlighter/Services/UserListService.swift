import Foundation
import NDKSwift

/// Generic protocol for items that can be stored in user lists
protocol UserListItem: Identifiable {
    var id: String { get }
    func toTag() -> [String]
}

/// Generic service for managing NIP-51 user lists (bookmarks, archives, etc.)
@MainActor
class UserListService<ArticleType: UserListItem, HighlightType: UserListItem>: ObservableObject {
    @Published private(set) var articles: [String: ArticleType] = [:]
    @Published private(set) var highlights: [String: HighlightType] = [:]
    @Published private(set) var isLoading = false
    
    private let listIdentifier: String
    private let eventKind: Int
    private let localStorageKey: String
    
    private var ndk: NDK?
    private var signer: NDKSigner?
    private var currentUserPubkey: String?
    private var loadingTask: Task<Void, Never>?
    private var listEventId: String?
    
    // MARK: - Initialization
    
    init(
        listIdentifier: String,
        eventKind: Int = 30001,
        localStorageKey: String
    ) {
        self.listIdentifier = listIdentifier
        self.eventKind = eventKind
        self.localStorageKey = localStorageKey
    }
    
    // MARK: - Configuration
    
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
        
        Task {
            if let signer = signer {
                currentUserPubkey = try? await signer.pubkey
                await loadItems()
            }
        }
    }
    
    // MARK: - Article Management
    
    func isArticleInList(_ articleId: String) -> Bool {
        articles[articleId] != nil
    }
    
    func toggleArticle(_ article: ArticleType) async throws {
        guard let _ = ndk, let _ = signer else {
            throw UserListError.notConfigured
        }
        
        if isArticleInList(article.id) {
            articles.removeValue(forKey: article.id)
        } else {
            articles[article.id] = article
        }
        
        saveToLocalStorage()
        try await publishList()
    }
    
    // MARK: - Highlight Management
    
    func isHighlightInList(_ highlightId: String) -> Bool {
        highlights[highlightId] != nil
    }
    
    func toggleHighlight(_ highlight: HighlightType) async throws {
        guard let _ = ndk, let _ = signer else {
            throw UserListError.notConfigured
        }
        
        if isHighlightInList(highlight.id) {
            highlights.removeValue(forKey: highlight.id)
        } else {
            highlights[highlight.id] = highlight
        }
        
        saveToLocalStorage()
        try await publishList()
    }
    
    // MARK: - Publishing
    
    private func publishList() async throws {
        guard let ndk = ndk, let signer = signer else {
            throw UserListError.notConfigured
        }
        
        var tags: [[String]] = [
            ["d", listIdentifier]
        ]
        
        // Add article tags
        for article in articles.values {
            tags.append(article.toTag())
        }
        
        // Add highlight tags
        for highlight in highlights.values {
            tags.append(highlight.toTag())
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(eventKind)
            .content("")
            .tags(tags)
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
        
        listEventId = event.id
    }
    
    // MARK: - Loading
    
    private func loadItems() async {
        loadingTask?.cancel()
        
        loadingTask = Task {
            guard !Task.isCancelled else { return }
            
            isLoading = true
            defer { isLoading = false }
            
            // First load from local storage
            loadFromLocalStorage()
            
            // Then sync from Nostr
            await syncFromNostr()
        }
    }
    
    private func syncFromNostr() async {
        guard let ndk = ndk,
              let currentUserPubkey = currentUserPubkey else { return }
        
        let filter = NDKFilter(
            authors: [currentUserPubkey],
            kinds: [eventKind],
            tags: ["d": [listIdentifier]]
        )
        
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in dataSource.events {
            guard !Task.isCancelled else { break }
            await processListEvent(event)
        }
    }
    
    private func processListEvent(_ event: NDKEvent) async {
        // Clear existing items for full sync
        articles.removeAll()
        highlights.removeAll()
        
        // Process tags
        for tag in event.tags {
            guard tag.count >= 2 else { continue }
            
            switch tag[0] {
            case "a":
                // Article reference: ["a", "30023:pubkey:d-tag"]
                if let article = await fetchArticle(from: tag) {
                    articles[article.id] = article
                }
            case "e":
                // Highlight reference: ["e", "event-id"]
                if let highlight = await fetchHighlight(from: tag) {
                    highlights[highlight.id] = highlight
                }
            default:
                break
            }
        }
        
        saveToLocalStorage()
    }
    
    // MARK: - Abstract Methods (to be implemented by subclasses or extensions)
    
    private func fetchArticle(from tag: [String]) async -> ArticleType? {
        // This would be implemented based on the specific article type
        // For now, returning nil - subclasses should override
        return nil
    }
    
    private func fetchHighlight(from tag: [String]) async -> HighlightType? {
        // This would be implemented based on the specific highlight type
        // For now, returning nil - subclasses should override
        return nil
    }
    
    // MARK: - Local Storage
    
    private func saveToLocalStorage() {
        // Store just the IDs for now - simple string array storage
        let articleIds = Array(articles.keys)
        let highlightIds = Array(highlights.keys)
        
        UserDefaults.standard.set(articleIds, forKey: "\(localStorageKey)_articles")
        UserDefaults.standard.set(highlightIds, forKey: "\(localStorageKey)_highlights")
    }
    
    private func loadFromLocalStorage() {
        // For now, just clear storage since we can't persist complex objects easily
        // Items will be reloaded from Nostr when needed
        articles.removeAll()
        highlights.removeAll()
    }
}


// MARK: - Error Types

enum UserListError: LocalizedError {
    case notConfigured
    case publishFailed
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Service not configured with NDK"
        case .publishFailed:
            return "Failed to publish list update"
        }
    }
}

// MARK: - Conformance Extensions

extension Article: UserListItem {
    func toTag() -> [String] {
        let kind = event.kind
        let authorPubkey = author
        let dTag = identifier ?? id
        let naddr = "\(kind):\(authorPubkey):\(dTag)"
        return ["a", naddr]
    }
}

extension HighlightEvent: UserListItem {
    func toTag() -> [String] {
        return ["e", id]
    }
}