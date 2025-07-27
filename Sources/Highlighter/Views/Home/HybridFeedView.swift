import SwiftUI
import NDKSwift

struct HybridFeedView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataManager: HomeDataManager
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSection: FeedSection = .forYou
    @State private var carouselOffsets: [String: CGFloat] = [:]
    @State private var floatingHeaderOpacity: Double = 0
    @State private var activeHighlight: HighlightEvent?
    @State private var showingHighlightDetail = false
    @State private var parallaxOffset: CGFloat = 0
    @State private var sectionVisibility: [String: Bool] = [:]
    @State private var pulseAnimation = false
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    enum FeedSection: String, CaseIterable {
        case forYou = "For You"
        case trending = "Trending"
        case recent = "Recent"
        case following = "Following"
        
        var icon: String {
            switch self {
            case .forYou: return "sparkles"
            case .trending: return "flame.fill"
            case .recent: return "clock.fill"
            case .following: return "person.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .forYou: return .purple
            case .trending: return .orange
            case .recent: return .blue
            case .following: return .green
            }
        }
    }
    
    init() {
        let manager = HomeDataManager()
        self._dataManager = StateObject(wrappedValue: manager)
        // HybridFeedView initialized with dataManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient with parallax
                backgroundLayer
                
                // Main content
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Hero header with parallax
                            heroHeader
                                .offset(y: parallaxOffset * 0.5)
                                .opacity(1 - (abs(parallaxOffset) / 200.0))
                            
                            // Recent articles - ALWAYS shown at the top, right after greeting
                            RecentArticlesSection(dataManager: dataManager)
                                .padding(.vertical, 24)
                            
                            // Sticky section tabs
                            sectionTabs
                                .background(
                                    HybridFeedVisualEffectBlur(blurStyle: .systemMaterial)
                                        .opacity(floatingHeaderOpacity)
                                        .ignoresSafeArea()
                                )
                                .overlay(alignment: .bottom) {
                                    Divider()
                                        .opacity(floatingHeaderOpacity)
                                }
                            
                            // Content sections with carousels
                            contentSections
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        handleScrollOffset(value)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            dataManager.appState = appState
            startAnimations()
        }
        .task {
            await dataManager.startStreaming()
        }
        .sheet(isPresented: $showingHighlightDetail) {
            if let highlight = activeHighlight {
                HighlightDetailView(highlight: highlight)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // MARK: - Background Layer
    @ViewBuilder
    private var backgroundLayer: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.ds.background,
                    Color.ds.background.opacity(0.95),
                    selectedSection.color.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated mesh gradient
            if colorScheme == .dark {
                MeshGradientBackground()
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .blur(radius: 50)
                    .scaleEffect(1 + (pulseAnimation ? 0.1 : 0))
            }
            
            // Noise texture overlay
            NoiseTextureView()
                .opacity(0.03)
                .ignoresSafeArea()
                .blendMode(.overlay)
        }
    }
    
    // MARK: - Hero Header
    @ViewBuilder
    private var heroHeader: some View {
        VStack(spacing: 20) {
            // App name
            Text("Highlighter")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ds.text, .ds.text.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }
    
    // MARK: - Section Tabs
    @ViewBuilder
    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(FeedSection.allCases, id: \.self) { section in
                    SectionTab(
                        section: section,
                        isSelected: selectedSection == section,
                        namespace: animation
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedSection = section
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Content Sections
    @ViewBuilder
    private var contentSections: some View {
        VStack(spacing: 32) {
            // Featured highlights carousel
            if selectedSection == .forYou || selectedSection == .trending {
                CarouselSection(
                    title: "Featured Highlights",
                    icon: "star.fill",
                    iconColor: .yellow,
                    id: "featured"
                ) {
                    ForEach(dataManager.userHighlights.prefix(10), id: \.id) { highlight in
                        FeaturedHighlightCarouselCard(highlight: highlight)
                            .onTapGesture {
                                activeHighlight = highlight
                                showingHighlightDetail = true
                                HapticManager.shared.impact(.medium)
                            }
                    }
                }
                .revealAnimation(id: "featured", visibility: $sectionVisibility)
            }
            
            // Trending quotes carousel
            CarouselSection(
                title: "Trending Quotes",
                icon: "quote.bubble.fill",
                iconColor: .orange,
                id: "quotes",
                cardWidth: 280
            ) {
                ForEach(dataManager.userHighlights.filter { $0.content.count < 150 }.prefix(8), id: \.id) { highlight in
                    QuoteCarouselCard(highlight: highlight)
                }
            }
            .revealAnimation(id: "quotes", visibility: $sectionVisibility)
            
            // Active discussions - vertical list within the feed
            if !dataManager.discussions.isEmpty {
                ActiveDiscussionsInlineSection(discussions: dataManager.discussions)
                    .padding(.horizontal, 20)
                    .revealAnimation(id: "discussions", visibility: $sectionVisibility)
            }
            
            // Community curations carousel
            CarouselSection(
                title: "Community Curations",
                icon: "folder.fill",
                iconColor: .blue,
                id: "curations",
                cardWidth: 300
            ) {
                ForEach(0..<5) { index in
                    CurationCarouselCard(index: index)
                }
            }
            .revealAnimation(id: "curations", visibility: $sectionVisibility)
            
            // Recently zapped articles
            if !dataManager.zappedArticles.isEmpty {
                CarouselSection(
                    title: "Lightning Strikes",
                    icon: "bolt.fill",
                    iconColor: .yellow,
                    id: "zapped",
                    cardWidth: 320
                ) {
                    ForEach(dataManager.zappedArticles.prefix(6), id: \.id) { event in
                        ZappedArticleCard(event: event)
                    }
                }
                .revealAnimation(id: "zapped", visibility: $sectionVisibility)
            }
            
            // Follow recommendations carousel
            CarouselSection(
                title: "Discover People",
                icon: "person.crop.circle.badge.plus",
                iconColor: .green,
                id: "people",
                cardWidth: 160
            ) {
                ForEach(0..<8) { index in
                    PersonDiscoveryCard(index: index)
                }
            }
            .revealAnimation(id: "people", visibility: $sectionVisibility)
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Helper Methods
    private func handleScrollOffset(_ offset: CGFloat) {
        scrollOffset = offset
        parallaxOffset = min(0, offset)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            floatingHeaderOpacity = min(1, max(0, -offset / 100))
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

// MARK: - Supporting Components

struct CarouselSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let id: String
    var cardWidth: CGFloat = 240
    @ViewBuilder let content: () -> Content
    @State private var scrollOffset: CGFloat = 0
    @State private var titleScale: CGFloat = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Label(title, systemImage: icon)
                    .font(.ds.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.ds.text)
                    .scaleEffect(titleScale)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.ds.footnote)
                        .foregroundColor(.ds.primary)
                }
            }
            .padding(.horizontal, 20)
            
            // Carousel content
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    content()
                        .frame(width: cardWidth)
                }
                .padding(.horizontal, 20)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.x)
                }
            )
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
                withAnimation(.spring(response: 0.3)) {
                    titleScale = 1 + (abs(scrollOffset) / 1000)
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }
}

struct FeaturedHighlightCarouselCard: View {
    let highlight: HighlightEvent
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Content
            Text("\"\(highlight.content)\"")
                .font(.ds.headline)
                .foregroundColor(.ds.text)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Context indicator
            if highlight.context != nil {
                Label("Has context", systemImage: "text.bubble")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
            
            // Footer
            HStack {
                Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                    .font(.ds.caption)
                    .foregroundColor(.ds.textTertiary)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.ds.primary)
                    .opacity(isPressed ? 1 : 0.6)
            }
        }
        .padding(20)
        .frame(height: 180)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.ds.surfaceSecondary,
                                Color.ds.surfaceSecondary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glow effect
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(glowIntensity),
                                Color.orange.opacity(glowIntensity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 2)
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.95 : 1)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
    }
}

struct QuoteCarouselCard: View {
    let highlight: HighlightEvent
    @State private var rotationAngle: Double = 0
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Quote mark
            Image(systemName: "quote.opening")
                .font(.title)
                .foregroundColor(.orange.opacity(0.6))
                .rotationEffect(.degrees(isHovered ? 10 : 0))
            
            // Quote text
            Text(highlight.content)
                .font(.ds.body)
                .foregroundColor(.ds.text)
                .multilineTextAlignment(.center)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Attribution
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.caption)
                    .foregroundColor(.ds.textSecondary)
                
                Text(PubkeyFormatter.formatShort(highlight.author))
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
        }
        .padding(24)
        .frame(height: 200)
        .background(
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.05),
                        Color.orange.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 8, x: 0, y: 4)
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 1
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.3)) {
                isHovered = hovering
                rotationAngle = hovering ? 5 : 0
            }
        }
    }
}

struct CurationCarouselCard: View {
    let index: Int
    @State private var imageOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover image with parallax
            ZStack {
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.8)
                
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
                    .offset(imageOffset)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Philosophy Essentials")
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                
                Text("A collection of timeless wisdom from great thinkers")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(2)
                
                // Stats
                HStack(spacing: 16) {
                    Label("24 items", systemImage: "doc.text")
                    Label("1.2k zaps", systemImage: "bolt.fill")
                }
                .font(.ds.caption)
                .foregroundColor(.ds.textTertiary)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                imageOffset = CGSize(width: 10, height: -10)
            }
        }
    }
}

struct PersonDiscoveryCard: View {
    let index: Int
    @State private var isFollowing = false
    @State private var bounceScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("NP")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .scaleEffect(bounceScale)
            
            // Name
            Text("Nostrich #\(index + 1)")
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.text)
                .lineLimit(1)
            
            // Stats
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption2)
                Text("\(Int.random(in: 100...999))")
                    .font(.ds.caption)
            }
            .foregroundColor(.ds.textSecondary)
            
            // Follow button
            Button(action: {
                isFollowing.toggle()
                HapticManager.shared.impact(.light)
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    bounceScale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3)) {
                        bounceScale = 1
                    }
                }
            }) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.ds.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isFollowing ? .ds.text : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isFollowing ? Color.ds.surfaceSecondary : Color.ds.primary)
                    )
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ZappedArticleCard: View {
    let event: NDKEvent
    @State private var lightningAnimation = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Lightning icon with animation
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .blur(radius: lightningAnimation ? 10 : 5)
                
                Image(systemName: "bolt.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .scaleEffect(lightningAnimation ? 1.2 : 1)
                    .rotationEffect(.degrees(lightningAnimation ? 10 : -10))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Article received 1,000 sats")
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                
                Text(event.content.prefix(100) + "...")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(2)
                
                Text(RelativeTimeFormatter.relativeTime(from: event.createdAt))
                    .font(.ds.caption)
                    .foregroundColor(.ds.textTertiary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.05),
                    Color.yellow.opacity(0.02)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                lightningAnimation = true
            }
        }
    }
}

struct ActiveDiscussionsInlineSection: View {
    let discussions: [NDKEvent]
    @State private var expandedDiscussion: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Active Discussions", systemImage: "bubble.left.and.bubble.right.fill")
                .font(.ds.title3)
                .fontWeight(.semibold)
                .foregroundColor(.ds.text)
            
            VStack(spacing: 0) {
                ForEach(discussions.prefix(3), id: \.id) { event in
                    DiscussionRowEnhanced(
                        event: event,
                        isExpanded: expandedDiscussion == event.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                expandedDiscussion = expandedDiscussion == event.id ? nil : event.id
                            }
                        }
                    )
                    
                    if event.id != discussions.prefix(3).last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color.ds.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct DiscussionRowEnhanced: View {
    let event: NDKEvent
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                TappableAvatar(pubkey: event.pubkey, size: 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(PubkeyFormatter.formatCompact(event.pubkey))
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.ds.text)
                        
                        Text("·")
                            .foregroundColor(.ds.textTertiary)
                        
                        Text(RelativeTimeFormatter.relativeTime(from: event.createdAt))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.ds.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    
                    Text(event.content)
                        .font(.ds.body)
                        .foregroundColor(.ds.text)
                        .lineLimit(isExpanded ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if isExpanded {
                        HStack(spacing: 20) {
                            Button(action: {}) {
                                Label("Reply", systemImage: "bubble.left")
                                    .font(.ds.caption)
                                    .foregroundColor(.ds.primary)
                            }
                            
                            Button(action: {}) {
                                Label("12", systemImage: "bolt.fill")
                                    .font(.ds.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct SectionTab: View {
    let section: HybridFeedView.FeedSection
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: section.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? section.color : .ds.textTertiary)
                    
                    Text(section.rawValue)
                        .font(.ds.footnoteMedium)
                        .foregroundColor(isSelected ? .ds.text : .ds.textSecondary)
                }
                
                // Animated underline
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(section.color)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "tab", in: namespace)
                    } else {
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 3)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @State private var animateValue = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .scaleEffect(animateValue ? 1.1 : 1)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.ds.footnoteMedium)
                    .foregroundColor(.ds.text)
                    .monospacedDigit()
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.ds.textTertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                animateValue = true
            }
        }
    }
}

// MARK: - Visual Effects

struct HybridFeedVisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

struct NoiseTextureView: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for _ in 0..<1000 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let opacity = Double.random(in: 0.1...0.3)
                    
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Recent Articles Section

struct RecentArticlesSection: View {
    @ObservedObject var dataManager: HomeDataManager
    @State private var currentPage = 0
    @State private var selectedArticle: Article?
    @State private var showingArticleDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                Label("Recent articles", systemImage: "clock.fill")
                    .font(.ds.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                // Page indicators
                if !dataManager.highlightedArticles.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(0..<min(dataManager.highlightedArticles.count, 5), id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.ds.primary : Color.ds.textTertiary.opacity(0.3))
                                .frame(width: 6, height: 6)
                                .scaleEffect(currentPage == index ? 1.2 : 1)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Portrait article cards carousel
            if !dataManager.highlightedArticles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(Array(dataManager.highlightedArticles.prefix(5).enumerated()), id: \.element.article.id) { index, highlightedArticle in
                            RecentArticlePortraitCard(
                                article: highlightedArticle.article,
                                highlights: highlightedArticle.highlights,
                                index: index
                            )
                            .frame(width: UIScreen.main.bounds.width - 80)
                            .onTapGesture {
                                selectedArticle = highlightedArticle.article
                                showingArticleDetail = true
                                HapticManager.shared.impact(.medium)
                            }
                            .onAppear {
                                withAnimation {
                                    currentPage = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .sensoryFeedback(.selection, trigger: currentPage)
            }
        }
        .sheet(isPresented: $showingArticleDetail) {
            if let article = selectedArticle {
                ArticleView(article: article)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }
}

struct RecentArticlePortraitCard: View {
    let article: Article?
    let highlights: [HighlightEvent]
    let index: Int
    @State private var isPressed = false
    @State private var imageScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image or gradient
            if let article = article, let imageUrl = article.image {
                GeometryReader { geometry in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            shimmeringGradient
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scaleEffect(imageScale)
                                .animation(.easeInOut(duration: 20).repeatForever(autoreverses: true), value: imageScale)
                                .clipped()
                        case .failure(_):
                            fallbackGradient
                        @unknown default:
                            fallbackGradient
                        }
                    }
                }
            } else {
                fallbackGradient
            }
            
            // Dark overlay gradient for text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content overlay
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                // Category/Topic badge
                if let article = article, let firstTag = article.hashtags.first {
                    Text(firstTag.uppercased())
                        .font(.ds.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                        )
                } else {
                    Text(["PHILOSOPHY", "TECHNOLOGY", "SCIENCE", "CULTURE", "BITCOIN"][index % 5])
                        .font(.ds.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                        )
                }
                
                // Title
                Text(article?.title ?? "Recent Article Title \(index + 1)")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Summary or first highlight
                if let article = article, let summary = article.summary {
                    Text(summary)
                        .font(.ds.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                } else if !highlights.isEmpty, let firstHighlight = highlights.first {
                    HStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(firstHighlight.content)
                            .font(.ds.body)
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                } else {
                    Text("This is a compelling summary that draws readers in and gives them a preview of the fascinating content within this article...")
                        .font(.ds.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                // Metadata bar
                HStack(spacing: 16) {
                    // Reading time
                    if let article = article {
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(.ds.caption)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Label("\(5 + index) min", systemImage: "clock")
                            .font(.ds.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Highlights count
                    Label("\(highlights.count)", systemImage: "highlighter")
                        .font(.ds.caption)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    // Author avatar and time
                    if let article = article {
                        HStack(spacing: 8) {
                            TappableAvatar(pubkey: article.author, size: 24)
                            
                            Text(PubkeyFormatter.formatCompact(article.author))
                                .font(.ds.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 500)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15),
            radius: 20,
            x: 0,
            y: 10
        )
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
                if pressing {
                    HapticManager.shared.impact(.light)
                }
            },
            perform: {}
        )
        .onTapGesture {
            HapticManager.shared.impact(.medium)
        }
        .onAppear {
            // Start subtle Ken Burns effect
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                imageScale = 1.1
            }
            
            // Start shimmer animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
    
    @ViewBuilder
    private var shimmeringGradient: some View {
        LinearGradient(
            colors: [
                Color.ds.surfaceSecondary,
                Color.ds.surfaceSecondary.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.2),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(30))
            .offset(x: shimmerOffset)
            .blendMode(.screen)
        )
    }
    
    @ViewBuilder
    private var fallbackGradient: some View {
        let gradients: [[Color]] = [
            [Color.purple, Color.blue],
            [Color.orange, Color.pink],
            [Color.green, Color.teal],
            [Color.red, Color.orange],
            [Color.indigo, Color.purple]
        ]
        
        LinearGradient(
            colors: gradients[index % gradients.count],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle pattern overlay
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 200, height: 200)
                        .offset(
                            x: CGFloat(i * 50 - 50),
                            y: CGFloat(i * 80 - 100)
                        )
                        .blur(radius: 50)
                }
            }
        )
    }
}

// MARK: - Featured Articles Section

struct FeaturedArticlesSection: View {
    let articles: [HomeDataManager.HighlightedArticle]
    let onArticleTap: (Article) -> Void
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                Label("Recent articles2", systemImage: "doc.richtext.fill")
                    .font(.ds.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 6) {
                    ForEach(0..<min(articles.count, 5), id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.ds.primary : Color.ds.textTertiary.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(currentPage == index ? 1.2 : 1)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Portrait article cards carousel
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(articles.prefix(5).enumerated()), id: \.element.article.id) { index, highlightedArticle in
                        PortraitArticleCard(
                            article: highlightedArticle.article,
                            highlights: highlightedArticle.highlights,
                            index: index
                        )
                        .onTapGesture {
                            onArticleTap(highlightedArticle.article)
                        }
                        .frame(width: UIScreen.main.bounds.width - 40)
                        .onAppear {
                            withAnimation {
                                currentPage = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .sensoryFeedback(.selection, trigger: currentPage)
        }
    }
}

struct PortraitArticleCard: View {
    let article: Article
    let highlights: [HighlightEvent]
    let index: Int
    @State private var isPressed = false
    @State private var imageScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image or gradient
            if let imageUrl = article.image {
                GeometryReader { geometry in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            shimmeringGradient
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scaleEffect(imageScale)
                                .animation(.easeInOut(duration: 20).repeatForever(autoreverses: true), value: imageScale)
                                .clipped()
                        case .failure(_):
                            fallbackGradient
                        @unknown default:
                            fallbackGradient
                        }
                    }
                }
            } else {
                fallbackGradient
            }
            
            // Dark overlay gradient for text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content overlay
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                // Category/Topic badge
                if let firstTag = article.hashtags.first {
                    Text(firstTag.uppercased())
                        .font(.ds.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                        )
                }
                
                // Title
                Text(article.title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Summary or first highlight
                if let summary = article.summary {
                    Text(summary)
                        .font(.ds.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                } else if let firstHighlight = highlights.first {
                    HStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(firstHighlight.content)
                            .font(.ds.body)
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                
                // Metadata bar
                HStack(spacing: 16) {
                    // Reading time
                    Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                        .font(.ds.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Highlights count
                    Label("\(highlights.count)", systemImage: "highlighter")
                        .font(.ds.caption)
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    // Author avatar placeholder
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(PubkeyFormatter.formatForAvatar(article.author))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            )
                        
                        Text(PubkeyFormatter.formatCompact(article.author))
                            .font(.ds.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 500)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15),
            radius: 20,
            x: 0,
            y: 10
        )
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
                if pressing {
                    HapticManager.shared.impact(.light)
                }
            },
            perform: {}
        )
        .onAppear {
            // Start subtle Ken Burns effect
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                imageScale = 1.1
            }
            
            // Start shimmer animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }
    
    @ViewBuilder
    private var shimmeringGradient: some View {
        LinearGradient(
            colors: [
                Color.ds.surfaceSecondary,
                Color.ds.surfaceSecondary.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.2),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(30))
            .offset(x: shimmerOffset)
            .blendMode(.screen)
        )
    }
    
    @ViewBuilder
    private var fallbackGradient: some View {
        let gradients: [[Color]] = [
            [Color.purple, Color.blue],
            [Color.orange, Color.pink],
            [Color.green, Color.teal],
            [Color.red, Color.orange],
            [Color.indigo, Color.purple]
        ]
        
        LinearGradient(
            colors: gradients[index % gradients.count],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle pattern overlay
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 200, height: 200)
                        .offset(
                            x: CGFloat(i * 50 - 50),
                            y: CGFloat(i * 80 - 100)
                        )
                        .blur(radius: 50)
                }
            }
        )
    }
}

// MARK: - View Modifiers

extension View {
    func revealAnimation(id: String, visibility: Binding<[String: Bool]>) -> some View {
        self
            .opacity(visibility.wrappedValue[id] ?? false ? 1 : 0)
            .offset(y: visibility.wrappedValue[id] ?? false ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    visibility.wrappedValue[id] = true
                }
            }
    }
}

// MARK: - Preference Keys

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Preview

struct HybridFeedView_Previews: PreviewProvider {
    static var previews: some View {
        HybridFeedView()
            .environmentObject(AppState())
    }
}
