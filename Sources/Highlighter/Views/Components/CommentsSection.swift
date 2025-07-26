import SwiftUI
import NDKSwift

struct CommentsSection: View {
    let highlightId: String
    @EnvironmentObject var appState: AppState
    @State private var comments: [CommentEvent] = []
    @State private var isLoading = true
    @State private var newCommentText = ""
    @State private var isPostingComment = false
    @State private var commentAuthors: [String: NDKUserProfile] = [:]
    @State private var showComposer = false
    @State private var animatedCommentIds = Set<String>()
    @State private var replyingTo: CommentEvent?
    @State private var commentReactions: [String: CommentReactions] = [:]
    @State private var currentUserPubkey: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced section header
            CommentsSectionHeader(
                commentsCount: comments.count,
                isLoading: isLoading
            )
            .padding(.horizontal)
            
            // Enhanced comments list with animations
            if comments.isEmpty && !isLoading {
                EmptyCommentsView(onComment: { showComposer = true })
                    .padding(.horizontal)
                    .transition(.asymmetric(
                        insertion: .push(from: .bottom).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            } else {
                CommentsList(
                    comments: comments,
                    commentAuthors: commentAuthors,
                    commentReactions: commentReactions,
                    animatedCommentIds: $animatedCommentIds,
                    onReply: { comment in replyingTo = comment },
                    onReact: handleReaction
                )
            }
            
            // Enhanced comment composer
            VStack(spacing: 12) {
                if let replyingTo = replyingTo {
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("Replying to \(commentAuthors[replyingTo.author]?.displayName ?? "user")")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Spacer()
                        
                        Button(action: { self.replyingTo = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                HStack(spacing: 12) {
                    EnhancedAsyncProfileImage(pubkey: currentUserPubkey, size: 36)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: showComposer ? 2 : 0
                                )
                        )
                        .animation(.spring(response: 0.3), value: showComposer)
                    
                    ZStack(alignment: .trailing) {
                        // Glass morphism background
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: showComposer ? 
                                                [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.secondary.opacity(0.3)] :
                                                [Color.clear, Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        HStack {
                            TextField(
                                replyingTo != nil ? "Write your reply..." : "Add a comment...",
                                text: $newCommentText,
                                axis: .vertical
                            )
                            .font(DesignSystem.Typography.body)
                            .disabled(isPostingComment)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    showComposer = true
                                }
                            }
                            .lineLimit(showComposer ? 5 : 1)
                            
                            if !newCommentText.isEmpty {
                                Button(action: postComment) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 32, height: 32)
                                        
                                        if isPostingComment {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.6)
                                        } else {
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .disabled(isPostingComment || newCommentText.isEmpty)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, showComposer ? 12 : 10)
                    }
                    .frame(height: showComposer ? nil : 44)
                    .animation(.spring(response: 0.3), value: showComposer)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .task {
            await loadComments()
            await loadCurrentUserPubkey()
        }
    }
    
    private func loadComments() async {
        guard let ndk = appState.ndk else { return }
        
        let filter = NDKFilter(
            kinds: [1],
            limit: 50,
            tags: ["e": [highlightId]]
        )
        
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var hasReceivedFirstComment = false
        
        for await event in dataSource.events {
            // Check if this is a reply to the highlight
            let eTags = event.tags.filter { $0.first == "e" }
            let isReplyToHighlight = eTags.contains { tag in
                tag.count > 1 && tag[1] == highlightId
            }
            
            if isReplyToHighlight,
               let comment = try? CommentEvent(from: event) {
                await MainActor.run {
                    if !comments.contains(where: { $0.id == comment.id }) {
                        comments.append(comment)
                        comments.sort { $0.createdAt > $1.createdAt }
                        
                        if !hasReceivedFirstComment {
                            hasReceivedFirstComment = true
                            isLoading = false
                        }
                    }
                }
                
                // Load author profile
                Task {
                    await loadAuthorProfile(for: comment.author)
                }
            }
        }
        
        // Set loading to false after a timeout if no comments found
        if !hasReceivedFirstComment {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func loadAuthorProfile(for pubkey: String) async {
        guard let ndk = appState.ndk else { return }
        
        if commentAuthors[pubkey] != nil { return }
        
        for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.commentAuthors[pubkey] = profile
            }
            break
        }
    }
    
    private func loadCurrentUserPubkey() async {
        if let signer = appState.activeSigner {
            if let pubkey = try? await signer.pubkey {
                await MainActor.run {
                    self.currentUserPubkey = pubkey
                }
            }
        }
    }
    
    private func postComment() {
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner,
              !newCommentText.isEmpty else { return }
        
        isPostingComment = true
        
        Task {
            do {
                // Create comment event using NDKEventBuilder
                let commentEvent = try await NDKEventBuilder(ndk: ndk)
                    .kind(1)
                    .content(newCommentText)
                    .tags([["e", highlightId]])
                    .build(signer: signer)
                
                // Publish
                _ = try await ndk.publish(commentEvent)
                
                await MainActor.run {
                    newCommentText = ""
                    isPostingComment = false
                    showComposer = false
                    replyingTo = nil
                    HapticManager.shared.impact(.medium)
                }
            } catch {
                print("Failed to post comment: \(error)")
                await MainActor.run {
                    isPostingComment = false
                }
            }
        }
    }
}

struct EmptyCommentsView: View {
    let onComment: () -> Void
    @State private var bubbleScale: CGFloat = 1
    @State private var bubbleRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Animated background circles
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .scaleEffect(bubbleScale)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: bubbleScale
                    )
                
                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(bubbleScale * 0.8)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(0.5),
                        value: bubbleScale
                    )
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(bubbleRotation))
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6)
                        .repeatForever(autoreverses: true),
                        value: bubbleRotation
                    )
            }
            
            VStack(spacing: 8) {
                Text("No comments yet")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Be the first to share your thoughts")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Button(action: onComment) {
                Text("Add Comment")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 8, y: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            bubbleScale = 1.1
            bubbleRotation = 5
        }
    }
}

// Enhanced comment row with animations and interactions
struct EnhancedCommentRow: View {
    let comment: CommentEvent
    let author: NDKUserProfile?
    let reactions: CommentReactions
    let isAnimated: Bool
    let onReply: () -> Void
    let onReact: (String) -> Void
    
    @State private var isPressed = false
    @State private var showReactions = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Enhanced author avatar
            EnhancedAsyncProfileImage(pubkey: comment.author, size: 36)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.divider, lineWidth: 0.5)
                )
                .scaleEffect(isAnimated ? 1 : 0.8)
                .opacity(isAnimated ? 1 : 0)
            
            VStack(alignment: .leading, spacing: 8) {
                // Author info with verified badge
                HStack(spacing: 6) {
                    Text(authorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    
                    Text("·")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text(RelativeTimeFormatter.shortRelativeTime(from: comment.createdAt))
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 10)
                
                // Comment content with better typography
                Text(comment.content)
                    .font(.system(size: 15))
                    .foregroundColor(DesignSystem.Colors.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isAnimated ? 1 : 0)
                    .offset(y: isAnimated ? 0 : 10)
                
                // Interactive reaction bar
                HStack(spacing: 16) {
                    ReactionButton(
                        icon: "heart.fill",
                        count: reactions.likes,
                        isActive: reactions.userLiked,
                        activeColor: .red,
                        action: { onReact("like") }
                    )
                    
                    ReactionButton(
                        icon: "bubble.right",
                        count: 0,
                        isActive: false,
                        action: onReply
                    )
                    
                    ReactionButton(
                        icon: "bolt.fill",
                        count: reactions.zaps,
                        isActive: reactions.userZapped,
                        activeColor: DesignSystem.Colors.secondary,
                        action: { onReact("zap") }
                    )
                }
                .padding(.top, 4)
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 10)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0.1,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
                if pressing {
                    HapticManager.shared.impact(.light)
                }
            },
            perform: {}
        )
    }
    
    private var authorName: String {
        author?.displayName ?? author?.name ?? PubkeyFormatter.formatCompact(comment.author)
    }
}

struct ReactionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    var activeColor: Color = DesignSystem.Colors.primary
    let action: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnimating = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? activeColor : DesignSystem.Colors.textSecondary)
                    .scaleEffect(isAnimating ? 1.3 : 1)
                    .rotationEffect(.degrees(isAnimating ? 15 : 0))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isActive ? activeColor : DesignSystem.Colors.textSecondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Comment event model
struct CommentEvent: Identifiable {
    let id: String
    let event: NDKEvent
    let content: String
    let author: String
    let createdAt: Date
    
    init(from event: NDKEvent) throws {
        self.id = event.id
        self.event = event
        self.content = event.content
        self.author = event.pubkey
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(event.createdAt))
    }
}

// Comment reactions model
struct CommentReactions {
    var likes: Int = 0
    var zaps: Int = 0
    var userLiked: Bool = false
    var userZapped: Bool = false
}

// Loading dots animation
struct LoadingDots: View {
    @State private var currentDot = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(currentDot == index ? 1.2 : 0.8)
                    .opacity(currentDot == index ? 1 : 0.5)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever()
            ) {
                currentDot = 2
            }
        }
    }
}

// MARK: - Subcomponents

struct CommentsList: View {
    let comments: [CommentEvent]
    let commentAuthors: [String: NDKUserProfile]
    let commentReactions: [String: CommentReactions]
    @Binding var animatedCommentIds: Set<String>
    let onReply: (CommentEvent) -> Void
    let onReact: (CommentEvent, String) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(comments.indices, id: \.self) { index in
                    CommentRowWrapper(
                        comment: comments[index],
                        author: commentAuthors[comments[index].author],
                        reactions: commentReactions[comments[index].id] ?? CommentReactions(),
                        isAnimated: animatedCommentIds.contains(comments[index].id),
                        index: index,
                        isLast: index == comments.count - 1,
                        animatedCommentIds: $animatedCommentIds,
                        onReply: onReply,
                        onReact: onReact
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// Simplified wrapper to reduce complexity
struct CommentRowWrapper: View {
    let comment: CommentEvent
    let author: NDKUserProfile?
    let reactions: CommentReactions
    let isAnimated: Bool
    let index: Int
    let isLast: Bool
    @Binding var animatedCommentIds: Set<String>
    let onReply: (CommentEvent) -> Void
    let onReact: (CommentEvent, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            EnhancedCommentRow(
                comment: comment,
                author: author,
                reactions: reactions,
                isAnimated: isAnimated,
                onReply: { onReply(comment) },
                onReact: { reaction in onReact(comment, reaction) }
            )
            .id(comment.id)
            .transition(.asymmetric(
                insertion: .push(from: .bottom).combined(with: .opacity),
                removal: .push(from: .top).combined(with: .opacity)
            ))
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05)) {
                    _ = animatedCommentIds.insert(comment.id)
                }
            }
            
            if !isLast {
                Divider()
                    .background(DesignSystem.Colors.divider.opacity(0.3))
                    .padding(.leading, 48)
            }
        }
    }
}

struct CommentsSectionHeader: View {
    let commentsCount: Int
    let isLoading: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: commentsCount)
                
                Text("Comments")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.text)
                
                if commentsCount > 0 {
                    Text("\(commentsCount)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Spacer()
            
            if isLoading {
                LoadingDots()
                    .frame(width: 40, height: 20)
            }
        }
    }
}

// AsyncProfileImage has been replaced with EnhancedAsyncProfileImage

// Extension to handle reactions
extension CommentsSection {
    private func handleReaction(comment: CommentEvent, reaction: String) {
        var reactions = commentReactions[comment.id] ?? CommentReactions()
        
        switch reaction {
        case "like":
            reactions.userLiked.toggle()
            reactions.likes += reactions.userLiked ? 1 : -1
        case "zap":
            reactions.userZapped.toggle()
            reactions.zaps += reactions.userZapped ? 1 : -1
        default:
            break
        }
        
        commentReactions[comment.id] = reactions
        
        // In a real app, this would publish reaction events to Nostr
        HapticManager.shared.impact(.light)
    }
}