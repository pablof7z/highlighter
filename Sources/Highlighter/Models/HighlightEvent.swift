import Foundation
import NDKSwift

/// NIP-84 Highlight Event (kind:9802)
struct HighlightEvent: Identifiable, Equatable {
    let id: String
    let event: NDKEvent
    let content: String
    let author: String
    let createdAt: Date
    
    // NIP-84 specific fields
    let context: String?
    let url: String?
    let referencedEvent: String?
    let attributedAuthors: [String]
    let comment: String?
    
    // Additional fields for publishing
    var source: String? { url }
    var pubkey: String { event.pubkey }
    
    // Convert to NDKEvent for use with ZapButton
    func toNostrEvent() -> NDKEvent {
        return event
    }
    
    // For creating new highlights
    init(content: String, context: String? = nil, source: String? = nil, author: String? = nil, comment: String? = nil) {
        self.id = UUID().uuidString
        self.event = NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 9802, tags: [], content: content, sig: "")
        self.content = content
        self.author = ""
        self.createdAt = Date()
        self.context = context
        self.url = source
        self.referencedEvent = nil
        self.attributedAuthors = author != nil ? [author!] : []
        self.comment = comment
    }
    
    // For testing/preview
    init(id: String, event: NDKEvent, content: String, author: String, createdAt: Date, context: String?, url: String?, referencedEvent: String?, attributedAuthors: [String], comment: String?) {
        self.id = id
        self.event = event
        self.content = content
        self.author = author
        self.createdAt = createdAt
        self.context = context
        self.url = url
        self.referencedEvent = referencedEvent
        self.attributedAuthors = attributedAuthors
        self.comment = comment
    }
    
    init(from event: NDKEvent) throws {
        guard event.kind == 9802 else {
            throw HighlightError.invalidKind
        }
        
        self.id = event.id
        self.event = event
        self.content = event.content
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
        
        // Parse NIP-84 tags
        var context: String?
        var url: String?
        var referencedEvent: String?
        var attributedAuthors: [String] = []
        var comment: String?
        
        for tag in event.tags {
            switch tag.first {
            case "context":
                context = tag.count > 1 ? tag[1] : nil
            case "r":
                url = tag.count > 1 ? tag[1] : nil
            case "e":
                referencedEvent = tag.count > 1 ? tag[1] : nil
            case "a":
                referencedEvent = tag.count > 1 ? tag[1] : nil
            case "p":
                if tag.count > 1 {
                    attributedAuthors.append(tag[1])
                }
            case "comment":
                comment = tag.count > 1 ? tag[1] : nil
            default:
                break
            }
        }
        
        self.context = context
        self.url = url
        self.referencedEvent = referencedEvent
        self.attributedAuthors = attributedAuthors
        self.comment = comment
    }
    
    static func create(
        ndk: NDK,
        content: String,
        context: String? = nil,
        url: String? = nil,
        referencedEvent: String? = nil,
        attributedAuthors: [String] = [],
        comment: String? = nil,
        signer: NDKSigner
    ) async throws -> NDKEvent {
        var tags: [[String]] = []
        
        if let context = context {
            tags.append(["context", context])
        }
        
        if let url = url {
            tags.append(["r", url])
        }
        
        if let referencedEvent = referencedEvent {
            if referencedEvent.contains(":") {
                tags.append(["a", referencedEvent])
            } else {
                tags.append(["e", referencedEvent])
            }
        }
        
        for author in attributedAuthors {
            tags.append(["p", author])
        }
        
        if let comment = comment {
            tags.append(["comment", comment])
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(9802)
            .content(content)
            .tags(tags)
            .build(signer: signer)
        
        return event
    }
}

enum HighlightError: LocalizedError {
    case invalidKind
    case missingRequired
    
    var errorDescription: String? {
        switch self {
        case .invalidKind:
            return "Event is not a highlight (kind:9802)"
        case .missingRequired:
            return "Missing required fields for highlight"
        }
    }
}
