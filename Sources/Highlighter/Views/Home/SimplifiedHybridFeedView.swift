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
    @State private var discussionEngagements: [String: EngagementService.EngagementMetrics] = [:]
    @State private var isRefreshing = false
    @State private var refreshProgress: CGFloat = 0
    @State private var contentAppeared = false
    
    
    // MARK: - Engagement Fetching
    private func fetchHighlightEngagements() async {
        let eventIds = dataManager.userHighlights.map { $0.id }
        guard !eventIds.isEmpty else { return }
        
        _ = await appState.engagementService.fetchEngagementBatch(for: eventIds)
        await MainActor.run {
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
                // Subtle gradient background
                LinearGradient(
                    colors: [DesignSystem.Colors.background, DesignSystem.Colors.backgroundSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Custom refresh indicator
                RefreshIndicatorView(progress: refreshProgress, isRefreshing: isRefreshing)
                    .offset(y: -80 + (scrollOffset > 0 ? scrollOffset * 0.5 : 0)
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
                                    carouselSection(
                                        title: "Featured Highlights",
                                        subtitle: "Top highlights from your network",
                                        items: dataManager.userHighlights,
                                        icon: "sparkle"
                                    ) { highlight in
                                        HighlightCard(highlight: highlight)
                                            .environmentObject(appState)
                                    }
                                }
                                
                                // Active Discussions
                                if !dataManager.discussions.isEmpty {
                                    discussionsSection
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
                            headerOpacity = min(1.0, max(0.0, (50.0 + value) / 50.0)
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
                .font(.ds.largeTitle, weight: .bold, design: .rounded)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeBasedEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date()
        switch hour {
        case 5..<12: return "☀️"
        case 12..<17: return "🌤"
        case 17..<21: return "🌅"
        default: return "🌙"
        }
    }
    
    private func carouselSection<Item: Identifiable, Content: View>(
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
                            .font(.ds.title3).fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    Text(title)
                        .font(.ds.title2, weight: .bold, design: .rounded)
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
                            )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.vertical, DesignSystem.Spacing.micro) // For shadows
            }
        }
    }
    
    
    private var recentlyHighlightedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                Text("Recently Highlighted")
                    .font(.ds.title, weight: .bold, design: .rounded)
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
    
    private var discussionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.ds.title3).fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("Active Discussions")
                            .font(.ds.title2, weight: .bold, design: .rounded)
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
                    DiscussionRow(
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

// MARK: - Cards

struct DiscussionRow: View {
    let event: NDKEvent
    let engagement: EngagementService.EngagementMetrics
    @State private var author: NDKUserProfile?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ProfileImage(pubkey: event.pubkey, size: 44)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                HStack {
                    Text(author?.displayName ?? PubkeyFormatter.formatCompact(event.pubkey)
                        .font(.ds.body).fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("·")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text(RelativeTimeFormatter.shortRelativeTime(from: event.createdAt)
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Spacer()
                    
                    if Bool.random() {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.ds.callout)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                Text(event.content)
                    .font(.ds.callout)
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
                        .font(.ds.headline, weight: .bold, design: .rounded)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let summary = highlightedArticle.article.summary {
                        Text(summary)
                            .font(.ds.callout)
                            .foregroundColor(.white.opacity(0.8)
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
                    ProfileImage(pubkey: highlightedArticle.article.author, size: 24)
                    
                    Text(PubkeyFormatter.formatCompact(highlightedArticle.article.author)
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
                            .font(.ds.caption)
                            .foregroundColor(DesignSystem.Colors.secondary)
                        
                        Text("\(highlightedArticle.highlights.count) highlight\(highlightedArticle.highlights.count == 1 ? "" : "s")")
                            .font(.ds.caption).fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.secondary)
                        
                        Text("·")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Text(RelativeTimeFormatter.shortRelativeTime(from: highlightedArticle.lastHighlightTime)
                            .font(.ds.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    // Show a preview of the most recent highlight
                    if let latestHighlight = highlightedArticle.highlights.first {
                        Text("\"\(latestHighlight.content.prefix(80))...\"")
                            .font(.ds.footnote, design: .serif)
                            .italic()
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .padding(.horizontal, DesignSystem.Spacing.small)
                            .padding(.vertical, DesignSystem.Spacing.mini)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                    .fill(DesignSystem.Colors.highlightSubtle.opacity(0.5)
                            )
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
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
                .rotationEffect(.degrees(-90)
                .rotationEffect(.degrees(rotation)
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotation)
            
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.ds.body, weight: .bold, design: .rounded)
                    .foregroundColor(DesignSystem.Colors.primary)
                Text("%")
                    .font(.ds.caption2).fontWeight(.medium)
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
                .font(.ds.callout)
            if count > 0 {
                Text(formatCount(count)
                    .font(.ds.caption).fontWeight(.medium)
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
                .font(.ds.caption)
            if count > 0 {
                Text("\(count)")
                    .font(.ds.caption2).fontWeight(.medium)
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
                .font(.ds.caption)
            Text(value)
                .font(.ds.caption).fontWeight(.medium)
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
                .rotationEffect(.degrees(rotation)
                .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .spring(), value: rotation)
            
            // Center icon
            Image(systemName: "arrow.clockwise")
                .font(.ds.body).fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primary)
                .rotationEffect(.degrees(isRefreshing ? rotation : 0)
                .scaleEffect(isRefreshing ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRefreshing)
        }
        .scaleEffect(0.8 + (progress * 0.2)
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
        .mask(Rectangle()
    }
}

// ProfileImage is now in its own file

#Preview {
    SimplifiedHybridFeedView()
        .environmentObject(AppState())
}