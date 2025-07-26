import SwiftUI
import NDKSwift

struct ImmersiveHighlightDetailView: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // State
    @State private var author: NDKUserProfile?
    @State private var scrollOffset: CGFloat = 0
    @State private var showShareSheet = false
    @State private var showComments = false
    @State private var isBookmarked = false
    @State private var hasZapped = false
    @State private var engagementMetrics = EngagementService.EngagementMetrics()
    @State private var relatedHighlights: [HighlightEvent] = []
    
    // Animation states
    @State private var contentAppeared = false
    @State private var headerScale: CGFloat = 1.0
    @State private var glowAnimation = false
    @State private var floatingElementsAnimation = false
    @State private var reactionAnimation = false
    @State private var pulseAnimation = false
    
    // Gesture states
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                animatedBackground
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Parallax header
                            parallaxHeader
                                .offset(y: scrollOffset > 0 ? -scrollOffset * 0.8 : 0)
                                .scaleEffect(scrollOffset > 0 ? 1 + scrollOffset / 500 : 1)
                                .opacity(1 - (scrollOffset / 200))
                            
                            // Main content
                            mainContent
                                .offset(y: dragOffset.height)
                                .scaleEffect(isDragging ? 0.95 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragging)
                        }
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }
                
                // Floating action buttons
                floatingActionButtons
                    .opacity(contentAppeared ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: contentAppeared)
                
                // Custom navigation bar
                customNavigationBar
            }
            .navigationBarHidden(true)
            .gesture(dragGesture)
        }
        .task {
            await loadData()
            startAnimations()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [highlight.content])
        }
        .sheet(isPresented: $showComments) {
            CommentsSheetView(highlightId: highlight.id)
        }
    }
    
    // MARK: - Background
    
    private var animatedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.background,
                    DesignSystem.Colors.primary.opacity(0.05),
                    DesignSystem.Colors.secondary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating orbs
            GeometryReader { geometry in
                ForEach(0..<5) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.15),
                                    DesignSystem.Colors.primary.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                        .offset(
                            x: floatingOffset(index: index, width: geometry.size.width).x,
                            y: floatingOffset(index: index, width: geometry.size.width).y
                        )
                        .opacity(floatingElementsAnimation ? 0.8 : 0.3)
                        .animation(
                            .easeInOut(duration: Double.random(in: 15...25))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: floatingElementsAnimation
                        )
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Parallax Header
    
    private var parallaxHeader: some View {
        ZStack(alignment: .bottom) {
            // Background image or gradient
            if let imageUrl = highlight.url {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()
                            .overlay(headerOverlay)
                    default:
                        headerGradient
                    }
                }
            } else {
                headerGradient
            }
            
            // Content overlay
            VStack(spacing: DesignSystem.Spacing.large) {
                Spacer()
                
                // Author info
                HStack(spacing: DesignSystem.Spacing.medium) {
                    EnhancedAsyncProfileImage(pubkey: highlight.author, size: 60)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 3)
                        )
                        .shadow(radius: 10)
                        .scaleEffect(headerScale)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(author?.displayName ?? PubkeyFormatter.formatCompact(highlight.author))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Follow button
                    FollowButton(pubkey: highlight.author)
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.bottom, DesignSystem.Spacing.large)
            }
        }
        .frame(height: 400)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 40,
                bottomTrailingRadius: 40
            )
        )
        .shadow(radius: 20)
    }
    
    private var headerGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary,
                    DesignSystem.Colors.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated pattern
            GeometryReader { geometry in
                ForEach(0..<20) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 2)
                        .opacity(glowAnimation ? 0.8 : 0.3)
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: glowAnimation
                        )
                }
            }
        }
        .frame(height: 400)
        .overlay(headerOverlay)
    }
    
    private var headerOverlay: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0),
                Color.black.opacity(0.3),
                Color.black.opacity(0.6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Quote card with glass morphism
            quoteCard
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, -30) // Overlap with header
                .zIndex(1)
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 50)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: contentAppeared)
            
            // Engagement metrics
            engagementMetricsView
                .padding(.horizontal, DesignSystem.Spacing.large)
                .opacity(contentAppeared ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: contentAppeared)
            
            // Context section
            if let context = highlight.context {
                contextSection(context: context)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .opacity(contentAppeared ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: contentAppeared)
            }
            
            // Author's note
            if let comment = highlight.comment {
                authorNoteSection(comment: comment)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .opacity(contentAppeared ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: contentAppeared)
            }
            
            // Related highlights
            relatedHighlightsSection
                .opacity(contentAppeared ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: contentAppeared)
            
            // Spacer for floating buttons
            Color.clear.frame(height: 100)
        }
        .padding(.bottom, DesignSystem.Spacing.huge)
    }
    
    // MARK: - Quote Card
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            // Opening quote mark
            Text("\u{201C}")
                .font(.system(size: 60, weight: .black, design: .serif))
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))
                .offset(x: -10, y: 20)
            
            // Highlighted text with selection effect
            Text(highlight.content)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(DesignSystem.Colors.text)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.highlightSubtle.opacity(0.2))
                        .padding(.horizontal, -8)
                )
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: pulseAnimation
                )
            
            // Closing quote mark
            HStack {
                Spacer()
                Text("\u{201D}")
                    .font(.system(size: 60, weight: .black, design: .serif))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))
                    .offset(x: 10, y: -20)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(glassMorphismBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 20, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var glassMorphismBackground: some View {
        ZStack {
            // Base blur
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.05),
                    DesignSystem.Colors.secondary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Engagement Metrics
    
    private var engagementMetricsView: some View {
        HStack(spacing: 0) {
            MetricView(
                icon: "heart.fill",
                value: engagementMetrics.likes,
                color: .red,
                label: "Likes"
            )
            
            Spacer()
            
            MetricView(
                icon: "bubble.right.fill",
                value: engagementMetrics.comments,
                color: .blue,
                label: "Comments"
            )
            
            Spacer()
            
            MetricView(
                icon: "arrow.2.squarepath",
                value: engagementMetrics.reposts,
                color: .green,
                label: "Reposts"
            )
            
            Spacer()
            
            MetricView(
                icon: "bolt.fill",
                value: engagementMetrics.zaps,
                color: .orange,
                label: "Zaps"
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignSystem.Colors.surfaceSecondary)
        )
    }
    
    // MARK: - Context Section
    
    private func contextSection(context: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Label("Context", systemImage: "text.alignleft")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(context)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DesignSystem.Colors.surface)
        )
    }
    
    // MARK: - Author Note Section
    
    private func authorNoteSection(comment: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                EnhancedAsyncProfileImage(pubkey: highlight.author, size: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Author's Note")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(author?.displayName ?? "Author")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
            }
            
            Text(comment)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.text)
                .lineSpacing(4)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.05),
                            DesignSystem.Colors.primary.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Related Highlights
    
    private var relatedHighlightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            Text("Related Highlights")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DesignSystem.Colors.text)
                .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(relatedHighlights, id: \.id) { relatedHighlight in
                        RelatedHighlightCard(highlight: relatedHighlight)
                            .frame(width: 280)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
    }
    
    // MARK: - Floating Action Buttons
    
    private var floatingActionButtons: some View {
        VStack {
            Spacer()
            
            HStack(spacing: DesignSystem.Spacing.large) {
                // Bookmark button
                FloatingActionButton(
                    icon: isBookmarked ? "bookmark.fill" : "bookmark",
                    color: .blue,
                    isActive: isBookmarked,
                    action: toggleBookmark
                )
                
                // Comment button
                FloatingActionButton(
                    icon: "bubble.left.fill",
                    color: .green,
                    badge: engagementMetrics.comments > 0 ? "\(engagementMetrics.comments)" : nil,
                    action: { showComments = true }
                )
                
                // Zap button
                FloatingActionButton(
                    icon: "bolt.fill",
                    color: .orange,
                    isActive: hasZapped,
                    action: zapHighlight
                )
                
                // Share button
                FloatingActionButton(
                    icon: "square.and.arrow.up",
                    color: .purple,
                    action: { showShareSheet = true }
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }
    
    // MARK: - Navigation Bar
    
    private var customNavigationBar: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(scrollOffset < -50 ? DesignSystem.Colors.text : .white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(scrollOffset < -50 ? DesignSystem.Colors.surface : Color.black.opacity(0.3))
                                .shadow(radius: 4)
                        )
                }
                
                Spacer()
                
                if scrollOffset < -100 {
                    Text("Highlight")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                        .transition(.opacity)
                }
                
                Spacer()
                
                Menu {
                    Button(action: {}) {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                    Button(action: {}) {
                        Label("Copy Link", systemImage: "link")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(scrollOffset < -50 ? DesignSystem.Colors.text : .white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(scrollOffset < -50 ? DesignSystem.Colors.surface : Color.black.opacity(0.3))
                                .shadow(radius: 4)
                        )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.top, 50) // Account for status bar
            .background(
                scrollOffset < -50 ?
                    AnyView(
                        DesignSystem.Colors.background
                            .opacity(0.95)
                            .background(.ultraThinMaterial)
                            .ignoresSafeArea()
                    ) :
                    AnyView(Color.clear)
            )
            .animation(.easeInOut(duration: 0.3), value: scrollOffset)
            
            Spacer()
        }
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation
                    isDragging = true
                }
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        dragOffset = .zero
                        isDragging = false
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    
    private func loadData() async {
        guard let ndk = appState.ndk else { return }
        
        // Load author profile
        if let profile = await appState.profileManager.fetchProfile(pubkey: highlight.author) {
            await MainActor.run {
                self.author = profile
            }
        }
        
        // Load engagement metrics
        let metrics = await appState.engagementService.fetchEngagementBatch(for: [highlight.id])
        await MainActor.run {
            self.engagementMetrics = metrics[highlight.id] ?? EngagementService.EngagementMetrics()
        }
        
        // Load related highlights (mock for now)
        await MainActor.run {
            self.relatedHighlights = Array(repeating: highlight, count: 5)
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.6)) {
            contentAppeared = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            headerScale = 1.1
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowAnimation = true
            pulseAnimation = true
        }
        
        floatingElementsAnimation = true
    }
    
    private func floatingOffset(index: Int, width: CGFloat) -> CGPoint {
        let baseX = CGFloat(index) * width / 5
        let baseY = CGFloat(index * 100)
        
        let offsetX = floatingElementsAnimation ? CGFloat.random(in: -50...50) : 0
        let offsetY = floatingElementsAnimation ? CGFloat.random(in: -50...50) : 0
        
        return CGPoint(x: baseX + offsetX, y: baseY + offsetY)
    }
    
    private func toggleBookmark() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isBookmarked.toggle()
        }
        HapticManager.shared.impact(.medium)
        
        Task {
            await appState.bookmarkService.toggleBookmark(for: highlight)
        }
    }
    
    private func zapHighlight() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            hasZapped = true
            reactionAnimation = true
        }
        HapticManager.shared.notification(.success)
        
        // Trigger zap flow
        Task {
            await appState.lightningService.zapEvent(highlight.id, amount: 21)
        }
        
        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            reactionAnimation = false
        }
    }
}

// MARK: - Supporting Views

struct MetricView: View {
    let icon: String
    let value: Int
    let color: Color
    let label: String
    
    @State private var animatedValue: Int = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .scaleEffect(animatedValue > 0 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animatedValue)
            
            Text("\(animatedValue)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.text)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedValue = value
            }
        }
    }
}

struct FloatingActionButton: View {
    let icon: String
    let color: Color
    var isActive: Bool = false
    var badge: String? = nil
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(isActive ? color : DesignSystem.Colors.surface)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: isActive ? 0 : 2)
                    )
                    .shadow(
                        color: isActive ? color.opacity(0.4) : DesignSystem.Shadow.medium.color,
                        radius: isActive ? 15 : DesignSystem.Shadow.medium.radius,
                        y: DesignSystem.Shadow.medium.y
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundColor(isActive ? .white : color)
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.red))
                        .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
            if pressing {
                HapticManager.shared.impact(.light)
            }
        }, perform: {})
    }
}

struct RelatedHighlightCard: View {
    let highlight: HighlightEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(highlight.content)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.text)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                EnhancedAsyncProfileImage(pubkey: highlight.author, size: 24)
                
                Text(PubkeyFormatter.formatCompact(highlight.author))
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Text(RelativeTimeFormatter.shortRelativeTime(from: highlight.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
    }
}

struct FollowButton: View {
    let pubkey: String
    @State private var isFollowing = false
    @State private var isLoading = false
    
    var body: some View {
        Button(action: toggleFollow) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: isFollowing ? "person.fill.checkmark" : "person.fill.badge.plus")
                        .font(.system(size: 14))
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isFollowing ? Color.white.opacity(0.2) : DesignSystem.Colors.primary)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isFollowing ? 0.5 : 0), lineWidth: 1)
                    )
            )
            .shadow(radius: 4)
        }
        .disabled(isLoading)
    }
    
    private func toggleFollow() {
        HapticManager.shared.impact(.light)
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isFollowing.toggle()
                isLoading = false
            }
        }
    }
}

struct CommentsSheetView: View {
    let highlightId: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            CommentsSection(highlightId: highlightId)
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    ImmersiveHighlightDetailView(
        highlight: HighlightEvent(
            id: "1",
            event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 9802, tags: [], content: "", sig: ""),
            content: "The best way to predict the future is to invent it. Innovation comes from seeing connections where others see boundaries.",
            author: "test",
            createdAt: Date(),
            context: "From Alan Kay's famous quote about the nature of innovation and technological progress.",
            url: "https://example.com",
            referencedEvent: nil,
            attributedAuthors: [],
            comment: "This quote perfectly encapsulates the spirit of technological innovation. Kay's insight reminds us that the future isn't something that happens to us—it's something we actively create."
        )
    )
    .environmentObject(AppState())
}