import Foundation
import NDKSwift

@MainActor
class BookmarkService: ObservableObject {
    @Published private(set) var bookmarkedArticles: [String: Article] = [:]
    @Published private(set) var bookmarkedHighlights: [String: HighlightEvent] = [:]
    @Published private(set) var isLoading = false
    
    private var ndk: NDK?
    private var signer: NDKSigner?
    private var currentUserPubkey: String?
    private var loadingTask: Task<Void, Never>?
    private var cachedBookmarkIds: BookmarkIds?
    private var bookmarkEventIds: [String: String] = [:] // Maps content ID to bookmark event ID
    
    // MARK: - Configuration
    
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
        
        Task {
            if let signer = signer {
                currentUserPubkey = try? await signer.pubkey
                await loadBookmarks()
            }
        }
    }
    
    // MARK: - Article Bookmarks
    
    func isArticleBookmarked(_ articleId: String) -> Bool {
        bookmarkedArticles[articleId] != nil
    }
    
    func toggleArticleBookmark(_ article: Article) async throws {
        guard let _ = ndk, let _ = signer else {
            throw BookmarkError.notConfigured
        }
        
        if isArticleBookmarked(article.id) {
            // Remove bookmark
            await removeArticleBookmark(article.id)
            
            // Publish deletion event (NIP-09)
            if let existingEventId = findBookmarkEventId(for: article.id) {
                try await publishDeletionEvent(for: existingEventId)
            }
        } else {
            // Add bookmark
            await addArticleBookmark(article)
            
            // Publish bookmark event (kind 30001)
            try await publishArticleBookmark(article)
        }
    }
    
    private func addArticleBookmark(_ article: Article) async {
        bookmarkedArticles[article.id] = article
        saveToLocalStorage()
    }
    
    private func removeArticleBookmark(_ articleId: String) async {
        bookmarkedArticles.removeValue(forKey: articleId)
        saveToLocalStorage()
    }
    
    // MARK: - Highlight Bookmarks
    
    func isHighlightBookmarked(_ highlightId: String) -> Bool {
        bookmarkedHighlights[highlightId] != nil
    }
    
    func toggleHighlightBookmark(_ highlight: HighlightEvent) async throws {
        guard let _ = ndk, let _ = signer else {
            throw BookmarkError.notConfigured
        }
        
        if isHighlightBookmarked(highlight.id) {
            await removeHighlightBookmark(highlight.id)
            
            if let existingEventId = findHighlightBookmarkEventId(for: highlight.id) {
                try await publishDeletionEvent(for: existingEventId)
            }
        } else {
            await addHighlightBookmark(highlight)
            try await publishHighlightBookmark(highlight)
        }
    }
    
    private func addHighlightBookmark(_ highlight: HighlightEvent) async {
        bookmarkedHighlights[highlight.id] = highlight
        saveToLocalStorage()
    }
    
    private func removeHighlightBookmark(_ highlightId: String) async {
        bookmarkedHighlights.removeValue(forKey: highlightId)
        saveToLocalStorage()
    }
    
    // MARK: - Nostr Publishing
    
    private func publishArticleBookmark(_ article: Article) async throws {
        guard let _ = ndk, let _ = signer else { return }
        
        // Create bookmark list event (NIP-51, kind 30001)
        let tags: [[String]] = [
            ["d", "articles"], // Replaceable event identifier
            ["name", "Bookmarked Articles"],
            ["a", "\(article.identifier ?? article.id)::\(article.author)", "wss://relay.damus.io", article.title]
        ]
        
        let contentDict: [String: Any] = [
            "bookmarked_at": ISO8601DateFormatter().string(from: Date()),
            "note": "Saved for later reading"
        ]
        let content = (try? JSONSerialization.data(withJSONObject: contentDict)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(30001) // Bookmark list
            .content(content)
            .tags(tags)
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
        
        // Track the bookmark event ID
        bookmarkEventIds[article.id] = event.id
    }
    
    private func publishHighlightBookmark(_ highlight: HighlightEvent) async throws {
        guard let _ = ndk, let _ = signer else { return }
        
        let tags: [[String]] = [
            ["d", "highlights"],
            ["name", "Bookmarked Highlights"],
            ["e", highlight.id, "wss://relay.damus.io", "highlight"]
        ]
        
        let contentDict: [String: Any] = [
            "bookmarked_at": ISO8601DateFormatter().string(from: Date()),
            "highlight_content": highlight.content
        ]
        let content = (try? JSONSerialization.data(withJSONObject: contentDict)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(30001)
            .content(content)
            .tags(tags)
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
        
        // Track the bookmark event ID
        bookmarkEventIds[highlight.id] = event.id
    }
    
    private func publishDeletionEvent(for eventId: String) async throws {
        guard let _ = ndk, let _ = signer else { return }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(5) // Deletion
            .content("Removed bookmark")
            .tags([["e", eventId]])
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
    }
    
    // MARK: - Loading
    
    private func loadBookmarks() async {
        guard let ndk = ndk, let currentUserPubkey = currentUserPubkey else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // Load from local storage first
        loadFromLocalStorage()
        
        // Then sync with Nostr
        let filter = NDKFilter(
            authors: [currentUserPubkey],
            kinds: [30001],
            tags: ["d": ["articles", "highlights"]]
        )
        
        // Use outbox to get bookmark events
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 300 // 5 minute cache
        )
        
        var events: [NDKEvent] = []
        for await event in dataSource.events {
            events.append(event)
        }
        
        await processBookmarkEvents(events)
    }
    
    private func processBookmarkEvents(_ events: [NDKEvent]) async {
        for event in events {
            guard let dTag = event.tags.first(where: { $0.count > 1 && $0[0] == "d" })?[1] else {
                continue
            }
            
            switch dTag {
            case "articles":
                await processArticleBookmarks(from: event)
            case "highlights":
                await processHighlightBookmarks(from: event)
            default:
                break
            }
        }
    }
    
    private func processArticleBookmarks(from event: NDKEvent) async {
        let articleTags = event.tags.filter { $0.first == "a" }
        
        for tag in articleTags {
            guard tag.count >= 4 else { continue }
            let articleData = tag[1].split(separator: ":").map(String.init)
            guard articleData.count >= 2 else {
                continue
            }
            
            let articleId = articleData[0]
            let author = articleData[1]
            let title = tag[3]
            
            // Create article from bookmark data
            let article = Article(
                id: articleId,
                identifier: articleId,
                title: title,
                summary: nil,
                content: "", // Will be loaded when opened
                author: author,
                publishedAt: Date(timeIntervalSince1970: TimeInterval(event.createdAt)),
                image: nil,
                hashtags: [],
                createdAt: event.createdAt
            )
            
            // Track the bookmark event ID for this article
            bookmarkEventIds[articleId] = event.id
            
            await addArticleBookmark(article)
        }
    }
    
    private func processHighlightBookmarks(from event: NDKEvent) async {
        // Process highlight bookmarks from event tags
        let highlightTags = event.tags.filter { $0.first == "e" }
        
        for tag in highlightTags where tag.count >= 2 {
            let highlightId = tag[1]
            
            // Track the bookmark event ID for this highlight
            bookmarkEventIds[highlightId] = event.id
            
            // Fetch the actual highlight event
            if let ndk = ndk {
                let filter = NDKFilter(ids: [highlightId])
                
                // Use observe to get the highlight event
                let highlightDataSource = await ndk.outbox.observe(
                    filter: filter,
                    maxAge: 300 // 5 minute cache
                )
                
                for await highlightEvent in highlightDataSource.events {
                    // Convert to HighlightEvent
                    let highlight = HighlightEvent(
                        id: highlightId,
                        event: highlightEvent,
                        content: highlightEvent.content,
                        author: highlightEvent.pubkey,
                        createdAt: Date(timeIntervalSince1970: TimeInterval(highlightEvent.createdAt)),
                        context: nil,
                        url: highlightEvent.tags.first(where: { $0.first == "r" })?.dropFirst().first,
                        referencedEvent: highlightEvent.tags.first(where: { $0.first == "e" })?.dropFirst().first,
                        attributedAuthors: highlightEvent.tags.filter { $0.first == "p" }.compactMap { $0.dropFirst().first },
                        comment: nil
                    )
                    
                    await addHighlightBookmark(highlight)
                    break // Only need the first event
                }
            }
        }
    }
    
    // MARK: - Local Storage
    
    private func saveToLocalStorage() {
        // For now, we'll only save the IDs since Article and HighlightEvent contain NDKEvent which isn't Codable
        let bookmarkIds = BookmarkIds(
            articleIds: Array(bookmarkedArticles.keys),
            highlightIds: Array(bookmarkedHighlights.keys)
        )
        
        if let encoded = try? JSONEncoder().encode(bookmarkIds) {
            UserDefaults.standard.set(encoded, forKey: "highlighter.bookmarks.ids")
        }
    }
    
    private func loadFromLocalStorage() {
        // Don't clear bookmarks here - they will be populated from the network
        // The local storage is just for offline reference of bookmark IDs
        guard let data = UserDefaults.standard.data(forKey: "highlighter.bookmarks.ids"),
              let bookmarkIds = try? JSONDecoder().decode(BookmarkIds.self, from: data) else {
            return
        }
        
        // Store the IDs for reference while we fetch from network
        // The actual bookmark objects will be populated by loadBookmarks()
        self.cachedBookmarkIds = bookmarkIds
    }
    
    // MARK: - Helpers
    
    private func findBookmarkEventId(for articleId: String) -> String? {
        return bookmarkEventIds[articleId]
    }
    
    private func findHighlightBookmarkEventId(for highlightId: String) -> String? {
        return bookmarkEventIds[highlightId]
    }
}

// MARK: - Supporting Types

private struct BookmarkIds: Codable {
    let articleIds: [String]
    let highlightIds: [String]
}


enum BookmarkError: LocalizedError {
    case notConfigured
    case publishFailed
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Bookmark service not configured"
        case .publishFailed:
            return "Failed to publish bookmark"
        }
    }
}