import Foundation
import NDKSwift

/// NIP-51 Article Curation (kind:30004)
struct ArticleCuration: Identifiable, Equatable, Hashable {
    let id: String
    let event: NDKEvent
    let name: String
    let title: String
    let description: String?
    let image: String?
    let author: String
    let createdAt: Date
    let updatedAt: Date
    let articles: [ArticleReference]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(title)
        hasher.combine(author)
    }
    
    static func == (lhs: ArticleCuration, rhs: ArticleCuration) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.title == rhs.title &&
        lhs.author == rhs.author &&
        lhs.articles == rhs.articles
    }
    
    // For testing/preview
    init(id: String, event: NDKEvent, name: String, title: String, description: String?, image: String?, author: String, createdAt: Date, updatedAt: Date, articles: [ArticleReference]) {
        self.id = id
        self.event = event
        self.name = name
        self.title = title
        self.description = description
        self.image = image
        self.author = author
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.articles = articles
    }
    
    struct ArticleReference: Equatable, Hashable {
        let url: String?
        let eventId: String?
        let eventAddress: String?
        let addedAt: Date
        
        init(from tag: [String]) {
            switch tag.first {
            case "r":
                self.url = tag.count > 1 ? tag[1] : nil
                self.eventId = nil
                self.eventAddress = nil
            case "e":
                self.url = nil
                self.eventId = tag.count > 1 ? tag[1] : nil
                self.eventAddress = nil
            case "a":
                self.url = nil
                self.eventId = nil
                self.eventAddress = tag.count > 1 ? tag[1] : nil
            default:
                self.url = nil
                self.eventId = nil
                self.eventAddress = nil
            }
            
            // Check for timestamp in tag
            if let timestampStr = tag.last,
               let timestamp = Int64(timestampStr),
               tag.count > 2 {
                self.addedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
            } else {
                self.addedAt = Date()
            }
        }
    }
    
    init(from event: NDKEvent) throws {
        guard event.kind == 30004 else {
            throw CurationError.invalidKind
        }
        
        self.id = event.id
        self.event = event
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
        
        // Parse d tag for identifier
        let dTag = event.tags.first { $0.first == "d" }
        guard let name = dTag?.count ?? 0 > 1 ? dTag?[1] : nil else {
            throw CurationError.missingIdentifier
        }
        self.name = name
        
        // Parse other metadata tags
        var title: String?
        var description: String?
        var image: String?
        var updatedAt: Date?
        var articles: [ArticleReference] = []
        
        for tag in event.tags {
            switch tag.first {
            case "title":
                title = tag.count > 1 ? tag[1] : nil
            case "description":
                description = tag.count > 1 ? tag[1] : nil
            case "image":
                image = tag.count > 1 ? tag[1] : nil
            case "updated_at":
                if tag.count > 1,
                   let timestamp = Int64(tag[1]) {
                    updatedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
                }
            case "r", "e", "a":
                articles.append(ArticleReference(from: tag))
            default:
                break
            }
        }
        
        self.title = title ?? name
        self.description = description
        self.image = image
        self.updatedAt = updatedAt ?? createdAt
        self.articles = articles
    }
    
    static func create(
        ndk: NDK,
        name: String,
        title: String,
        description: String? = nil,
        image: String? = nil,
        articles: [(type: ArticleType, value: String)] = [],
        signer: NDKSigner
    ) async throws -> NDKEvent {
        var tags: [[String]] = [
            ["d", name],
            ["title", title]
        ]
        
        if let description = description {
            tags.append(["description", description])
        }
        
        if let image = image {
            tags.append(["image", image])
        }
        
        let timestamp = String(Int64(Date().timeIntervalSince1970))
        
        for article in articles {
            switch article.type {
            case .url:
                tags.append(["r", article.value, timestamp])
            case .event:
                tags.append(["e", article.value, timestamp])
            case .address:
                tags.append(["a", article.value, timestamp])
            }
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(30004)
            .content("")
            .tags(tags)
            .build(signer: signer)
        
        return event
    }
    
    enum ArticleType {
        case url
        case event
        case address
    }
}

enum CurationError: LocalizedError {
    case invalidKind
    case missingIdentifier
    
    var errorDescription: String? {
        switch self {
        case .invalidKind:
            return "Event is not an article curation (kind:30004)"
        case .missingIdentifier:
            return "Missing required 'd' tag identifier"
        }
    }
}
