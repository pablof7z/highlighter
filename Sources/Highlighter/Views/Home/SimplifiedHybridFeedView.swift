import SwiftUI
import NDKSwift

// Make NDKEvent conform to Identifiable for SwiftUI usage
extension NDKEvent: @retroactive Identifiable {}

struct SimplifiedHybridFeedView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataManager = HomeDataManager()
    @State private var selectedSection = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var headerOpacity: Double = 1
    @State private var highlightEngagements: [String: EngagementService.EngagementMetrics] = [:]
    @State private var discussionEngagements: [String: EngagementService.EngagementMetrics] = [:]
    @State private var isRefreshing = false
    @State private var refreshProgress: CGFloat = 0
    @State private var showFloatingElements = true
    @State private var contentAppeared = false
    
    // Dynamic gradient colors that shift based on time of day
    private var gradientColors: [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: // Morning - warm orange tones
            return [DesignSystem.Colors.secondary.opacity(0.2), DesignSystem.Colors.secondaryLight.opacity(0.1)]
        case 12..<17: // Afternoon - purple to orange blend
            return [DesignSystem.Colors.primary.opacity(0.15), DesignSystem.Colors.secondary.opacity(0.1)]
        case 17..<21: // Evening - deeper purple tones
            return [DesignSystem.Colors.primary.opacity(0.2), DesignSystem.Colors.primaryDark.opacity(0.15)]
        default: // Night - subtle dark purple
            return [DesignSystem.Colors.primaryDark.opacity(0.15), DesignSystem.Colors.primary.opacity(0.08)]
        }
    }
    
    // MARK: - Engagement Fetching
    private func fetchHighlightEngagements() async {
        let eventIds = dataManager.userHighlights.map { $0.id }
        guard !eventIds.isEmpty else { return }
        
        let engagements = await appState.engagementService.fetchEngagementBatch(for: eventIds)
        await MainActor.run {
            highlightEngagements = engagements
        }
    }
    
    private func fetchDiscussionEngagements() async {
        let eventIds = dataManager.discussions.prefix(10).map { $0.id }
        guard !eventIds.isEmpty else { return }
        
        let engagements = await appState.engagementService.fetchEngagementBatch(for: eventIds)
        await MainActor.run {
            discussionEngagements = engagements
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Animated gradient background with floating elements
                ZStack {
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .opacity(0.3)
                    .animation(.easeInOut(duration: 3), value: gradientColors)
                    
                    // Floating ambient elements
                    if showFloatingElements {
                        FloatingAmbientView()
                            .ignoresSafeArea()
                            .opacity(contentAppeared ? 1 : 0)
                            .animation(.easeIn(duration: 1.5), value: contentAppeared)
                    }
                }
                
                // Custom refresh indicator
                RefreshIndicatorView(progress: refreshProgress, isRefreshing: isRefreshing)
                    .offset(y: -80 + (scrollOffset > 0 ? scrollOffset * 0.5 : 0))
                    .opacity(scrollOffset > 10 ? 1 : 0)
                    .animation(.spring(response: 0.3), value: scrollOffset)
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Parallax header with live indicator
                            headerView
                                .padding(.horizontal, DesignSystem.Spacing.large)
                                .padding(.top, DesignSystem.Spacing.medium)
                                .offset(y: scrollOffset * 0.5)
                                .opacity(headerOpacity)
                                .id("header")
                            
                            
                            VStack(spacing: DesignSystem.Spacing.xxl) {
                                // Recently Highlighted Articles
                                if !dataManager.highlightedArticles.isEmpty {
                                    recentlyHighlightedSection
                                }
                                
                                // Featured Highlights with enhanced carousel
                                if !dataManager.userHighlights.isEmpty {
                                    enhancedCarouselSection(
                                        title: "Featured Highlights",
                                        subtitle: "Top highlights from your network",
                                        items: dataManager.userHighlights,
                                        icon: "sparkle"
                                    ) { highlight in
                                        EnhancedHighlightCard(
                                            highlight: highlight,
                                            engagement: highlightEngagements[highlight.id] ?? EngagementService.EngagementMetrics()
                                        )
                                    }
                                } else {
                                    // Loading state with skeleton UI
                                    carouselLoadingState(title: "Featured Highlights")
                                }
                                
                                // Active Discussions
                                if !dataManager.discussions.isEmpty {
                                    enhancedDiscussionsSection
                                }
                            }
                            .padding(.top, DesignSystem.Spacing.xl)
                        }
                        .padding(.bottom, DesignSystem.Spacing.huge * 2.5)
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
                        withAnimation(.easeOut(duration: 0.2)) {
                            headerOpacity = min(1.0, max(0.0, (50.0 + value) / 50.0))
                        }
                    }
                    .refreshable {
                        HapticManager.shared.impact(.medium)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            isRefreshing = true
                        }
                        await dataManager.refresh()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isRefreshing = false
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            dataManager.appState = appState
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                contentAppeared = true
            }
        }
        .task {
            await dataManager.startStreaming()
        }
        .onChange(of: dataManager.userHighlights) {
            Task {
                await fetchHighlightEngagements()
            }
        }
        .onChange(of: dataManager.discussions) {
            Task {
                await fetchDiscussionEngagements()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Highlighter")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeBasedEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "☀️"
        case 12..<17: return "🌤"
        case 17..<21: return "🌅"
        default: return "🌙"
        }
    }
    
    private func enhancedCarouselSection<Item: Identifiable, Content: View>(
        title: String,
        subtitle: String? = nil,
        items: [Item],
        icon: String? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.ds.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.large) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: 300)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.vertical, DesignSystem.Spacing.micro) // For shadows
            }
        }
    }
    
    private func carouselLoadingState(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.text)
                .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.large) {
                    ForEach(0..<3, id: \.self) { index in
                        SkeletonHighlightCard()
                            .frame(width: 300, height: 200)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.2).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.1),
                                value: dataManager.userHighlights.isEmpty
                            )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
    }
    
    private var recentlyHighlightedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                Text("Recently Highlighted")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Articles you might enjoy")
                    .font(.ds.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(dataManager.highlightedArticles.prefix(5), id: \.article.id) { highlightedArticle in
                        NavigationLink(destination: ArticleView(article: highlightedArticle.article)) {
                            RecentlyHighlightedArticleCard(highlightedArticle: highlightedArticle)
                                .frame(width: 280)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var enhancedDiscussionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("Active Discussions")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(DesignSystem.Colors.text)
                    }
                    
                    Text("\(dataManager.discussions.count) conversations happening now")
                        .font(.ds.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            VStack(spacing: 0) {
                ForEach(dataManager.discussions.prefix(5), id: \.id) { event in
                    EnhancedDiscussionRow(
                        event: event,
                        engagement: discussionEngagements[event.id] ?? EngagementService.EngagementMetrics()
                    )
                    
                    if event.id != dataManager.discussions.prefix(5).last?.id {
                        Divider()
                            .background(DesignSystem.Colors.divider)
                            .padding(.leading, DesignSystem.Spacing.huge + DesignSystem.Spacing.large)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .shadow(color: DesignSystem.Shadow.medium.color, radius: DesignSystem.Shadow.medium.radius, x: DesignSystem.Shadow.medium.x, y: DesignSystem.Shadow.medium.y)
            )
            .padding(.horizontal, DesignSystem.Spacing.large)
        }
    }
}

// MARK: - Enhanced Cards

struct EnhancedHighlightCard: View {
    let highlight: HighlightEvent
    let engagement: EngagementService.EngagementMetrics
    @State private var isPressed = false
    @State private var showingDetail = false
    @State private var isHovered = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.12),
                                DesignSystem.Colors.secondary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Glow effect when hovered
                if isHovered {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.6),
                                    DesignSystem.Colors.secondary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .blur(radius: 4)
                        .opacity(glowAnimation ? 0.8 : 0.4)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowAnimation)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Source info if available
                    if let url = highlight.url {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            Text(ContentFormatter.extractDomain(from: url))
                                .font(.ds.caption)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                    
                    // Quote text with stylish quotes
                    HStack(alignment: .top, spacing: 12) {
                        Text("\"")
                            .font(.system(size: 36, weight: .black, design: .serif))
                            .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))
                            .offset(y: -8)
                        
                        Text(highlight.content)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                        
                        Spacer(minLength: 0)
                    }
                    
                    Spacer()
                    
                    // Footer with interactions
                    HStack {
                        // Time and author
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(PubkeyFormatter.formatForAvatar(highlight.author))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(DesignSystem.Colors.primary)
                                )
                            
                            Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                                .font(.ds.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Interaction buttons
                        HStack(spacing: DesignSystem.Spacing.medium) {
                            InteractionButton(icon: "heart", count: engagement.likes)
                            InteractionButton(icon: "bubble.right", count: engagement.comments)
                            InteractionButton(icon: "bolt.fill", count: engagement.zaps, color: DesignSystem.Colors.secondary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous))
            .shadow(
                color: isHovered ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Shadow.large.color,
                radius: isHovered ? 20 : DesignSystem.Shadow.large.radius,
                x: 0,
                y: isHovered ? 12 : DesignSystem.Shadow.large.y
            )
            .scaleEffect(isPressed ? 0.93 : (isHovered ? 1.02 : 1))
            .rotation3DEffect(
                .degrees(isHovered ? 2 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                HapticManager.shared.impact(.light)
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
            if hovering {
                glowAnimation = true
            }
        }
        .sheet(isPresented: $showingDetail) {
            HighlightDetailView(highlight: highlight)
        }
        .onAppear {
            if isHovered {
                glowAnimation = true
            }
        }
    }
}


struct EnhancedDiscussionRow: View {
    let event: NDKEvent
    let engagement: EngagementService.EngagementMetrics
    @State private var author: NDKUserProfile?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            EnhancedAsyncProfileImage(pubkey: event.pubkey, size: 44)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                HStack {
                    Text(author?.displayName ?? PubkeyFormatter.formatCompact(event.pubkey))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("·")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text(RelativeTimeFormatter.shortRelativeTime(from: event.createdAt))
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Spacer()
                    
                    if Bool.random() {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                Text(event.content)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Engagement row with real metrics
                HStack(spacing: DesignSystem.Spacing.large) {
                    EngagementButton(icon: "bubble.right", count: engagement.comments)
                    EngagementButton(icon: "arrow.2.squarepath", count: engagement.reposts)
                    EngagementButton(icon: "heart", count: engagement.likes)
                    EngagementButton(icon: "bolt.fill", count: engagement.zaps, color: DesignSystem.Colors.secondary)
                }
                .padding(.top, 4)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.base)
    }
}

// MARK: - Supporting Components

struct RecentlyHighlightedArticleCard: View {
    let highlightedArticle: HomeDataManager.HighlightedArticle
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Article thumbnail/gradient
            ZStack(alignment: .bottom) {
                // Background image or gradient
                if let imageUrl = highlightedArticle.article.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                        case .empty, .failure:
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.8),
                                    DesignSystem.Colors.primary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 180)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.8),
                            DesignSystem.Colors.primary.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 180)
                }
                
                // Overlay gradient for readability
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.7)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Article title
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text(highlightedArticle.article.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let summary = highlightedArticle.article.summary {
                        Text(summary)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(DesignSystem.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 180)
            
            // Bottom metadata
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.base) {
                // Author and time
                HStack(spacing: DesignSystem.Spacing.small) {
                    EnhancedAsyncProfileImage(pubkey: highlightedArticle.article.author, size: 24)
                    
                    Text(PubkeyFormatter.formatCompact(highlightedArticle.article.author))
                        .font(.ds.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    Text(highlightedArticle.article.estimatedReadingTime > 0 ? "\(highlightedArticle.article.estimatedReadingTime) min read" : "Quick read")
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // Highlight count and sample
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                    HStack(spacing: DesignSystem.Spacing.mini) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 12))
                            .foregroundColor(DesignSystem.Colors.secondary)
                        
                        Text("\(highlightedArticle.highlights.count) highlight\(highlightedArticle.highlights.count == 1 ? "" : "s")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.secondary)
                        
                        Text("·")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Text(RelativeTimeFormatter.shortRelativeTime(from: highlightedArticle.lastHighlightTime))
                            .font(.system(size: 12))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    // Show a preview of the most recent highlight
                    if let latestHighlight = highlightedArticle.highlights.first {
                        Text("\"\(latestHighlight.content.prefix(80))...\"")
                            .font(.system(size: 13, design: .serif))
                            .italic()
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .padding(.horizontal, DesignSystem.Spacing.small)
                            .padding(.vertical, DesignSystem.Spacing.mini)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                    .fill(DesignSystem.Colors.highlightSubtle.opacity(0.5))
                            )
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous))
        .shadow(color: DesignSystem.Shadow.medium.color, radius: DesignSystem.Shadow.medium.radius, x: DesignSystem.Shadow.medium.x, y: DesignSystem.Shadow.medium.y)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .strokeBorder(DesignSystem.Colors.divider.opacity(0.5), lineWidth: 0.5)
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(DesignSystem.Animation.springSnappy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                HapticManager.shared.impact(.light)
            }
        }, perform: {})
    }
}


struct ActivityRing: View {
    @State private var progress: CGFloat = 0.75
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.surfaceSecondary, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.ds.primary, .ds.primary.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotation)
            
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.primary)
                Text("%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .onAppear {
            rotation = 360
        }
    }
}


struct InteractionButton: View {
    let icon: String
    let count: Int
    var color: Color = .ds.textSecondary
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.micro) {
            Image(systemName: icon)
                .font(.system(size: 14))
            if count > 0 {
                Text(formatCount(count))
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .foregroundColor(color)
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k"
        }
        return "\(count)"
    }
}

struct EngagementButton: View {
    let icon: String
    let count: Int
    var color: Color = .ds.textSecondary
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.micro) {
            Image(systemName: icon)
                .font(.system(size: 12))
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .foregroundColor(color)
    }
}

struct MetricPill: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.micro) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(value)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(DesignSystem.Colors.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.surfaceSecondary)
        )
    }
}



// MARK: - Custom Components

struct FloatingAmbientView: View {
    @State private var particles: [FloatingParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(particle.opacity),
                                DesignSystem.Colors.primary.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size / 2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.blur)
                    .animation(
                        .linear(duration: particle.duration).repeatForever(autoreverses: false),
                        value: particle.y
                    )
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<8).map { _ in
            FloatingParticle(
                size: CGFloat.random(in: 40...120),
                opacity: Double.random(in: 0.05...0.15),
                blur: CGFloat.random(in: 5...15),
                duration: Double.random(in: 20...40)
            )
        }
    }
}

struct FloatingParticle: Identifiable {
    let id = UUID()
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let duration: Double
    var x: CGFloat = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    var y: CGFloat = CGFloat.random(in: 0...UIScreen.main.bounds.height)
}

struct RefreshIndicatorView: View {
    let progress: CGFloat
    let isRefreshing: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 3)
                .frame(width: 40, height: 40)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: isRefreshing ? 0.8 : progress)
                .stroke(
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(rotation))
                .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .spring(), value: rotation)
            
            // Center icon
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
                .rotationEffect(.degrees(isRefreshing ? rotation : 0))
                .scaleEffect(isRefreshing ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRefreshing)
        }
        .scaleEffect(0.8 + (progress * 0.2))
        .opacity(progress > 0.1 ? 1 : 0)
        .onChange(of: isRefreshing) { _, newValue in
            if newValue {
                rotation = 360
            } else {
                rotation = 0
            }
        }
    }
}

struct SkeletonHighlightCard: View {
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Elegant base with subtle gradient
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.surfaceSecondary,
                            DesignSystem.Colors.surfaceSecondary.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                        .strokeBorder(
                            DesignSystem.Colors.divider.opacity(0.1),
                            lineWidth: 1
                        )
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Elegant header placeholder with varied widths
                HStack(spacing: DesignSystem.Spacing.small) {
                    Circle()
                        .fill(DesignSystem.Colors.textTertiary.opacity(0.12))
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Capsule()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.15))
                            .frame(width: 100, height: 12)
                        
                        Capsule()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                            .frame(width: 60, height: 10)
                    }
                    
                    Spacer()
                }
                
                // Content placeholder with natural text flow
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.12 - Double(index) * 0.02))
                            .frame(height: 14)
                            .frame(maxWidth: index == 2 ? 180 : .infinity)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Spacer()
                
                // Elegant footer with interaction hints
                HStack {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                            .frame(width: 16, height: 16)
                        
                        Capsule()
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.08))
                            .frame(width: 40, height: 12)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: DesignSystem.Spacing.small) {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(DesignSystem.Colors.textTertiary.opacity(0.1 - Double(index) * 0.02))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.xl)
            
            // Subtle, elegant shimmer effect
            LinearGradient(
                colors: [
                    Color.clear,
                    DesignSystem.Colors.primary.opacity(0.05),
                    DesignSystem.Colors.secondary.opacity(0.05),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 150)
            .offset(x: shimmerOffset)
            .blur(radius: 8)
            .mask(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
            )
        }
        .opacity(pulseOpacity)
        .onAppear {
            // Elegant shimmer animation
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 400
            }
            
            // Subtle pulse for organic feel
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                pulseOpacity = 0.8
            }
        }
    }
}

struct ShimmeringOverlay: View {
    @State private var shimmerPosition: CGFloat = -1
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 0.3)
            .offset(x: geometry.size.width * shimmerPosition)
            .onAppear {
                withAnimation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerPosition = 2
                }
            }
        }
        .mask(Rectangle())
    }
}

// EnhancedAsyncProfileImage is now in its own file

#Preview {
    SimplifiedHybridFeedView()
        .environmentObject(AppState())
}