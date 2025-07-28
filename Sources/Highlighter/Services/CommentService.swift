import Foundation
import NDKSwift

@MainActor
class CommentService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var comments: [String: [Comment]] = [:] // Keyed by highlight ID
    @Published private(set) var isLoadingComments: [String: Bool] = [:]
    @Published private(set) var replyingTo: Comment?
    
    // MARK: - Properties
    private var ndk: NDK?
    private var signer: NDKSigner?
    private var activeTasks: [String: Task<Void, Never>] = [:]
    
    // MARK: - Configuration
    
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
    }
    
    // MARK: - Public Methods
    
    /// Load comments for a highlight
    func loadComments(for highlightId: String) async {
        guard let ndk = ndk else { return }
        
        // Mark as loading
        await MainActor.run {
            isLoadingComments[highlightId] = true
        }
        
        // Create filter for comments on this highlight
        let filter = NDKFilter(
            kinds: [1], // Regular text notes
            tags: ["e": [highlightId]]
        )
        
        // Subscribe to comments
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 300, // 5 minute cache
            cachePolicy: .cacheWithNetwork
        )
        
        // Cancel any existing subscription
        activeTasks[highlightId]?.cancel()
        
        // Process comments as they arrive
        let task = Task {
            for await event in dataSource.events {
                if let comment = await self.processCommentEvent(event, highlightId: highlightId) {
                    await MainActor.run {
                        if self.comments[highlightId] == nil {
                            self.comments[highlightId] = []
                        }
                        
                        // Add if not already present
                        if !self.comments[highlightId]!.contains(where: { $0.id == comment.id }) {
                            self.comments[highlightId]!.append(comment)
                            
                            // Sort by timestamp
                            self.comments[highlightId]!.sort { $0.createdAt > $1.createdAt }
                        }
                        
                        // Mark as loaded after first comment
                        self.isLoadingComments[highlightId] = false
                    }
                }
            }
            
            // Mark as loaded when stream ends
            await MainActor.run {
                self.isLoadingComments[highlightId] = false
            }
        }
        
        activeTasks[highlightId] = task
    }
    
    /// Post a comment on a highlight
    func postComment(
        on highlightId: String,
        content: String,
        replyingTo: Comment? = nil
    ) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw CommentError.notConfigured
        }
        
        // Build tags
        var tags: [[String]] = [
            ["e", highlightId, "", "root"] // Reference to the highlight
        ]
        
        // Add reply tag if replying
        if let replyComment = replyingTo {
            tags.append(["e", replyComment.id, "", "reply"])
            tags.append(["p", replyComment.author]) // Mention the author
        }
        
        // Create the comment event
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(1) // Regular text note
            .content(content)
            .tags(tags)
            .build(signer: signer)
        
        // Publish the comment
        _ = try await ndk.publish(event)
        
        // The comment will be received through the subscription and added automatically
        
        // Clear reply target if this was a reply
        if replyingTo != nil {
            await MainActor.run {
                self.replyingTo = nil
            }
        }
        
        HapticManager.shared.notification(.success)
    }
    
    /// Like a comment
    func likeComment(_ comment: Comment) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw CommentError.notConfigured
        }
        
        // Create reaction event (NIP-25)
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(7) // Reaction
            .content("+") // Like emoji
            .tags([
                ["e", comment.id],
                ["p", comment.author]
            ])
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
        
        // Update local state
        await MainActor.run {
            if let highlightComments = self.comments[comment.highlightId],
               let index = highlightComments.firstIndex(where: { $0.id == comment.id }) {
                self.comments[comment.highlightId]![index].likes += 1
                self.comments[comment.highlightId]![index].isLiked = true
            }
        }
        
        HapticManager.shared.impact(.light)
    }
    
    /// Delete a comment (if author)
    func deleteComment(_ comment: Comment) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw CommentError.notConfigured
        }
        
        // Verify the user is the author
        let userPubkey = try await signer.pubkey
        guard comment.author == userPubkey else {
            throw CommentError.notAuthor
        }
        
        // Create deletion event (NIP-09)
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(5) // Deletion
            .content("Deleted comment")
            .tags([["e", comment.id]])
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
        
        // Remove from local state
        await MainActor.run {
            if var highlightComments = self.comments[comment.highlightId] {
                highlightComments.removeAll { $0.id == comment.id }
                self.comments[comment.highlightId] = highlightComments
            }
        }
        
        HapticManager.shared.notification(.success)
    }
    
    /// Get comment count for a highlight
    func getCommentCount(for highlightId: String) -> Int {
        comments[highlightId]?.count ?? 0
    }
    
    /// Set reply target
    func setReplyTarget(_ comment: Comment?) {
        replyingTo = comment
        if comment != nil {
            HapticManager.shared.impact(.light)
        }
    }
    
    /// Clear all subscriptions
    func clearSubscriptions() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func processCommentEvent(_ event: NDKEvent, highlightId: String) async -> Comment? {
        // Filter out deletions and other non-comment events
        guard event.kind == 1 else { return nil }
        
        // Try to create Comment from event
        if var comment = try? Comment(from: event) {
            // Update engagement metrics
            comment.likes = await countReactions(for: event.id)
            comment.isLiked = await checkIfLiked(event.id)
            return comment
        }
        
        return nil
    }
    
    private func countReactions(for eventId: String) async -> Int {
        guard let ndk = ndk else { return 0 }
        
        let filter = NDKFilter(
            kinds: [7], // Reactions
            tags: ["e": [eventId]]
        )
        
        // Use outbox to get reactions
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 60 // 1 minute cache for reactions
        )
        
        var count = 0
        for await event in dataSource.events {
            if event.content == "+" || event.content == "❤️" {
                count += 1
            }
        }
        return count
    }
    
    private func checkIfLiked(_ eventId: String) async -> Bool {
        guard let ndk = ndk, let signer = signer else { return false }
        
        guard let userPubkey = try? await signer.pubkey else { return false }
        
        let filter = NDKFilter(
            authors: [userPubkey],
            kinds: [7], // Reactions
            tags: ["e": [eventId]]
        )
        
        // Use observe with maxAge for one-shot fetch
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 60 // 1 minute cache
        )
        
        for await event in dataSource.events {
            if event.content == "+" || event.content == "❤️" {
                return true
            }
        }
        return false
    }
}

// MARK: - Supporting Types

extension CommentError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Comment service not configured"
        case .notAuthor:
            return "You can only delete your own comments"
        case .invalidHighlightReference:
            return "Invalid highlight reference in comment"
        }
    }
}