import Foundation
import NDKSwift

/// NIP-51 Follow Pack (kind:39089)
struct FollowPack: Identifiable, Equatable {
    let id: String
    let event: NDKEvent
    let name: String
    let title: String
    let description: String?
    let image: String?
    let author: String
    let createdAt: Date
    let profiles: [String] // Array of pubkeys
    
    // For testing/preview
    init(id: String, event: NDKEvent, name: String, title: String, description: String?, image: String?, author: String, createdAt: Date, profiles: [String]) {
        self.id = id
        self.event = event
        self.name = name
        self.title = title
        self.description = description
        self.image = image
        self.author = author
        self.createdAt = createdAt
        self.profiles = profiles
    }
    
    init(from event: NDKEvent) throws {
        guard event.kind == 39089 else {
            throw FollowPackError.invalidKind
        }
        
        self.id = event.id
        self.event = event
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt)
        
        // Parse d tag for identifier
        let dTag = event.tags.first { $0.first == "d" }
        guard let name = dTag?.count ?? 0 > 1 ? dTag?[1] : nil else {
            throw FollowPackError.missingIdentifier
        }
        self.name = name
        
        // Parse metadata and profiles
        var title: String?
        var description: String?
        var image: String?
        var profiles: [String] = []
        
        for tag in event.tags {
            switch tag.first {
            case "title":
                title = tag.count > 1 ? tag[1] : nil
            case "description":
                description = tag.count > 1 ? tag[1] : nil
            case "image":
                image = tag.count > 1 ? tag[1] : nil
            case "p":
                if tag.count > 1 {
                    profiles.append(tag[1])
                }
            default:
                break
            }
        }
        
        self.title = title ?? name
        self.description = description
        self.image = image
        self.profiles = profiles
    }
    
    static func create(
        ndk: NDK,
        name: String,
        title: String,
        description: String? = nil,
        image: String? = nil,
        profiles: [String],
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
        
        // Add profile tags
        for profile in profiles {
            tags.append(["p", profile])
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(39089)
            .content("")
            .tags(tags)
            .build(signer: signer)
        
        return event
    }
    
    /// Import a follow pack by adding its profiles to the user's follow list
    func importToFollowList(currentFollows: Set<String>) -> Set<String> {
        var updatedFollows = currentFollows
        for profile in profiles {
            updatedFollows.insert(profile)
        }
        return updatedFollows
    }
}

enum FollowPackError: LocalizedError {
    case invalidKind
    case missingIdentifier
    
    var errorDescription: String? {
        switch self {
        case .invalidKind:
            return "Event is not a follow pack (kind:39089)"
        case .missingIdentifier:
            return "Missing required 'd' tag identifier"
        }
    }
}
