import SwiftUI
import NDKSwift

struct HighlightsFeedView: View {
    @EnvironmentObject var appState: AppState
    @State private var highlights: [HighlightEvent] = []
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    // Stream task reference
    @State private var streamTask: Task<Void, Never>?
    @State private var selectedHighlight: HighlightEvent?
    @State private var showHighlightDetail = false
    @State private var showCommentSheet = false
    @State private var hapticPrepared = false
    @State private var selectedUserPubkey: String?
    @State private var showUserProfile = false
    
    // Author cache
    @State private var authorProfiles: [String: NDKUserProfile] = [:]
    
    // Article cache for highlights from articles
    @State private var articleCache: [String: Article] = [:]
    @State private var articleImages: [String: UIImage] = [:]
    
    // Comment counts cache
    @State private var commentCounts: [String: Int] = [:]
    
    // Animation states
    @State private var backgroundAnimation = false
    @State private var pulseAnimation = false
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced animated background
                UnifiedGradientBackground(style: .immersive)
                
                if highlights.isEmpty {
                    EmptyHighlightsView()
                        .transition(.scale.combined(with: .opacity)
                } else {
                    // Wrap in ScrollView for pull-to-refresh
                    ScrollView(.vertical, showsIndicators: false) {
                        // Enhanced Highlights Stack with gestures
                        ZStack {
                            ForEach(Array(highlights.enumerated()), id: \.element.id) { index, highlight in
                                if index >= currentIndex - 1 && index <= currentIndex + 1 {
                                    HighlightFeedItemView(
                                    highlight: highlight,
                                    author: authorProfiles[highlight.author],
                                    article: articleForHighlight(highlight),
                                    articleImage: articleImageForHighlight(highlight),
                                    onAuthorTap: { 
                                        impactGenerator.impactOccurred()
                                        showProfile(for: highlight.author) 
                                    },
                                    onZap: { 
                                        impactGenerator.impactOccurred(intensity: 0.7)
                                        zapHighlight(highlight) 
                                    },
                                    onShare: { 
                                        selectionGenerator.selectionChanged()
                                        shareHighlight(highlight) 
                                    },
                                    onComment: { 
                                        selectedHighlight = highlight
                                        showCommentSheet = true
                                    },
                                    commentCount: commentCounts[highlight.id] ?? 0,
                                    onDoubleTap: {
                                        likeHighlight(highlight)
                                    },
                                    onRepost: {
                                        await repostHighlight(highlight)
                                    }
                                )
                                .scaleEffect(index == currentIndex ? 1 : 0.95)
                                .opacity(index == currentIndex ? 1 : 0)
                                .offset(y: CGFloat(index - currentIndex) * geometry.size.height + dragOffset.height)
                                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                                .zIndex(index == currentIndex ? 1 : 0)
                            }
                        }
                    }
                    .gesture(createDragGesture()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .refreshable {
                    await refreshFeed()
                }
                
                // Progress indicator - moved outside ScrollView
                if !highlights.isEmpty && highlights.count > 1 {
                    VStack {
                        HighlightProgressIndicator(
                            currentIndex: currentIndex,
                            total: highlights.count
                        )
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity)
                    .allowsHitTesting(false)
                }
            }
            }
        }
        .onAppear {
            prepareHaptics()
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                backgroundAnimation = true
            }
            // Start streaming immediately
            streamHighlights()
        }
        .onDisappear {
            streamTask?.cancel()
        }
        .sheet(isPresented: $showCommentSheet) {
            if let highlight = selectedHighlight {
                CommentSheetView(highlight: highlight)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showUserProfile) {
            if let pubkey = selectedUserPubkey {
                NavigationStack {
                    UserProfileView(pubkey: pubkey)
                }
            }
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            if oldValue != newValue {
                selectionGenerator.selectionChanged()
            }
        }
    }
    
    private func streamHighlights() {
        guard let ndk = appState.ndk else { return }
        
        streamTask?.cancel()
        streamTask = Task {
            let filter = NDKFilter(
                kinds: [9802],
                limit: 50
            )
            
            // Stream highlights as they arrive
            let dataSource = await ndk.outbox.observe(
                filter: filter,
                maxAge: 300, // Use 5 minute cache
                cachePolicy: .cacheWithNetwork
            )
            
            // Process each highlight as it arrives - no waiting!
            for await event in dataSource.events {
                if let highlightEvent = try? HighlightEvent(from: event) {
                    await MainActor.run {
                        // Add if not already present
                        if !highlights.contains(where: { $0.id == highlightEvent.id }) {
                            highlights.append(highlightEvent)
                            highlights.sort { $0.createdAt > $1.createdAt }
                        }
                    }
                    
                    // Load author profile for this highlight
                    Task {
                        await loadAuthorProfile(for: highlightEvent.author)
                    }
                    
                    // Load referenced article if any
                    if highlightEvent.referencedEvent != nil {
                        Task {
                            await loadReferencedArticleForHighlight(highlightEvent)
                        }
                    }
                    
                    // Load comment count
                    Task {
                        await loadCommentCount(for: highlightEvent.id)
                    }
                }
            }
        }
    }
    
    private func loadAuthorProfile(for author: String) async {
        guard let ndk = appState.ndk else { return }
        
        // Don't reload if we already have it
        if authorProfiles[author] != nil { return }
        
        for await profile in await ndk.profileManager.observe(for: author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.authorProfiles[author] = profile
            }
            break
        }
    }
    
    private func loadReferencedArticleForHighlight(_ highlight: HighlightEvent) async {
        guard let ndk = appState.ndk,
              let ref = highlight.referencedEvent,
              ref.contains(":") else { return }
        
        let parts = ref.split(separator: ":")
        guard parts.count >= 3,
              let kind = Int(parts[0]),
              kind == 30023 else { return }
        
        let author = String(parts[1])
        let identifier = parts[2...].joined(separator: ":")
        
        let filter = NDKFilter(
            authors: [author],
            kinds: [30023],
            limit: 1,
            tags: ["d": [String(identifier)]]
        )
        
        let dataSource = await ndk.outbox.observe(filter: filter, maxAge: 3600)
        
        for await event in dataSource.events {
            if let article = try? Article(from: event) {
                await MainActor.run {
                    self.articleCache[ref] = article
                }
                
                // Load article image if available
                if let imageUrl = article.image,
                   let url = URL(string: imageUrl) {
                    await loadArticleImage(url: url, for: ref)
                }
                break
            }
        }
    }
    
    private func refreshFeed() async {
        // Haptic feedback for pull-to-refresh
        await MainActor.run {
            HapticManager.shared.impact(.medium)
        }
        
        // Clear existing data to show fresh content
        await MainActor.run {
            highlights.removeAll()
            authorProfiles.removeAll()
            articleCache.removeAll()
            articleImages.removeAll()
            commentCounts.removeAll()
            currentIndex = 0
        }
        
        // Cancel existing stream and restart
        streamTask?.cancel()
        streamHighlights()
    }
    
    private func showProfile(for pubkey: String) {
        selectedUserPubkey = pubkey
        showUserProfile = true
        HapticManager.shared.impact(.light)
    }
    
    private func zapHighlight(_ highlight: HighlightEvent) {
        Task {
            do {
                _ = try await appState.lightningService.sendSmartZap(
                    amount: 1000, // Default 1000 sats
                    to: highlight,
                    comment: nil
                )
                HapticManager.shared.impact(.medium)
            } catch {
                // Handle zap error
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func shareHighlight(_ highlight: HighlightEvent) {
        let shareText = """
        "\(highlight.content)"
        
        — Highlighted on Nostr
        nostr:\(highlight.id)
        """
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
        
        HapticManager.shared.impact(.light)
    }
    
    private func commentOnHighlight(_ highlight: HighlightEvent) {
        selectedHighlight = highlight
        showCommentSheet = true
        HapticManager.shared.impact(.light)
    }
    
    private func loadReferencedArticles(for highlights: [HighlightEvent]) async {
        guard let ndk = appState.ndk else { return }
        
        // Collect all referenced events that look like article references
        let articleReferences = highlights.compactMap { highlight -> String? in
            guard let ref = highlight.referencedEvent else { return nil }
            // Check if it's an article reference (contains ":" for replaceable events)
            return ref.contains(":") ? ref : nil
        }
        
        guard !articleReferences.isEmpty else { return }
        
        // Parse article references and create filters
        for reference in Set(articleReferences) {
            let parts = reference.split(separator: ":")
            guard parts.count >= 3,
                  let kind = Int(parts[0]),
                  kind == 30023 else { continue }
            
            let author = String(parts[1])
            let identifier = parts[2...].joined(separator: ":")
            
            // Create filter for this specific article
            let filter = NDKFilter(
                authors: [author],
                kinds: [30023],
                limit: 1,
                tags: ["d": [String(identifier)]]
            )
            
            // Fetch the article
            let dataSource = await ndk.outbox.observe(filter: filter, maxAge: 3600, cachePolicy: .cacheWithNetwork)
            
            for await event in dataSource.events {
                if let article = try? Article(from: event) {
                    await MainActor.run {
                        self.articleCache[reference] = article
                    }
                    
                    // Load article image if available
                    if let imageUrl = article.image,
                       let url = URL(string: imageUrl) {
                        await loadArticleImage(url: url, for: reference)
                    }
                    break
                }
            }
        }
    }
    
    private func loadArticleImage(url: URL, for reference: String) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.articleImages[reference] = image
                }
            }
        } catch {
        }
    }
    
    private func articleForHighlight(_ highlight: HighlightEvent) -> Article? {
        guard let ref = highlight.referencedEvent else { return nil }
        return articleCache[ref]
    }
    
    private func articleImageForHighlight(_ highlight: HighlightEvent) -> UIImage? {
        guard let ref = highlight.referencedEvent else { return nil }
        return articleImages[ref]
    }
    
    private func loadCommentCount(for highlightId: String) async {
        guard let ndk = appState.ndk else { return }
        
        // Create filter for replies to this highlight (kind 1 events that tag this event)
        let filter = NDKFilter(
            kinds: [1], // Kind 1 = text note/comment
            limit: 50,
            tags: ["e": [highlightId]]
        )
        
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 300, // 5 minute cache
            cachePolicy: .cacheWithNetwork
        )
        
        var count = 0
        for await _ in dataSource.events {
            count += 1
        }
        
        await MainActor.run {
            self.commentCounts[highlightId] = count
        }
    }
}

// MARK: - Feed Item View
struct HighlightFeedItemView: View {
    let highlight: HighlightEvent
    let author: NDKUserProfile?
    let article: Article?
    let articleImage: UIImage?
    let onAuthorTap: () -> Void
    let onZap: () -> Void
    let onShare: () -> Void
    let onComment: () -> Void
    let commentCount: Int
    let onDoubleTap: () -> Void
    let onRepost: () async -> Void
    
    @State private var isLiked = false
    @State private var showingActions = false
    @State private var showHeartAnimation = false
    @State private var likeScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Layer - Fullscreen image with overlay
                if let articleImage = articleImage {
                    // Article image background with blur
                    Image(uiImage: articleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .blur(radius: 20) // Gaussian blur
                        .opacity(0.4) // Standardized opacity (0.3-0.5)
                } else {
                    // Design system gradient fallback
                    LinearGradient(
                        colors: [
                            Color.ds.primary,      // Purple from design system
                            Color.ds.primaryLight, // Light purple
                            Color.ds.secondary     // Orange from design system
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Dark overlay for text contrast - increased to 0.5
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                // Main Content Layout
                VStack {
                    // Header Area - Source info capsule (top-left)
                    HStack {
                        HStack(spacing: 4) {
                            Text(sourceText)
                                .font(.ds.footnote).fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8)
                            Text("·")
                                .font(.ds.footnote).fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8)
                            Text(relativeTime(from: highlight.createdAt)
                                .font(.ds.footnote).fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                        .padding(.leading, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Main Quote Block (centered vertically)
                    Text(highlight.content)
                        .font(.ds.bodyMedium, design: .serif)
                        .foregroundColor(.white)
                        .lineSpacing(10)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                    
                    // Bottom User Info (bottom-left)
                    HStack {
                        HStack(spacing: 10) {
                            // Small avatar or placeholder
                            Circle()
                                .fill(Color.white.opacity(0.2)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(authorInitial)
                                        .font(.ds.callout).fontWeight(.medium)
                                        .foregroundColor(.white)
                                )
                            
                            Text(authorName)
                                .font(.ds.footnote).fontWeight(.regular)
                                .foregroundColor(.white)
                            
                            // Follow button only shown if not already following
                            // (Removed for now as it needs proper follow state management)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                // Action buttons overlay (positioned absolutely)
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // Actions Stack (bottom-right, vertical)
                        VStack(spacing: 16) {
                            // Like
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isLiked.toggle()
                                }
                                HapticManager.shared.impact(.light)
                            }) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black.opacity(0.3)
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                            .font(.ds.title3)
                                            .foregroundColor(isLiked ? .red : .white)
                                            .scaleEffect(isLiked ? 1.1 : 1.0)
                                    }
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                }
                            }
                            
                            // Comment
                            Button(action: onComment) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black.opacity(0.3)
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: "message")
                                            .font(.ds.headline)
                                            .foregroundColor(.white)
                                    }
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                    
                                    if commentCount > 0 {
                                        Text("\(commentCount)")
                                            .font(.ds.caption2)
                                            .foregroundColor(.white.opacity(0.8)
                                    }
                                }
                            }
                            
                            // Repost
                            Button(action: {
                                Task {
                                    await onRepost()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.3)
                                        .frame(width: 42, height: 42)
                                    
                                    Image(systemName: "arrow.2.squarepath")
                                        .font(.ds.headline)
                                        .foregroundColor(.white)
                                }
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                            }
                            
                            // Share
                            Button(action: onShare) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.3)
                                        .frame(width: 42, height: 42)
                                    
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.ds.headline)
                                        .foregroundColor(.white)
                                }
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 80) // Extra padding to position above user info
                    }
                }
                
                // Double tap heart animation
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.ds.caption0)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(likeScale)
                        .opacity(showHeartAnimation ? 0 : 1)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .allowsHitTesting(false)
                }
            }
        }
        .ignoresSafeArea()
        .onTapGesture(count: 2) {
            onDoubleTap()
            triggerLikeAnimation()
        }
    }
    
    private func triggerLikeAnimation() {
        withAnimation(.easeOut(duration: 0.1)) {
            likeScale = 1.3
            showHeartAnimation = true
            isLiked = true
        }
        
        withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
            likeScale = 0.8
        }
        
        withAnimation(.easeOut(duration: 0.2).delay(0.4)) {
            showHeartAnimation = false
            likeScale = 1.0
        }
    }
    
    // Computed properties for cleaner code
    private var sourceText: String {
        if let article = article {
            return article.title.count > 30 ? String(article.title.prefix(27)) + "..." : article.title
        } else if let url = highlight.url, let host = URL(string: url)?.host {
            return host.replacingOccurrences(of: "www.", with: "")
        } else {
            return "Highlight"
        }
    }
    
    private var authorName: String {
        if let name = author?.name ?? author?.displayName {
            return name.count > 20 ? String(name.prefix(17)) + "..." : name
        } else {
            return String(highlight.author.prefix(8)
        }
    }
    
    private var authorInitial: String {
        (author?.name ?? author?.displayName ?? "U").prefix(1).uppercased()
    }
    
    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date()
    }
}
struct HighlightProgressIndicator: View {
    let currentIndex: Int
    let total: Int
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.3)
                    .frame(height: 3)
                    .scaleEffect(x: index == currentIndex ? animatedProgress : 1, y: 1, anchor: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .onAppear {
            withAnimation(.linear(duration: 5)) {
                animatedProgress = 1
            }
        }
        .onChange(of: currentIndex) { _, _ in
            animatedProgress = 0
            withAnimation(.linear(duration: 5)) {
                animatedProgress = 1
            }
        }
    }
}

struct CommentSheetView: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var commentText = ""
    @FocusState private var isCommentFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Highlight preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Replying to highlight")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(highlight.content)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(3)
                        .padding()
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Comment input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your comment")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal)
                    
                    TextEditor(text: $commentText)
                        .padding(8)
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(12)
                        .frame(minHeight: 100)
                        .focused($isCommentFieldFocused)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Add Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        Task {
                            await postComment()
                        }
                    }
                    .disabled(commentText.isEmpty)
                }
            }
        }
        .onAppear {
            isCommentFieldFocused = true
        }
    }
    
    private func postComment() async {
        guard !commentText.isEmpty else { return }
        
        do {
            try await appState.commentService.postComment(
                on: highlight.id,
                content: commentText
            )
            dismiss()
        } catch {
        }
    }
}

// MARK: - Extensions

extension HighlightsFeedView {
    private func prepareHaptics() {
        impactGenerator.prepare()
        selectionGenerator.prepare()
        hapticPrepared = true
    }
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                let verticalThreshold: CGFloat = 150
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if abs(value.translation.height) > verticalThreshold {
                        // Vertical swipe - dismiss or refresh
                        if value.translation.height > 0 {
                            // Swipe down - could trigger refresh
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right - previous
                        if currentIndex > 0 {
                            currentIndex -= 1
                        }
                    } else if value.translation.width < -threshold {
                        // Swipe left - next
                        if currentIndex < highlights.count - 1 {
                            currentIndex += 1
                        }
                    }
                    
                    dragOffset = .zero
                    isDragging = false
                }
            }
    }
    
    private func likeHighlight(_ highlight: HighlightEvent) {
        impactGenerator.impactOccurred()
        
        Task {
            do {
                // Create a reaction event (kind: 7)
                try await appState.engagementService.react(
                    to: highlight.id,
                    reaction: "+"  // "+" is a like/upvote
                )
            } catch {
                // Handle reaction error
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func repostHighlight(_ highlight: HighlightEvent) async {
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner else { return }
        
        do {
            // Create a repost event (kind: 6)
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(6) // Repost
                .content(highlight.id)
                .tags([
                    ["e", highlight.id, "", "mention"],
                    ["p", highlight.author, "", "mention"]
                ])
                .build(signer: signer)
            
            // Publish the repost
            _ = try await ndk.publish(event)
            
            await MainActor.run {
                HapticManager.shared.notification(.success)
            }
        } catch {
            await MainActor.run {
                HapticManager.shared.notification(.error)
            }
        }
    }
}

#Preview {
    HighlightsFeedView()
        .environmentObject(AppState())
}