import SwiftUI
import NDKSwift

struct HybridFeedView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataManager: HomeDataManager
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSection: FeedSection = .forYou
    @State private var carouselOffsets: [String: CGFloat] = [:]
    @State private var headerVisible = false
    @State private var activeHighlight: HighlightEvent?
    @State private var showingHighlightDetail = false
    @State private var sectionVisibility: [String: Bool] = [:]
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
                // Simple background
                Color.ds.background
                    .ignoresSafeArea()
                
                // Main content
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Hero header
                            heroHeader
                            
                            // Recent articles - ALWAYS shown at the top, right after greeting
                            RecentArticlesSection(dataManager: dataManager)
                                .padding(.vertical, 16)
                            
                            // Sticky section tabs
                            sectionTabs
                                .background(
                                    Color.ds.background
                                        .opacity(headerVisible ? 0.95 : 0)
                                        .ignoresSafeArea()
                                )
                                .overlay(alignment: .bottom) {
                                    if headerVisible {
                                        Divider()
                                    }
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
    
    // MARK: - Hero Header
    @ViewBuilder
    private var heroHeader: some View {
        VStack(spacing: 12) {
            // App name
            Text("Highlighter")
                .font(.system(size: 32, weight: .bold, design: .rounded))
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
        .padding(.vertical, 16)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Content Sections
    @ViewBuilder
    private var contentSections: some View {
        VStack(spacing: 24) {
            // Featured highlights carousel
            if selectedSection == .forYou || selectedSection == .trending {
                CarouselSection(
                    title: "Featured Highlights",
                    icon: "star.fill",
                    iconColor: .yellow,
                    id: "featured"
                ) {
                    ForEach(dataManager.userHighlights.prefix(10), id: \.id) { highlight in
                        Button(action: {
                            activeHighlight = highlight
                            showingHighlightDetail = true
                            HapticManager.shared.impact(.medium)
                        }) {
                            FeaturedHighlightCarouselCard(highlight: highlight)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                    Button(action: {
                        activeHighlight = highlight
                        showingHighlightDetail = true
                        HapticManager.shared.impact(.medium)
                    }) {
                        QuoteCarouselCard(highlight: highlight)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .revealAnimation(id: "quotes", visibility: $sectionVisibility)
            
            // Active discussions - vertical list within the feed
            if !dataManager.discussions.isEmpty {
                ActiveDiscussionsInlineSection(discussions: dataManager.discussions)
                    .padding(.horizontal, 16)
                    .revealAnimation(id: "discussions", visibility: $sectionVisibility)
            }
            
            // Community curations carousel
            if !dataManager.curations.isEmpty {
                CarouselSection(
                    title: "Community Curations",
                    icon: "folder.fill",
                    iconColor: .blue,
                    id: "curations",
                    cardWidth: 300
                ) {
                    ForEach(dataManager.curations) { curation in
                        NavigationLink(destination: CurationDetailView(curation: curation)) {
                            CurationCarouselCard(curation: curation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .revealAnimation(id: "curations", visibility: $sectionVisibility)
            }
            
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
                        Button(action: {
                            // Handle zapped article tap
                            HapticManager.shared.impact(.medium)
                        }) {
                            ZappedArticleCard(event: event)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .revealAnimation(id: "zapped", visibility: $sectionVisibility)
            }
            
            // Follow recommendations carousel
            if !dataManager.suggestedUsers.isEmpty {
                CarouselSection(
                    title: "Discover People",
                    icon: "person.crop.circle.badge.plus",
                    iconColor: .green,
                    id: "people",
                    cardWidth: 160
                ) {
                    ForEach(Array(dataManager.suggestedUsers.enumerated()), id: \.offset) { index, profile in
                        PersonDiscoveryCard(
                            profile: profile, 
                            pubkey: index < dataManager.suggestedUserPubkeys.count ? dataManager.suggestedUserPubkeys[index] : ""
                        )
                    }
                }
                .revealAnimation(id: "people", visibility: $sectionVisibility)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Methods
    private func handleScrollOffset(_ offset: CGFloat) {
        scrollOffset = offset
        headerVisible = offset < -50
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
            .padding(.horizontal, 16)
            
            // Carousel content
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    content()
                        .frame(width: cardWidth)
                }
                .padding(.horizontal, 12)
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
        .padding(16)
        .frame(height: 160)
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
    let curation: ArticleCuration
    @State private var imageOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover image with parallax
            ZStack {
                if let imageUrl = curation.image {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    } placeholder: {
                        gradientBackground
                    }
                } else {
                    gradientBackground
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(curation.title)
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                if let description = curation.description {
                    Text(description)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
                
                // Stats
                HStack(spacing: 16) {
                    Label("\(curation.articles.count)", systemImage: "doc.text")
                    Label(PubkeyFormatter.formatCompact(curation.author), systemImage: "person.circle")
                }
                .font(.ds.caption)
                .foregroundColor(.ds.textTertiary)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var gradientBackground: some View {
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
    }
}

struct PersonDiscoveryCard: View {
    let profile: NDKUserProfile
    let pubkey: String
    @State private var isFollowing = false
    @State private var bounceScale: CGFloat = 1
    @EnvironmentObject var appState: AppState
    
    var displayName: String {
        profile.displayName ?? profile.name ?? PubkeyFormatter.formatCompact(pubkey)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            if let picture = profile.picture {
                AsyncImage(url: URL(string: picture)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    avatarPlaceholder
                }
                .scaleEffect(bounceScale)
            } else {
                avatarPlaceholder
                    .scaleEffect(bounceScale)
            }
            
            // Name
            Text(displayName)
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.text)
                .lineLimit(1)
            
            // Bio snippet if available
            if let about = profile.about {
                Text(about)
                    .font(.system(size: 10))
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            
            // Follow button
            Button(action: {
                Task {
                    await toggleFollow()
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
        .task {
            await checkFollowStatus()
        }
    }
    
    private var avatarPlaceholder: some View {
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
            
            Text(String(displayName.prefix(2)).uppercased())
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
    
    private func checkFollowStatus() async {
        do {
            isFollowing = try await appState.isFollowing(pubkey)
        } catch {
            // Error checking follow status
            isFollowing = false
        }
    }
    
    private func toggleFollow() async {
        let wasFollowing = isFollowing
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
        
        // Actually update the follow list using AppState
        do {
            if isFollowing {
                try await appState.followUser(pubkey)
            } else {
                try await appState.unfollowUser(pubkey)
            }
        } catch {
            // Revert on error
            await MainActor.run {
                isFollowing = wasFollowing
                HapticManager.shared.notification(.error)
            }
        }
    }
}

struct ZappedArticleCard: View {
    let event: NDKEvent
    @State private var lightningAnimation = false
    
    private var zapAmount: Int {
        // Extract amount from bolt11 tag if available
        if let bolt11Tag = event.tags.first(where: { $0.first == "bolt11" }),
           bolt11Tag.count > 1,
           let amountTag = event.tags.first(where: { $0.first == "amount" }),
           amountTag.count > 1,
           let amount = Int(amountTag[1]) {
            return amount / 1000 // Convert millisats to sats
        }
        return 0
    }
    
    private var zapperPubkey: String? {
        event.tags.first(where: { $0.first == "P" })?[safe: 1]
    }
    
    private var zappedEventId: String? {
        event.tags.first(where: { $0.first == "e" })?[safe: 1]
    }
    
    private var zapDescription: String {
        // Try to extract description from the event
        if let descriptionTag = event.tags.first(where: { $0.first == "description" }),
           descriptionTag.count > 1 {
            return descriptionTag[1]
        }
        return event.content
    }
    
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
                if zapAmount > 0 {
                    Text("⚡ \(zapAmount.formatted()) sats")
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                } else {
                    Text("Lightning payment")
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                }
                
                if !zapDescription.isEmpty {
                    Text(zapDescription.prefix(100) + (zapDescription.count > 100 ? "..." : ""))
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    if let zapperPubkey = zapperPubkey {
                        Text("from \(PubkeyFormatter.formatCompact(zapperPubkey))")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                    }
                    
                    Text("• \(RelativeTimeFormatter.relativeTime(from: event.createdAt))")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                }
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
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Label("Recent articles", systemImage: "clock.fill")
                    .font(.ds.title2)
                    .fontWeight(.semibold)
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
            .padding(.horizontal, 16)
            
            // Portrait article cards carousel
            if !dataManager.highlightedArticles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(Array(dataManager.highlightedArticles.prefix(5).enumerated()), id: \.element.article.id) { index, highlightedArticle in
                            Button(action: {
                                selectedArticle = highlightedArticle.article
                                showingArticleDetail = true
                                HapticManager.shared.impact(.medium)
                            }) {
                                RecentArticlePortraitCard(
                                    article: highlightedArticle.article,
                                    highlights: highlightedArticle.highlights,
                                    index: index
                                )
                                .frame(width: 280)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                withAnimation {
                                    currentPage = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image or gradient
            if let article = article, let imageUrl = article.image {
                GeometryReader { geometry in
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Color.ds.surfaceSecondary
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
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
                }
                
                // Title
                if let article = article {
                    Text(article.title)
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
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
                }
                
                // Metadata bar
                HStack(spacing: 16) {
                    // Reading time
                    if let article = article {
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
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
            .padding(20)
        }
        .frame(height: 420)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
