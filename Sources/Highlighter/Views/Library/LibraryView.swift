import SwiftUI
import NDKSwift

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCreateCuration = false
    @State private var selectedCuration: ArticleCuration?
    @State private var selectedFollowPack: FollowPack?
    @State private var showCurationManagement = false
    @State private var selectedFilter = FilterTab.all
    @State private var searchText = ""
    @State private var showStats = true
    @State private var animateGradient = false
    
    enum FilterTab: String, CaseIterable {
        case all = "All"
        case highlights = "Highlights"
        case curations = "Collections"
        case articles = "Articles"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .highlights: return "highlighter"
            case .curations: return "folder.fill"
            case .articles: return "doc.text.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color.ds.primary.opacity(0.05),
                        Color.ds.secondary.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Stats header
                        if showStats {
                            LibraryStatsCard()
                                .padding(.horizontal)
                                .padding(.top)
                                .transition(.asymmetric(
                                    insertion: .push(from: .top).combined(with: .opacity),
                                    removal: .push(from: .bottom).combined(with: .opacity)
                                ))
                        }
                        
                        // Filter tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.base) {
                                ForEach(FilterTab.allCases, id: \.self) { tab in
                                    LibraryFilterChip(
                                        title: tab.rawValue,
                                        icon: tab.icon,
                                        isSelected: selectedFilter == tab
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedFilter = tab
                                            HapticManager.shared.impact(.light)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        // Content based on filter
                        VStack(spacing: DesignSystem.Spacing.xxl) {
                            switch selectedFilter {
                            case .all:
                                allContentView
                            case .highlights:
                                EnhancedSavedHighlightsSection()
                            case .curations:
                                EnhancedYourCurationsSection(
                                    curations: appState.userCurations,
                                    showCreateCuration: $showCreateCuration,
                                    selectedCuration: $selectedCuration,
                                    showCurationManagement: $showCurationManagement
                                )
                            case .articles:
                                SavedArticlesSection()
                            }
                        }
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
                .refreshable {
                    await refreshLibrary()
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search your library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { 
                            withAnimation {
                                showStats.toggle()
                            }
                        }) {
                            Label(showStats ? "Hide Stats" : "Show Stats", systemImage: "chart.bar")
                        }
                        
                        Button(action: {}) {
                            Label("Sort by Date", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button(action: {}) {
                            Label("Export Library", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.ds.text)
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
        .onAppear {
            animateGradient = true
        }
        .sheet(isPresented: $showCreateCuration) {
            CreateCurationView()
                .environmentObject(appState)
        }
        .sheet(item: $selectedCuration) { curation in
            CurationDetailView(curation: curation)
                .environmentObject(appState)
        }
        .sheet(item: $selectedFollowPack) { followPack in
            FollowPackDetailView(followPack: followPack)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showCurationManagement) {
            CurationManagementView()
                .environmentObject(appState)
        }
    }
    
    private func refreshLibrary() async {
        // Haptic feedback for pull-to-refresh
        await MainActor.run {
            HapticManager.shared.impact(.medium)
        }
        
        // Reload highlights from network
        await loadHighlights()
        
        // Refresh other content types
        await loadCurations()
        await loadArticles()
        
        // Update activity feed
        await loadActivity()
        
        await MainActor.run {
            // Force UI update after refresh
            showStats = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.showStats = true
                }
            }
        }
    }
    
    private func loadHighlights() async {
        // Placeholder for loading highlights
    }
    
    private func loadCurations() async {
        // Placeholder for loading curations
    }
    
    private func loadArticles() async {
        // Placeholder for loading articles
    }
    
    private func loadActivity() async {
        // Placeholder for loading activity
    }
    
    @ViewBuilder
    private var allContentView: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // Recent Activity
            RecentActivitySection()
            
            // Saved highlights
            EnhancedSavedHighlightsSection()
            
            // Your curations
            EnhancedYourCurationsSection(
                curations: appState.userCurations,
                showCreateCuration: $showCreateCuration,
                selectedCuration: $selectedCuration,
                showCurationManagement: $showCurationManagement
            )
            
            // Follow packs
            EnhancedFollowPacksSection(
                followPacks: appState.followPacks,
                selectedFollowPack: $selectedFollowPack
            )
        }
    }
}

// MARK: - New Components

struct LibraryStatsCard: View {
    @EnvironmentObject var appState: AppState
    @State private var animateStats = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            HStack {
                Text("Your Library")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                // Streak indicator
                HStack(spacing: DesignSystem.Spacing.mini) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    Text("7 day streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, DesignSystem.Spacing.base)
                .padding(.vertical, DesignSystem.Spacing.mini)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }
            
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                LibraryStatCard(
                    value: "\(appState.highlights.count)",
                    label: "Highlights",
                    icon: "highlighter",
                    color: .ds.primary,
                    animate: $animateStats
                )
                
                LibraryStatCard(
                    value: "\(appState.curations.count)",
                    label: "Collections",
                    icon: "folder.fill",
                    color: .purple,
                    animate: $animateStats
                )
                
                LibraryStatCard(
                    value: "\(Int.random(in: 10...50))",
                    label: "Articles",
                    icon: "doc.text.fill",
                    color: .blue,
                    animate: $animateStats
                )
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.ds.surfaceSecondary,
                            Color.ds.surface
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 20, y: 10)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateStats = true
            }
        }
    }
}

struct LibraryStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    @Binding var animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1 : 0.5)
                    .opacity(animate ? 1 : 0)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.ds.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct LibraryFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .ds.text)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small + DesignSystem.Spacing.nano)
            .background(
                Capsule()
                    .fill(isSelected ? Color.ds.primary : Color.ds.surfaceSecondary)
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.ds.divider, lineWidth: 1)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var appState: AppState
    @State private var activities: [ActivityItem] = []
    
    struct ActivityItem: Identifiable {
        let id = UUID()
        let type: ActivityType
        let title: String
        let time: Date
        
        enum ActivityType {
            case highlight, curation, article, zap
            
            var icon: String {
                switch self {
                case .highlight: return "highlighter"
                case .curation: return "folder.badge.plus"
                case .article: return "doc.text"
                case .zap: return "bolt.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .highlight: return .ds.primary
                case .curation: return .purple
                case .article: return .blue
                case .zap: return .orange
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Recent Activity", systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.ds.primary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(activities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            loadRecentActivities()
        }
    }
    
    private func loadRecentActivities() {
        Task {
            guard let ndk = appState.ndk,
                  let signer = appState.activeSigner else { return }
            
            do {
                let pubkey = try await signer.pubkey
                let since = Date().addingTimeInterval(-24 * 60 * 60) // Last 24 hours
                
                // Fetch recent activities from the user
                let filter = NDKFilter(
                    authors: [pubkey],
                    kinds: [7, 9735, 9802, 30004, 30023], // reactions, zaps, highlights, curations, articles
                    since: Int64(since.timeIntervalSince1970),
                    limit: 20
                )
                
                let dataSource = await ndk.outbox.observe(filter: filter)
                var events: [NDKEvent] = []
                for await event in dataSource.events {
                    events.append(event)
                }
                
                var newActivities: [ActivityItem] = []
                
                for event in events.sorted(by: { $0.createdAt > $1.createdAt }).prefix(10) {
                    switch event.kind {
                    case 7: // Reaction
                        newActivities.append(ActivityItem(
                            type: .zap,
                            title: "Reacted to content",
                            time: Date(timeIntervalSince1970: TimeInterval(event.createdAt))
                        ))
                    case 9735: // Zap
                        let amount = extractZapAmount(from: event) ?? 0
                        newActivities.append(ActivityItem(
                            type: .zap,
                            title: "Zapped \(amount) sats",
                            time: Date(timeIntervalSince1970: TimeInterval(event.createdAt))
                        ))
                    case 9802: // Highlight
                        let preview = String(event.content.prefix(50))
                        newActivities.append(ActivityItem(
                            type: .highlight,
                            title: "Highlighted: \"\(preview)...\"",
                            time: Date(timeIntervalSince1970: TimeInterval(event.createdAt))
                        ))
                    case 30004: // Curation
                        if let name = event.tags.first(where: { $0.first == "name" })?.dropFirst().first {
                            newActivities.append(ActivityItem(
                                type: .curation,
                                title: "Created '\(name)'",
                                time: Date(timeIntervalSince1970: TimeInterval(event.createdAt))
                            ))
                        }
                    case 30023: // Article
                        if let title = event.tags.first(where: { $0.first == "title" })?.dropFirst().first {
                            newActivities.append(ActivityItem(
                                type: .article,
                                title: "Saved '\(title)'",
                                time: Date(timeIntervalSince1970: TimeInterval(event.createdAt))
                            ))
                        }
                    default:
                        break
                    }
                }
                
                await MainActor.run {
                    activities = newActivities
                }
            } catch {
                // Keep empty activities on error
            }
        }
    }
    
    private func extractZapAmount(from event: NDKEvent) -> Int? {
        // Extract zap amount from bolt11 tag
        if let bolt11Tag = event.tags.first(where: { $0.first == "bolt11" && $0.count > 1 }),
           bolt11Tag.count > 1 {
            let bolt11 = bolt11Tag[1]
            // Simple extraction - in production, use proper Lightning invoice parsing
            if let range = bolt11.range(of: "lnbc"),
               let endRange = bolt11.range(of: "1p", range: range.upperBound..<bolt11.endIndex) {
                let amountString = String(bolt11[range.upperBound..<endRange.lowerBound])
                if let amount = Int(amountString) {
                    return amount / 1000 // Convert millisats to sats
                }
            }
        }
        return nil
    }
}

struct ActivityCard: View {
    let activity: RecentActivitySection.ActivityItem
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.base) {
            ZStack {
                Circle()
                    .fill(activity.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.type.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(activity.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                Text(RelativeTimeFormatter.shortRelativeTime(from: activity.time))
                    .font(.system(size: 12))
                    .foregroundColor(.ds.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ds.surfaceSecondary)
        )
    }
}

struct EnhancedSavedHighlightsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showAllHighlights = false
    @State private var selectedSortOption = SortOption.recent
    
    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case popular = "Popular"
        case alphabetical = "A-Z"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Highlights")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("\(appState.highlights.count) highlights saved")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                }
                
                Spacer()
                
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { selectedSortOption = option }) {
                            Label(option.rawValue, systemImage: selectedSortOption == option ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.mini) {
                        Text(selectedSortOption.rawValue)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.ds.primary)
                    .padding(.horizontal, DesignSystem.Spacing.base)
                    .padding(.vertical, DesignSystem.Spacing.mini)
                    .background(
                        Capsule()
                            .fill(Color.ds.primary.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal)
            
            if appState.highlights.isEmpty {
                ModernEmptyState(
                    icon: "highlighter",
                    title: "No highlights yet",
                    message: "Start highlighting content to build your collection",
                    action: {},
                    actionTitle: "Create Highlight"
                )
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(appState.highlights.prefix(10)) { highlight in
                            LibraryHighlightCard(highlight: highlight)
                        }
                        
                        if appState.highlights.count > 10 {
                            ViewAllCard(count: appState.highlights.count - 10) {
                                showAllHighlights = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct LibraryHighlightCard: View {
    let highlight: HighlightEvent
    @State private var showDetail = false
    @State private var isBookmarked = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with source
                if let url = highlight.url {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.ds.primary)
                        
                        Text(ContentFormatter.extractDomain(from: url))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.ds.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            isBookmarked.toggle()
                            HapticManager.shared.impact(.light)
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14))
                                .foregroundColor(isBookmarked ? .ds.primary : .ds.textTertiary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Quote
                Text("\"\(highlight.content)\"")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.ds.text)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Footer
                HStack {
                    Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.ds.textSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: DesignSystem.Spacing.micro) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 16))
                        Text("View")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.ds.primary)
                }
            }
            .padding(DesignSystem.Spacing.large)
            .frame(width: 280, height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.ds.surface,
                                Color.ds.surfaceSecondary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.ds.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            HighlightDetailView(highlight: highlight)
        }
    }
}

struct ViewAllCard: View {
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(Color.ds.primary.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.ds.primary)
                }
                
                VStack(spacing: 4) {
                    Text("View All")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.ds.text)
                    
                    Text("+\(count) more")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                }
            }
            .frame(width: 140, height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ds.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
                            .foregroundColor(.ds.primary.opacity(0.3))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct SavedArticlesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Saved Articles")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.ds.text)
                .padding(.horizontal)
            
            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<5, id: \.self) { _ in
                    ArticleRow()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ArticleRow: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("The Future of Decentralized Social Media")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                
                Text("An exploration of how Nostr is changing social media")
                    .font(.system(size: 14))
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Label("5 min read", systemImage: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.ds.textTertiary)
                    
                    Label("12 highlights", systemImage: "highlighter")
                        .font(.system(size: 12))
                        .foregroundColor(.ds.primary)
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ds.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.ds.divider, lineWidth: 1)
        )
    }
}

struct EnhancedYourCurationsSection: View {
    let curations: [ArticleCuration]
    @Binding var showCreateCuration: Bool
    @Binding var selectedCuration: ArticleCuration?
    @Binding var showCurationManagement: Bool
    @State private var animateCards = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Collections")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("\(curations.count) curated collections")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: DesignSystem.Spacing.base) {
                    if !curations.isEmpty {
                        Button(action: { showCurationManagement = true }) {
                            Image(systemName: "folder.badge.gearshape")
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color.purple.opacity(0.1))
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: { showCreateCuration = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                            )
                            .symbolEffect(.bounce, value: showCreateCuration)
                    }
                }
            }
            .padding(.horizontal)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: curations.isEmpty)
            
            if curations.isEmpty {
                ModernEmptyState(
                    icon: "folder.badge.plus",
                    title: "No collections yet",
                    message: "Create curated collections of your favorite articles",
                    action: { showCreateCuration = true },
                    actionTitle: "Create First Collection"
                )
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(Array(curations.enumerated()), id: \.element.id) { index, curation in
                            EnhancedCurationCard(curation: curation)
                                .onTapGesture {
                                    selectedCuration = curation
                                    HapticManager.shared.impact(.light)
                                }
                                .scaleEffect(animateCards ? 1 : 0.8)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                    value: animateCards
                                )
                        }
                        
                        CreateCurationCard {
                            showCreateCuration = true
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    animateCards = true
                }
            }
        }
    }
}

struct EnhancedCurationCard: View {
    let curation: ArticleCuration
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image or gradient header
            ZStack(alignment: .topTrailing) {
                if let imageUrl = curation.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        GradientPlaceholder()
                    }
                    .frame(height: 140)
                    .clipped()
                } else {
                    GradientPlaceholder()
                        .frame(height: 140)
                }
                
                // Article count badge
                HStack(spacing: DesignSystem.Spacing.micro) {
                    Image(systemName: "doc.stack.fill")
                        .font(.system(size: 12))
                    Text("\(curation.articles.count)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.base)
                .padding(.vertical, DesignSystem.Spacing.mini)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.6))
                        .background(.ultraThinMaterial)
                )
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(curation.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                if let description = curation.description {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                } else {
                    Text("A curated collection")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                        .italic()
                }
                
                // Tags or metadata
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(["Featured", "Tech", "Insights"], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.1))
                            )
                    }
                }
                .padding(.top, 4)
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ds.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.ds.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct CreateCurationCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [8])
                        )
                        .foregroundColor(.purple.opacity(0.5))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.purple)
                }
                
                Text("New Collection")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.ds.text)
            }
            .frame(width: 160, height: 240)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.purple.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
                            .foregroundColor(.purple.opacity(0.3))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GradientPlaceholder: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.4),
                Color.purple.opacity(0.6)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear { animateGradient = true }
    }
}

struct EnhancedFollowPacksSection: View {
    let followPacks: [FollowPack]
    @Binding var selectedFollowPack: FollowPack?
    @State private var showDiscoverMore = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Follow Packs")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("Curated lists of people to follow")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                }
                
                Spacer()
                
                Button(action: { showDiscoverMore = true }) {
                    Text("Discover")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.ds.primary)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.ds.primary.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            
            if followPacks.isEmpty {
                ModernEmptyState(
                    icon: "person.3.sequence",
                    title: "No follow packs yet",
                    message: "Discover curated lists of interesting people to follow",
                    action: { showDiscoverMore = true },
                    actionTitle: "Explore Packs"
                )
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(followPacks) { pack in
                        EnhancedFollowPackRow(followPack: pack)
                            .onTapGesture {
                                selectedFollowPack = pack
                                HapticManager.shared.impact(.light)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct EnhancedFollowPackRow: View {
    let followPack: FollowPack
    @State private var profileImages: [String] = []
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Profile stack
            ZStack {
                ForEach(0..<min(3, followPack.profiles.count), id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.ds.primary.opacity(0.6),
                                    Color.ds.secondary.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(followPack.profiles[index].prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: CGFloat(index * 15))
                }
                
                if followPack.profiles.count > 3 {
                    Circle()
                        .fill(Color.ds.surfaceSecondary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("+\(followPack.profiles.count - 3)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.ds.text)
                        )
                        .offset(x: 45)
                }
            }
            .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(followPack.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.ds.text)
                
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Label("\(followPack.profiles.count) people", systemImage: "person.2")
                        .font(.system(size: 13))
                        .foregroundColor(.ds.textSecondary)
                    
                    if let description = followPack.description {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.ds.textTertiary)
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ds.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.ds.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}

// Add purple color extension if not already defined

#Preview {
    LibraryView()
        .environmentObject(AppState())
}
