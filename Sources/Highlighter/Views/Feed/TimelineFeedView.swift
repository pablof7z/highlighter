import SwiftUI
import NDKSwift

struct TimelineFeedView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var feedDataManager = FeedDataManager()
    @State private var scrollOffset: CGFloat = 0
    @State private var headerScale: CGFloat = 1
    @State private var isRefreshing = false
    @State private var selectedFilter: FeedFilter = .all
    @State private var showFilterSheet = false
    @State private var feedOpacity: Double = 0
    @State private var showFloatingTimeline = true
    @State private var engagements: [String: EngagementService.EngagementMetrics] = [:]
    
    enum FeedFilter: String, CaseIterable {
        case all = "All"
        case following = "Following"
        case trending = "Trending"
        case recent = "Recent"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .following: return "person.2.fill"
            case .trending: return "flame.fill"
            case .recent: return "clock.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .ds.primary
            case .following: return .ds.secondary
            case .trending: return .red
            case .recent: return .blue
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient background
                UnifiedGradientBackground(style: .subtle)
                    .ignoresSafeArea()
                
                // Floating timeline particles
                if showFloatingTimeline {
                    TimelineParticles()
                        .ignoresSafeArea()
                        .opacity(feedOpacity)
                        .animation(.easeIn(duration: 2), value: feedOpacity)
                }
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Sticky header with filters
                            feedHeader
                                .padding(.top, DesignSystem.Spacing.large)
                                .scaleEffect(headerScale)
                                .opacity(headerScale)
                                .id("header")
                            
                            // Timeline content
                            VStack(spacing: DesignSystem.Spacing.large) {
                                ForEach(feedDataManager.timelineEvents, id: \.id) { event in
                                    TimelineEventCard(
                                        event: event,
                                        engagement: engagements[event.id] ?? EngagementService.EngagementMetrics()
                                    )
                                    .transition(.asymmetric(
                                        insertion: .push(from: .bottom).combined(with: .opacity),
                                        removal: .push(from: .top).combined(with: .opacity)
                                    ))
                                    .id(event.id)
                                }
                                
                                // No loading states - events stream in progressively
                            }
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .padding(.vertical, DesignSystem.Spacing.xl)
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
                        // Calculate header scale based on scroll
                        let scale = min(1.0, max(0.8, (100 + value) / 100))
                        withAnimation(.easeOut(duration: 0.2)) {
                            headerScale = scale
                        }
                    }
                    .refreshable {
                        HapticManager.shared.impact(.medium)
                        isRefreshing = true
                        await feedDataManager.refresh()
                        isRefreshing = false
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            feedDataManager.appState = appState
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                feedOpacity = 1
            }
        }
        .task {
            await feedDataManager.startStreaming(filter: selectedFilter)
        }
        .onChange(of: selectedFilter) { _, newFilter in
            Task {
                await feedDataManager.changeFilter(newFilter)
            }
        }
        .onChange(of: feedDataManager.timelineEvents) {
            Task {
                await fetchEngagements()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSelectionSheet(selectedFilter: $selectedFilter)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var feedHeader: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                    Text("Timeline")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Latest highlights from your network")
                        .font(.ds.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Filter button with badge
                Button(action: { showFilterSheet = true }) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(selectedFilter.color)
                            )
                        
                        if selectedFilter != .all {
                            Circle()
                                .fill(selectedFilter.color)
                                .frame(width: 12, height: 12)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .unifiedScaleButton()
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            // Quick filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(FeedFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
    }
    
    private func fetchEngagements() async {
        let eventIds = feedDataManager.timelineEvents.prefix(20).map { $0.id }
        guard !eventIds.isEmpty else { return }
        
        let fetchedEngagements = await appState.engagementService.fetchEngagementBatch(for: eventIds)
        await MainActor.run {
            engagements = fetchedEngagements
        }
    }
}

// MARK: - Timeline Event Card

struct TimelineEventCard: View {
    let event: NDKEvent
    let engagement: EngagementService.EngagementMetrics
    @State private var isExpanded = false
    @State private var showDetail = false
    @State private var cardRotation: Double = 0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with author info
                HStack(spacing: DesignSystem.Spacing.small) {
                    EnhancedAsyncProfileImage(pubkey: event.pubkey, size: 42)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(PubkeyFormatter.formatCompact(event.pubkey))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(RelativeTimeFormatter.shortRelativeTime(from: event.createdAt))
                                .font(.system(size: 12))
                        }
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    // More menu
                    Menu {
                        Button(action: {}) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(action: {}) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        Button(action: {}) {
                            Label("Report", systemImage: "flag")
                        }
                    } label: {
                        Circle()
                            .fill(Color.primary.opacity(0.05))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary.opacity(0.6))
                            )
                    }
                }
                .padding(DesignSystem.Spacing.medium)
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text(event.content)
                        .font(.system(size: 16))
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(isExpanded ? nil : 4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if event.content.count > 200 && !isExpanded {
                        Button(action: { withAnimation { isExpanded.toggle() } }) {
                            Text("Show more")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.medium)
                
                // Engagement bar
                HStack(spacing: 0) {
                    TimelineEngagementButton(
                        icon: "bubble.right",
                        count: engagement.comments,
                        action: {}
                    )
                    
                    TimelineEngagementButton(
                        icon: "arrow.2.squarepath",
                        count: engagement.reposts,
                        action: {}
                    )
                    
                    TimelineEngagementButton(
                        icon: "heart",
                        count: engagement.likes,
                        action: {}
                    )
                    
                    TimelineEngagementButton(
                        icon: "bolt.fill",
                        count: engagement.zaps,
                        color: .ds.secondary,
                        action: {}
                    )
                    
                    Spacer()
                    
                    // Bookmark button
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 16))
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    .padding(.trailing, DesignSystem.Spacing.medium)
                }
                .padding(.vertical, DesignSystem.Spacing.small)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: isPressed ? 4 : 12,
            x: 0,
            y: isPressed ? 2 : 6
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 1
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
            if pressing {
                HapticManager.shared.impact(.light)
            }
        }, perform: {})
    }
}

// MARK: - Supporting Views

struct FilterPill: View {
    let filter: TimelineFeedView.FeedFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? filter.color : Color.primary.opacity(0.08))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : Color.primary.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .unifiedScaleButton()
    }
}

struct TimelineEngagementButton: View {
    let icon: String
    let count: Int
    var color: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .foregroundColor(color.opacity(0.8))
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
        }
        .unifiedScaleButton(scale: 1.1)
    }
}

struct TimelineSkeletonCard: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            // Header skeleton
            HStack(spacing: DesignSystem.Spacing.small) {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 42, height: 42)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 120, height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 16)
                        .frame(maxWidth: index == 2 ? 200 : .infinity)
                }
            }
            
            // Footer skeleton
            HStack(spacing: DesignSystem.Spacing.large) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 40, height: 20)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 100)
            .offset(x: shimmerOffset)
            .mask(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
            )
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 300
            }
        }
    }
}

struct TimelineParticles: View {
    @State private var particles: [TimelineParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .blur(radius: particle.blur)
                    .position(x: particle.x, y: particle.y)
                    .animation(
                        .linear(duration: particle.lifetime)
                        .repeatForever(autoreverses: false),
                        value: particle.y
                    )
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<15).map { _ in
            TimelineParticle(
                color: [.ds.primary, .ds.secondary, .ds.primary.opacity(0.5)].randomElement()!,
                size: CGFloat.random(in: 20...60),
                opacity: Double.random(in: 0.05...0.15),
                blur: CGFloat.random(in: 8...20),
                lifetime: Double.random(in: 15...30)
            )
        }
    }
}

struct TimelineParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let lifetime: Double
    var x: CGFloat = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    var y: CGFloat = CGFloat.random(in: -100...UIScreen.main.bounds.height + 100)
}

struct FilterSelectionSheet: View {
    @Binding var selectedFilter: TimelineFeedView.FeedFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            // Handle
            Capsule()
                .fill(Color.primary.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, DesignSystem.Spacing.small)
            
            Text("Filter Timeline")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, DesignSystem.Spacing.small)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                ForEach(TimelineFeedView.FeedFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }) {
                        HStack(spacing: DesignSystem.Spacing.medium) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 20))
                                .foregroundColor(filter.color)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(filter.rawValue)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(filterDescription(for: filter))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(filter.color)
                            }
                        }
                        .padding(DesignSystem.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(selectedFilter == filter ? filter.color.opacity(0.1) : Color.primary.opacity(0.05))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func filterDescription(for filter: TimelineFeedView.FeedFilter) -> String {
        switch filter {
        case .all: return "Show all highlights from the network"
        case .following: return "Only from people you follow"
        case .trending: return "Most engaged highlights"
        case .recent: return "Latest highlights first"
        }
    }
}

// MARK: - Button Styles


// MARK: - Feed Data Manager

@MainActor
class FeedDataManager: ObservableObject {
    @Published var timelineEvents: [NDKEvent] = []
    // No loading states - data streams progressively
    
    weak var appState: AppState?
    private var activeFilter: TimelineFeedView.FeedFilter = .all
    private var dataSource: NDKDataSource<NDKEvent>?
    private var streamTask: Task<Void, Never>?
    private var engagementCache: [String: EngagementService.EngagementMetrics] = [:]
    
    func startStreaming(filter: TimelineFeedView.FeedFilter) async {
        guard let appState = appState, let ndk = appState.ndk else { return }
        
        // Start streaming immediately - no loading states
        activeFilter = filter
        
        // Cancel existing stream
        streamTask?.cancel()
        streamTask = nil
        
        // Create filter based on selection
        let filter = createFilter(for: filter)
        
        // Create data source for observing events
        dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 0,  // Real-time updates
            cachePolicy: .cacheWithNetwork
        )
        
        // Start streaming events
        streamTask = Task {
            guard let dataSource = dataSource else { return }
            
            // Stream events (includes cached events first)
            for await event in dataSource.events {
                guard !Task.isCancelled else { break }
                addEvent(event)
            }
        }
        
        // Events stream continuously
    }
    
    func changeFilter(_ filter: TimelineFeedView.FeedFilter) async {
        timelineEvents.removeAll()
        await startStreaming(filter: filter)
    }
    
    func refresh() async {
        await changeFilter(activeFilter)
    }
    
    private func createFilter(for feedFilter: TimelineFeedView.FeedFilter) -> NDKFilter {
        switch feedFilter {
        case .all:
            return NDKFilter(kinds: [9802]) // All highlights
        case .following:
            // Get highlights only from people the user follows
            guard let appState = appState else {
                return NDKFilter(kinds: [9802], limit: 100)
            }
            
            let followingList = Array(appState.following)
            if followingList.isEmpty {
                // If not following anyone, show recent highlights as fallback
                let since = Date().addingTimeInterval(-TimeConstants.hour * 6)
                return NDKFilter(
                    kinds: [9802],
                    since: Int64(since.timeIntervalSince1970),
                    limit: 50
                )
            }
            
            return NDKFilter(
                authors: followingList,
                kinds: [9802],
                limit: 200
            )
        case .trending:
            // Get recent highlights that will be sorted by engagement
            let since = Date().addingTimeInterval(-TimeConstants.day)
            return NDKFilter(
                kinds: [9802],
                since: Int64(since.timeIntervalSince1970),
                limit: 100
            )
        case .recent:
            let since = Date().addingTimeInterval(-TimeConstants.hour * 2)
            return NDKFilter(kinds: [9802], since: Int64(since.timeIntervalSince1970))
        }
    }
    
    private func addEvent(_ event: NDKEvent) {
        // Avoid duplicates
        guard !timelineEvents.contains(where: { $0.id == event.id }) else { return }
        
        if activeFilter == .trending {
            // For trending, we need to sort by engagement
            Task {
                await addTrendingEvent(event)
            }
        } else {
            // For other filters, insert at beginning (newest first)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                timelineEvents.insert(event, at: 0)
                
                // Keep max 100 events
                if timelineEvents.count > 100 {
                    timelineEvents.removeLast()
                }
            }
        }
    }
    
    private func addTrendingEvent(_ event: NDKEvent) async {
        guard let appState = appState else { return }
        
        // Fetch engagement metrics for this event
        let metrics = await appState.engagementService.fetchEngagement(for: event.id)
        engagementCache[event.id] = metrics
        
        await MainActor.run {
            // Add event and re-sort by engagement
            timelineEvents.append(event)
            
            // Sort by total engagement
            timelineEvents.sort { event1, event2 in
                let metrics1 = engagementCache[event1.id] ?? EngagementService.EngagementMetrics()
                let metrics2 = engagementCache[event2.id] ?? EngagementService.EngagementMetrics()
                
                return metrics1.totalEngagement > metrics2.totalEngagement
            }
            
            // Keep max 100 events
            if timelineEvents.count > 100 {
                timelineEvents = Array(timelineEvents.prefix(100))
            }
        }
    }
}

#Preview {
    TimelineFeedView()
        .environmentObject(AppState())
}