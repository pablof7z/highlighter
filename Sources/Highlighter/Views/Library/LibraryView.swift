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
    @State private var sortOption = SortOption.newest
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case alphabetical = "A-Z"
        case mostHighlighted = "Most Highlighted"
        
        var systemImage: String {
            switch self {
            case .newest: return "arrow.down"
            case .oldest: return "arrow.up"
            case .alphabetical: return "textformat.abc"
            case .mostHighlighted: return "star.fill"
            }
        }
    }
    
    enum FilterTab: String, CaseIterable {
        case all = "All"
        case highlights = "Highlights"
        case curations = "Collections"
        case articles = "Articles"
        case archived = "Archived"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .highlights: return "pencil.tip"
            case .curations: return "books.vertical"
            case .articles: return "doc.text"
            case .archived: return "archivebox"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Unified gradient background
                UnifiedGradientBackground(style: .subtle)
                
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
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedFilter = tab
                                            HapticManager.shared.impact(.light)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: tab.icon)
                                                .font(.ds.body, weight: .medium))
                                            Text(tab.rawValue)
                                        }
                                        .unifiedTabPill(isSelected: selectedFilter == tab)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
                                SavedHighlightsSection()
                            case .curations:
                                YourCurationsSection(
                                    curations: sortedCurations,
                                    showCreateCuration: $showCreateCuration,
                                    selectedCuration: $selectedCuration,
                                    showCurationManagement: $showCurationManagement
                                )
                            case .articles:
                                SavedArticlesSection(sortOption: sortOption)
                            case .archived:
                                ArchivedContentSection()
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
                        
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    withAnimation {
                                        sortOption = option
                                    }
                                    HapticManager.shared.impact(.light)
                                }) {
                                    Label(option.rawValue, systemImage: option.systemImage)
                                }
                            }
                        } label: {
                            Label("Sort: \(sortOption.rawValue)", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button(action: { 
                            exportLibrary()
                        }) {
                            Label("Export Library", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.ds.headline))
                            .foregroundColor(.ds.text)
                            .frame(width: 44, height: 44)
                    }
                }
            }
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
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner else { return }
        
        do {
            let pubkey = try await signer.pubkey
            let filter = NDKFilter(
                authors: [pubkey],
                kinds: [9802], // NIP-84 highlights
                limit: 100
            )
            
            let dataSource = await ndk.outbox.observe(
                filter: filter,
                maxAge: 300 // 5 minute cache
            )
            
            var highlights: [HighlightEvent] = []
            for await event in dataSource.events {
                if let highlight = try? HighlightEvent(from: event) {
                    highlights.append(highlight)
                }
            }
            
            await MainActor.run {
                appState.highlights = highlights.sorted { $0.createdAt > $1.createdAt }
            }
        } catch {
        }
    }
    
    private func loadCurations() async {
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner else { return }
        
        do {
            let pubkey = try await signer.pubkey
            let filter = NDKFilter(
                authors: [pubkey],
                kinds: [30004], // Article curations
                limit: 50
            )
            
            let dataSource = await ndk.outbox.observe(
                filter: filter,
                maxAge: 300 // 5 minute cache
            )
            
            var curations: [ArticleCuration] = []
            for await event in dataSource.events {
                if let curation = try? ArticleCuration(from: event) {
                    curations.append(curation)
                }
            }
            
            await MainActor.run {
                appState.userCurations = curations.sorted { $0.createdAt > $1.createdAt }
            }
        } catch {
        }
    }
    
    private func loadArticles() async {
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner else { return }
        
        do {
            let pubkey = try await signer.pubkey
            let filter = NDKFilter(
                authors: [pubkey],
                kinds: [30023], // Long-form articles
                limit: 50
            )
            
            let dataSource = await ndk.outbox.observe(
                filter: filter,
                maxAge: 300 // 5 minute cache
            )
            
            var articles: [Article] = []
            for await event in dataSource.events {
                if let article = try? Article(from: event) {
                    articles.append(article)
                }
            }
            
            await MainActor.run {
                appState.savedArticles = articles.sorted { $0.createdAt > $1.createdAt }
            }
        } catch {
        }
    }
    
    private func loadActivity() async {
        // Activity is loaded in RecentActivitySection component
        // This method can be used for additional activity loading if needed
    }
    
    // MARK: - Export Functions
    
    private func exportLibrary() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        
        var exportContent = "# Highlighter Library Export\n\n"
        exportContent += "Date: \(date)\n\n"
        
        // Export highlights
        exportContent += "## Highlights (\(appState.highlights.count))\n\n"
        let sortedHighlights = appState.highlights.sorted { $0.createdAt > $1.createdAt }
        for highlight in sortedHighlights {
            exportContent += "### \(RelativeTimeFormatter.fullDate(from: highlight.createdAt))\n"
            exportContent += "> \(highlight.content)\n\n"
            if let url = highlight.url {
                exportContent += "Source: \(url)\n\n"
            }
            exportContent += "---\n\n"
        }
        
        // Export articles
        exportContent += "## Saved Articles (\(appState.savedArticles.count))\n\n"
        let sortedArticles = appState.savedArticles.sorted { $0.createdAt > $1.createdAt }
        for article in sortedArticles {
            exportContent += "### \(article.title)\n"
            if let summary = article.summary {
                exportContent += "\(summary)\n\n"
            }
            exportContent += "---\n\n"
        }
        
        // Export curations
        exportContent += "## Collections (\(appState.userCurations.count))\n\n"
        for curation in appState.userCurations {
            exportContent += "### \(curation.title)\n"
            if let description = curation.description {
                exportContent += "\(description)\n\n"
            }
            exportContent += "Articles: \(curation.articles.count)\n\n"
            exportContent += "---\n\n"
        }
        
        // Share the exported content
        let filename = "highlighter-export-\(date).md"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try exportContent.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityController = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityController, animated: true)
            }
            
            HapticManager.shared.notification(.success)
        } catch {
            // Handle export error
            HapticManager.shared.notification(.error)
        }
    }
    
    // MARK: - Computed Properties
    
    private var sortedCurations: [ArticleCuration] {
        switch sortOption {
        case .newest:
            return appState.userCurations.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return appState.userCurations.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical:
            return appState.userCurations.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .mostHighlighted:
            return appState.userCurations.sorted { $0.articles.count > $1.articles.count }
        }
    }
    
    @ViewBuilder
    private var allContentView: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            // Recent Activity
            RecentActivitySection()
            
            // Saved highlights
            SavedHighlightsSection()
            
            // Your curations
            YourCurationsSection(
                curations: sortedCurations,
                showCreateCuration: $showCreateCuration,
                selectedCuration: $selectedCuration,
                showCurationManagement: $showCurationManagement
            )
            
            // Follow packs
            FollowPacksSection(
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
                    .font(.ds.title, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                // Activity indicator - removed hardcoded streak
                if appState.highlights.count > 0 {
                    HStack(spacing: DesignSystem.Spacing.mini) {
                        Image(systemName: "sparkles")
                            .font(.ds.body))
                            .foregroundColor(.ds.primary)
                        Text("Active")
                            .font(.ds.callout, weight: .medium))
                            .foregroundColor(.ds.primary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.base)
                    .padding(.vertical, DesignSystem.Spacing.mini)
                    .background(
                        Capsule()
                            .fill(Color.ds.primary.opacity(0.15))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Stats grid
            HStack(spacing: 16) {
                UnifiedStatCard(
                    value: "\(appState.highlights.count)",
                    label: "Highlights",
                    icon: "pencil.tip",
                    color: .ds.primary
                )
                
                UnifiedStatCard(
                    value: "\(appState.curations.count)",
                    label: "Collections",
                    icon: "books.vertical",
                    color: .ds.primary
                )
                
                UnifiedStatCard(
                    value: "\(appState.savedArticles.count)",
                    label: "Articles",
                    icon: "doc.text",
                    color: .ds.primary
                )
            }
        }
        .padding(20)
        .unifiedCard()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateStats = true
            }
        }
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
                    .font(.ds.title3, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.ds.callout, weight: .medium))
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
                    .font(.ds.title3, weight: .medium))
                    .foregroundColor(activity.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.ds.callout, weight: .medium))
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                Text(RelativeTimeFormatter.shortRelativeTime(from: activity.time))
                    .font(.ds.caption))
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

struct SavedHighlightsSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showAllHighlights = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Highlights")
                        .font(.ds.title3, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("\(appState.highlights.count) highlights saved")
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            if appState.highlights.isEmpty {
                UnifiedEmptyState(
                    icon: "pencil.tip",
                    title: "No highlights yet",
                    message: "Start highlighting content to build your collection"
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
    
    private var sortedHighlights: [HighlightEvent] {
        // Simple sort by date for now
        return appState.highlights.sorted { $0.createdAt > $1.createdAt }
    }
}

struct LibraryHighlightCard: View {
    let highlight: HighlightEvent
    @State private var showDetail = false
    @State private var isBookmarked = false
    
    var body: some View {
        UnifiedCard(
            variant: .compact,
            action: { showDetail = true }
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with source
                if let url = highlight.url {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "link.circle.fill")
                            .font(.ds.callout))
                            .foregroundColor(.ds.primary)
                        
                        Text(ContentFormatter.extractDomain(from: url))
                            .font(.ds.caption, weight: .medium))
                            .foregroundColor(.ds.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            isBookmarked.toggle()
                            HapticManager.shared.impact(.light)
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.ds.callout))
                                .foregroundColor(isBookmarked ? .ds.primary : .ds.textTertiary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Quote
                Text("\"\(highlight.content)\"")
                    .font(.ds.body, weight: .medium))
                    .foregroundColor(.ds.text)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Footer
                HStack {
                    Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                        .font(.ds.caption))
                        .foregroundColor(.ds.textSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: DesignSystem.Spacing.micro) {
                        Image(systemName: "arrow.right.circle")
                            .font(.ds.body))
                        Text("View")
                            .font(.ds.caption, weight: .medium))
                    }
                    .foregroundColor(.ds.primary)
                }
            }
            .frame(height: 140)
        }
        .sheet(isPresented: $showDetail) {
            HighlightDetailView(highlight: highlight)
        }
    }
}

struct ViewAllCard: View {
    let count: Int
    let action: () -> Void
    
    var body: some View {
        UnifiedCard(
            variant: .placeholder,
            action: action
        ) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(Color.ds.primary.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.ds.largeTitle))
                        .foregroundColor(.ds.primary)
                }
                
                VStack(spacing: 4) {
                    Text("View All")
                        .font(.ds.body, weight: .semibold))
                        .foregroundColor(.ds.text)
                    
                    Text("+\(count) more")
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                }
            }
            .frame(width: 100, height: 140)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .foregroundColor(.ds.primary.opacity(0.3))
        )
    }
}


struct SavedArticlesSection: View {
    @EnvironmentObject var appState: AppState
    @State private var highlightCounts: [String: Int] = [:]
    let sortOption: LibraryView.SortOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Saved Articles")
                .font(.ds.title2, weight: .bold, design: .rounded))
                .foregroundColor(.ds.text)
                .padding(.horizontal)
            
            if appState.savedArticles.isEmpty {
                UnifiedEmptyState(
                    icon: "doc.text",
                    title: "No saved articles yet",
                    message: "Save articles to read them later"
                )
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(appState.savedArticles) { article in
                        ArticleRow(
                            article: article,
                            highlightCount: highlightCounts[article.id] ?? 0
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            loadHighlightCounts()
        }
    }
    
    private func loadHighlightCounts() {
        Task {
            guard let ndk = appState.ndk else { return }
            
            for article in appState.savedArticles {
                let filter = NDKFilter(
                    kinds: [9802],
                    limit: 100,
                    tags: ["a": ["30023:\(article.author):\(article.identifier ?? "")"]]
                )
                
                let dataSource = await ndk.outbox.observe(
                    filter: filter,
                    maxAge: 300,
                    cachePolicy: .cacheOnly
                )
                
                var count = 0
                for await _ in dataSource.events {
                    count += 1
                }
                
                await MainActor.run {
                    highlightCounts[article.id] = count
                }
            }
        }
    }
    
    private var sortedArticles: [Article] {
        // Simple sort by date for now
        return appState.savedArticles.sorted { $0.createdAt > $1.createdAt }
    }
}

struct ArticleRow: View {
    let article: Article
    let highlightCount: Int
    @State private var showArticleDetail = false
    @EnvironmentObject var appState: AppState
    
    private var readingProgress: ReadingProgressService.ArticleProgress? {
        appState.readingProgressService.getProgress(for: article.id)
    }
    
    var body: some View {
        Button(action: { showArticleDetail = true }) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                // Article image or gradient
                Group {
                    if let imageUrl = article.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ArticleImagePlaceholder()
                        }
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                    } else {
                        ArticleImagePlaceholder()
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.ds.body, weight: .semibold))
                        .foregroundColor(.ds.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let summary = article.summary {
                        Text(summary)
                            .font(.ds.callout))
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        if let readingTime = ArticleTimeEstimator.estimateReadingTime(for: article.content) {
                            Label("\(readingTime) min read", systemImage: "clock")
                                .font(.ds.caption))
                                .foregroundColor(.ds.textTertiary)
                        }
                        
                        // Reading progress
                        if let progress = readingProgress, progress.progress > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: progress.progress >= 1.0 ? "checkmark.circle.fill" : "book.fill")
                                    .font(.ds.caption2))
                                    .foregroundColor(progress.progress >= 1.0 ? .green : .ds.primary)
                                Text(progress.progress >= 1.0 ? "Completed" : "\(Int(progress.progress * 100))%")
                                    .font(.ds.caption, weight: .medium))
                                    .foregroundColor(progress.progress >= 1.0 ? .green : .ds.primary)
                            }
                        }
                        
                        Label(highlightCount > 0 ? "\(highlightCount) highlights" : "No highlights", 
                              systemImage: "highlighter")
                            .font(.ds.caption))
                            .foregroundColor(highlightCount > 0 ? .ds.primary : .ds.textTertiary)
                    }
                }
                
                Spacer()
            }
            .modernCard(noPadding: true, isInteractive: true)
            .overlay(
                // Reading progress bar at the bottom
                GeometryReader { geometry in
                    if let progress = readingProgress, progress.progress > 0 && progress.progress < 1.0 {
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress.progress, height: 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .animation(.spring(response: 0.3), value: progress.progress)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)
                    }
                }
                .allowsHitTesting(false)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showArticleDetail) {
            ArticleView(article: article)
        }
    }
}

struct ArticleImagePlaceholder: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct YourCurationsSection: View {
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
                        .font(.ds.title3, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("\(curations.count) curated collections")
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                }
                Spacer()
            }
                
                Spacer()
                
                HStack(spacing: DesignSystem.Spacing.base) {
                    if !curations.isEmpty {
                        Button(action: { showCurationManagement = true }) {
                            Image(systemName: "folder.badge.gearshape")
                                .font(.ds.body))
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
                            .font(.ds.largeTitle))
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
            .padding(.horizontal)
            
            if curations.isEmpty {
                UnifiedEmptyState(
                    icon: "books.vertical",
                    title: "No collections yet",
                    message: "Create curated collections of your favorite articles"
                )
                .onTapGesture { showCreateCuration = true }
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(Array(curations.enumerated()), id: \.element.id) { index, curation in
                            CurationCard(curation: curation)
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

struct CurationCard: View {
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
                        .font(.ds.caption))
                    Text("\(curation.articles.count)")
                        .font(.ds.callout, weight: .bold))
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
                    .font(.ds.headline, weight: .bold))
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                if let description = curation.description {
                    Text(description)
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                } else {
                    Text("A curated collection")
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                        .italic()
                }
                
                // Article count indicator
                HStack(spacing: DesignSystem.Spacing.small) {
                    Label("\(curation.articles.count) articles", systemImage: "doc.text")
                        .font(.ds.caption, weight: .medium))
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text(RelativeTimeFormatter.shortRelativeTime(from: curation.updatedAt))
                        .font(.ds.caption2))
                        .foregroundColor(.ds.textTertiary)
                }
                .padding(.top, 4)
            }
            .padding(DesignSystem.Spacing.medium)
        }
        .frame(width: 260)
        .modernCard(noPadding: true, isInteractive: true)
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
                        .font(.ds.title, weight: .medium))
                        .foregroundColor(.purple)
                }
                
                Text("New Collection")
                    .font(.ds.body, weight: .semibold))
                    .foregroundColor(.ds.text)
            }
            .frame(width: 160, height: 240)
            .modernCard(noPadding: true, isInteractive: true)
            .background(Color.purple.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8])
                    )
                    .foregroundColor(.purple.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GradientPlaceholder: View {
    var body: some View {
        UnifiedGradientBackground(style: .immersive)
    }
}

struct FollowPacksSection: View {
    let followPacks: [FollowPack]
    @Binding var selectedFollowPack: FollowPack?
    @State private var showDiscoverMore = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Follow Packs")
                        .font(.ds.title3, weight: .bold, design: .rounded))
                        .foregroundColor(.ds.text)
                    
                    Text("Curated lists of people to follow")
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            if followPacks.isEmpty {
                UnifiedEmptyState(
                    icon: "person.3.sequence",
                    title: "No follow packs yet",
                    message: "Discover curated lists of interesting people to follow"
                )
                .onTapGesture { showDiscoverMore = true }
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(followPacks) { pack in
                        FollowPackRow(followPack: pack)
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

struct FollowPackRow: View {
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
                                .font(.ds.body, weight: .bold))
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
                                .font(.ds.callout, weight: .bold))
                                .foregroundColor(.ds.text)
                        )
                        .offset(x: 45)
                }
            }
            .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(followPack.title)
                    .font(.ds.body, weight: .semibold))
                    .foregroundColor(.ds.text)
                
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Label("\(followPack.profiles.count) people", systemImage: "person.2")
                        .font(.ds.footnote))
                        .foregroundColor(.ds.textSecondary)
                    
                    if let description = followPack.description {
                        Text(description)
                            .font(.ds.footnote))
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.ds.callout))
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

// MARK: - Archived Content Section

struct ArchivedContentSection: View {
    @EnvironmentObject var appState: AppState
    @State private var showArchivedHighlights = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Archived Content")
                .font(.ds.title2, weight: .bold, design: .rounded))
                .foregroundColor(.ds.text)
                .padding(.horizontal)
            
            // Toggle between highlights and articles
            Picker("Content Type", selection: $showArchivedHighlights) {
                Text("Highlights").tag(true)
                Text("Articles").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if showArchivedHighlights {
                if appState.archiveService.archivedHighlights.isEmpty {
                    UnifiedEmptyState(
                        icon: UnifiedIcons.Features.archive,
                        title: "No archived highlights",
                        message: "Swipe left on highlights to archive them for later"
                    )
                    .padding(.horizontal)
                } else {
                    LazyVStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(Array(appState.archiveService.archivedHighlights.values)) { highlight in
                            ArchivedHighlightCard(highlight: highlight)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                if appState.archiveService.archivedArticles.isEmpty {
                    UnifiedEmptyState(
                        icon: UnifiedIcons.Features.archive,
                        title: "No archived articles",
                        message: "Archive articles to declutter your library"
                    )
                    .padding(.horizontal)
                } else {
                    LazyVStack(spacing: DesignSystem.Spacing.medium) {
                        ForEach(Array(appState.archiveService.archivedArticles.values)) { article in
                            ArchivedArticleCard(article: article)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ArchivedHighlightCard: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    // Quote content
                    Text("\"\(highlight.content)\"")
                        .font(.ds.body, weight: .medium))
                        .foregroundColor(.ds.text)
                        .lineLimit(isExpanded ? nil : 3)
                    
                    // Source
                    if let url = highlight.url {
                        HStack(spacing: 6) {
                            Image(systemName: "link.circle.fill")
                                .font(.ds.caption))
                                .foregroundColor(.ds.primary)
                            
                            Text(ContentFormatter.extractDomain(from: url))
                                .font(.ds.caption))
                                .foregroundColor(.ds.primary)
                        }
                    }
                    
                    // Timestamp
                    Text("Archived \(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))")
                        .font(.ds.caption))
                        .foregroundColor(.ds.textSecondary)
                }
                
                Spacer()
                
                // Actions
                Menu {
                    Button(action: {
                        Task {
                            try? await appState.archiveService.unarchiveHighlight(highlight.id)
                            HapticManager.shared.impact(.light)
                        }
                    }) {
                        Label("Unarchive", systemImage: "arrow.uturn.backward")
                    }
                    
                    Button(action: {
                        showDetail = true
                    }) {
                        Label("View Details", systemImage: "eye")
                    }
                    
                    Button(role: .destructive, action: {
                        Task {
                            // Remove from archive
                            try? await appState.archiveService.unarchiveHighlight(highlight.id)
                            // Publish deletion event via NIP-09
                            try? await PublishingService.shared.deleteHighlight(highlight.id)
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.ds.body))
                        .foregroundColor(.ds.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.ds.surface.opacity(0.5))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.ds.border, lineWidth: 1)
        )
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
        .sheet(isPresented: $showDetail) {
            HighlightDetailView(highlight: highlight)
        }
    }
}

struct ArchivedArticleCard: View {
    let article: Article
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Article info
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.ds.body, weight: .semibold))
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                
                if let summary = article.summary {
                    Text(summary)
                        .font(.ds.callout))
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
                
                Text("Archived \(RelativeTimeFormatter.relativeTime(from: article.publishedAt ?? Date()))")
                    .font(.ds.caption))
                    .foregroundColor(.ds.textTertiary)
            }
            
            Spacer()
            
            // Actions
            Menu {
                Button(action: {
                    Task {
                        try? await appState.archiveService.unarchiveArticle(article.id)
                        HapticManager.shared.impact(.light)
                    }
                }) {
                    Label("Unarchive", systemImage: "arrow.uturn.backward")
                }
                
                Button(action: {
                    showDetail = true
                }) {
                    Label("Read", systemImage: "book")
                }
                
                Button(role: .destructive, action: {
                    Task {
                        // Remove from archive
                        try? await appState.archiveService.unarchiveArticle(article.id)
                        // Publish deletion event via NIP-09
                        try? await PublishingService.shared.deleteArticle(article.id)
                    }
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.ds.body))
                    .foregroundColor(.ds.textSecondary)
            }
        }
        .padding()
        .background(Color.ds.surface.opacity(0.5))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.ds.border, lineWidth: 1)
        )
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            ArticleView(article: article)
        }
    }
}

// Add purple color extension if not already defined

#Preview {
    LibraryView()
        .environmentObject(AppState())
}
