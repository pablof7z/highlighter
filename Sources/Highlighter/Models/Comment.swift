import Foundation
import NDKSwift
import NDKSwiftUI

struct Comment: Identifiable, Equatable {
    let id: String
    let event: NDKEvent
    let author: String
    let content: String
    let createdAt: Date
    let highlightId: String
    let replyToId: String?
    var likes: Int
    var isLiked: Bool
    
    init(from event: NDKEvent) throws {
        self.id = event.id
        self.event = event
        self.content = event.content
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
        
        // Extract highlight ID from tags
        guard let highlightTag = event.tags.first(where: { $0.first == "e" && $0.contains("root") }),
              let highlightId = highlightTag[safe: 1] else {
            throw CommentError.invalidHighlightReference
        }
        self.highlightId = highlightId
        
        // Extract reply ID if this is a reply
        self.replyToId = event.tags.first(where: { $0.first == "e" && $0.contains("reply") })?[safe: 1]
        
        // Initialize engagement metrics (would be loaded separately)
        self.likes = 0
        self.isLiked = false
    }
    
    var isReply: Bool {
        replyToId != nil
    }
    
    var formattedTime: String {
        // Return a simple formatted string for now
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: createdAt)
    }
}

enum CommentError: Error {
    case notConfigured
    case notAuthor
    case invalidHighlightReference
}

