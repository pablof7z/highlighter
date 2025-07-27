import Foundation
import NDKSwift

// NIP-23: Long-form Content
struct Article: Identifiable, Equatable {
    let id: String
    let author: String
    let createdAt: Date
    let title: String
    let summary: String?
    let content: String
    let image: String?
    let blurhash: String?
    let publishedAt: Date?
    let tags: [[String]]
    let event: NDKEvent
    
    init(from event: NDKEvent) throws {
        guard event.kind == 30023 else {
            throw ArticleError.invalidKind
        }
        
        self.id = event.id
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
        self.event = event
        self.tags = event.tags
        
        // Extract title from "title" tag
        self.title = event.tags.first(where: { $0.first == "title" })?[safe: 1] ?? "Untitled"
        
        // Extract summary from "summary" tag
        self.summary = event.tags.first(where: { $0.first == "summary" })?[safe: 1]
        
        // Extract image from "image" tag
        self.image = event.tags.first(where: { $0.first == "image" })?[safe: 1]
        
        // Extract blurhash from "blurhash" tag
        self.blurhash = event.tags.first(where: { $0.first == "blurhash" })?[safe: 1]
        
        // Extract published_at from tag
        if let publishedAtString = event.tags.first(where: { $0.first == "published_at" })?[safe: 1],
           let publishedAtTimestamp = Int64(publishedAtString) {
            self.publishedAt = Date(timeIntervalSince1970: TimeInterval(publishedAtTimestamp))
        } else {
            self.publishedAt = nil
        }
        
        // Content is the main event content
        self.content = event.content
    }
    
    var identifier: String? {
        // d tag value for replaceable events
        event.tags.first(where: { $0.first == "d" })?[safe: 1]
    }
    
    var hashtags: [String] {
        event.tags
            .filter { $0.first == "t" }
            .compactMap { $0[safe: 1] }
    }
    
    var references: [String] {
        event.tags
            .filter { $0.first == "a" || $0.first == "e" }
            .compactMap { $0[safe: 1] }
    }
    
    var estimatedReadingTime: Int {
        ArticleTimeEstimator.estimateReadingTime(for: content) ?? 1
    }
    
    // Convenience initializer for testing and UI previews
    init(
        id: String,
        identifier: String,
        title: String,
        summary: String?,
        content: String,
        author: String,
        publishedAt: Date?,
        image: String?,
        hashtags: [String],
        createdAt: Timestamp
    ) {
        self.id = id
        self.author = author
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAt))
        self.title = title
        self.summary = summary
        self.content = content
        self.image = image
        self.blurhash = nil
        self.publishedAt = publishedAt
        self.tags = []
        
        // Create a mock event for the convenience init
        var tags: [[String]] = [
            ["d", identifier],
            ["title", title]
        ]
        
        if let summary = summary {
            tags.append(["summary", summary])
        }
        
        if let image = image {
            tags.append(["image", image])
        }
        
        for hashtag in hashtags {
            tags.append(["t", hashtag])
        }
        
        // Create the event with all required parameters
        let event = NDKEvent(
            id: id,
            pubkey: author,
            createdAt: createdAt,
            kind: 30023,
            tags: tags,
            content: content,
            sig: "" // Empty signature for mock events
        )
        self.event = event
    }
}

enum ArticleError: Error {
    case invalidKind
    case missingRequiredFields
}
