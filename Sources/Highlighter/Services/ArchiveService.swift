import Foundation
import NDKSwift

@MainActor
class ArchiveService: UserListService<Article, HighlightEvent> {
    
    init() {
        super.init(
            listIdentifier: "archive",
            eventKind: 30001,
            localStorageKey: "highlighter.archives"
        )
    }
    
    // MARK: - Convenience Methods
    
    var archivedArticles: [String: Article] {
        articles
    }
    
    var archivedHighlights: [String: HighlightEvent] {
        highlights
    }
    
    func isArticleArchived(_ articleId: String) -> Bool {
        isArticleInList(articleId)
    }
    
    func archiveArticle(_ article: Article) async throws {
        if !isArticleInList(article.id) {
            try await toggleArticle(article)
        }
    }
    
    func unarchiveArticle(_ articleId: String) async throws {
        if let article = articles[articleId] {
            try await toggleArticle(article)
        }
    }
    
    func isHighlightArchived(_ highlightId: String) -> Bool {
        isHighlightInList(highlightId)
    }
    
    func archiveHighlight(_ highlight: HighlightEvent) async throws {
        if !isHighlightInList(highlight.id) {
            try await toggleHighlight(highlight)
        }
    }
    
    func unarchiveHighlight(_ highlightId: String) async throws {
        if let highlight = highlights[highlightId] {
            try await toggleHighlight(highlight)
        }
    }
}

// Legacy error type for compatibility
enum ArchiveError: LocalizedError {
    case notConfigured
    case networkError
    case signingError
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Archive service is not configured"
        case .networkError:
            return "Failed to sync archives"
        case .signingError:
            return "Failed to sign archive event"
        }
    }
}