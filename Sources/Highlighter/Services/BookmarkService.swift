import Foundation
import NDKSwift

@MainActor
class BookmarkService: UserListService<Article, HighlightEvent> {
    
    init() {
        super.init(
            listIdentifier: "bookmarks",
            eventKind: 30001,
            localStorageKey: "highlighter.bookmarks"
        )
    }
    
    // MARK: - Convenience Methods
    
    var bookmarkedArticles: [String: Article] {
        articles
    }
    
    var bookmarkedHighlights: [String: HighlightEvent] {
        highlights
    }
    
    func isArticleBookmarked(_ articleId: String) -> Bool {
        isArticleInList(articleId)
    }
    
    func toggleArticleBookmark(_ article: Article) async throws {
        try await toggleArticle(article)
    }
    
    func isHighlightBookmarked(_ highlightId: String) -> Bool {
        isHighlightInList(highlightId)
    }
    
    func toggleHighlightBookmark(_ highlight: HighlightEvent) async throws {
        try await toggleHighlight(highlight)
    }
}

// Legacy error type for compatibility
enum BookmarkError: LocalizedError {
    case notConfigured
    case networkError
    case signingError
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Bookmark service is not configured"
        case .networkError:
            return "Failed to sync bookmarks"
        case .signingError:
            return "Failed to sign bookmark event"
        }
    }
}