import Foundation
import NDKSwift
import Combine

/// Handles all content publishing operations
/// Follows SRP by focusing solely on publishing and content creation
@MainActor
class PublishingService: ObservableObject {
    static let shared = PublishingService()
    // MARK: - Published State
    @Published private(set) var isPublishing = false
    @Published private(set) var lastPublishError: Error?
    
    // MARK: - Private Properties
    private weak var ndk: NDK?
    private var signer: NDKSigner?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Configuration
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
    }
    
    // MARK: - Publishing Methods
    
    /// Publish a new highlight with optimistic updates
    func publishHighlight(_ highlight: HighlightEvent) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            var tags: [[String]] = []
            
            // Add content with context if available
            if let context = highlight.context, !context.isEmpty {
                tags.append(["context", context])
            }
            
            // Add source/URL reference
            if let source = highlight.source {
                tags.append(["r", source])
            }
            
            // Add author attribution from attributed authors
            for author in highlight.attributedAuthors {
                tags.append(["p", author])
            }
            
            // Add alt tag for clients
            let preview = highlight.content.prefix(50)
            tags.append(["alt", "Highlight: '\(preview)...'" ])
            
            // Build event
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(9802) // NIP-84 highlight kind
                .content(highlight.comment ?? highlight.content)
                .tags(tags)
                .build(signer: signer)
            
            // Publish with optimistic updates
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Create and publish a new article curation
    func createCuration(
        name: String,
        title: String,
        description: String?,
        image: String?
    ) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            let event = try await ArticleCuration.create(
                ndk: ndk,
                name: name,
                title: title,
                description: description,
                image: image,
                articles: [],
                signer: signer
            )
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Update an existing curation with new articles
    func updateCuration(
        _ curation: ArticleCuration,
        addingArticle article: Article
    ) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            // Create a new list of articles including the new one
            var articles = curation.articles.map { ref -> (type: ArticleCuration.ArticleType, value: String) in
                if let url = ref.url {
                    return (.url, url)
                } else if let eventId = ref.eventId {
                    return (.event, eventId)
                } else if let eventAddress = ref.eventAddress {
                    return (.address, eventAddress)
                } else {
                    return (.url, "") // Fallback, shouldn't happen
                }
            }
            
            // Add the new article reference
            // If the article has a source URL, use that; otherwise use the event ID
            if let sourceUrl = article.references.first {
                articles.append((.url, sourceUrl))
            } else {
                articles.append((.event, article.id))
            }
            
            // Create updated curation event
            let event = try await ArticleCuration.create(
                ndk: ndk,
                name: curation.name,
                title: curation.title,
                description: curation.description,
                image: curation.image,
                articles: articles,
                signer: signer
            )
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Publish a text note with bookstr tag
    func publishNote(_ content: String, tags: [String] = []) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            var eventTags: [[String]] = []
            
            // Add bookstr tag by default
            eventTags.append(["t", "bookstr"])
            
            // Add additional tags
            for tag in tags {
                eventTags.append(["t", tag])
            }
            
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(1) // Text note
                .content(content)
                .tags(eventTags)
                .build(signer: signer)
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Publish a reaction to an event
    func publishReaction(to eventId: String, content: String = "🤙") async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(7) // Reaction
                .content(content)
                .tags([["e", eventId]])
                .build(signer: signer)
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Delete curations by publishing deletion events
    func deleteCurations(_ curations: [ArticleCuration]) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            // Create deletion tags for each curation
            var deletionTags: [[String]] = []
            
            for curation in curations {
                // Add "a" tag for the curation (kind:pubkey:d-tag format)
                let pubkey = try await signer.pubkey
                deletionTags.append(["a", "\(30004):\(pubkey):\(curation.name)"])
            }
            
            // Build deletion event
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(5) // Deletion event
                .content("Deleted curations")
                .tags(deletionTags)
                .build(signer: signer)
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    // MARK: - State Management
    
    /// Clear the last publish error
    func clearError() {
        lastPublishError = nil
    }
    
    /// Check if service is ready to publish
    var canPublish: Bool {
        return ndk != nil && signer != nil && !isPublishing
    }
    
    /// Update an existing curation
    func updateCuration(_ curation: ArticleCuration) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw AuthError.noSigner
        }
        
        isPublishing = true
        lastPublishError = nil
        
        do {
            // Build updated event with same identifier
            let event = try await ArticleCuration.create(
                ndk: ndk,
                name: curation.name,
                title: curation.title,
                description: curation.description,
                image: curation.image,
                articles: curation.articles.compactMap { ref in
                    if let url = ref.url {
                        return (.url, url)
                    } else if let eventId = ref.eventId {
                        return (.event, eventId)
                    } else if let eventAddress = ref.eventAddress {
                        return (.address, eventAddress)
                    }
                    return nil
                },
                signer: signer
            )
            
            _ = try await ndk.publish(event)
            
        } catch {
            lastPublishError = error
            throw error
        }
        
        isPublishing = false
    }
    
    /// Delete a single curation
    func deleteCuration(_ curation: ArticleCuration) async throws {
        try await deleteCurations([curation])
    }
}