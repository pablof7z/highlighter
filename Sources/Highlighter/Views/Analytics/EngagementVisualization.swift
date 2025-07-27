import SwiftUI
import Charts
import NDKSwift

struct EngagementVisualization: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeRange = TimeRange.week
    @State private var engagementData: [EngagementDataPoint] = []
    @State private var animateChart = false
    @State private var selectedMetric: MetricType = .all
    @State private var showInsights = false
    @State private var hoveredDataPoint: EngagementDataPoint?
    @State private var trendingHighlights: [HighlightEvent] = []
    
    enum TimeRange: String, CaseIterable {
        case day = "24h"
        case week = "7d"
        case month = "30d"
        case year = "1y"
        
        var title: String {
            switch self {
            case .day: return "Last 24 Hours"
            case .week: return "Last 7 Days"
            case .month: return "Last 30 Days"
            case .year: return "Last Year"
            }
        }
    }
    
    enum MetricType: String, CaseIterable {
        case all = "All"
        case likes = "Likes"
        case comments = "Comments"
        case zaps = "Zaps"
        case reposts = "Reposts"
        
        var color: Color {
            switch self {
            case .all: return DesignSystem.Colors.primary
            case .likes: return DesignSystem.Colors.error
            case .comments: return DesignSystem.Colors.primary
            case .zaps: return DesignSystem.Colors.secondary
            case .reposts: return DesignSystem.Colors.success
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "chart.line.uptrend.xyaxis"
            case .likes: return "heart.fill"
            case .comments: return "bubble.right.fill"
            case .zaps: return "bolt.fill"
            case .reposts: return "arrow.2.squarepath"
            }
        }
    }
    
    struct EngagementDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let likes: Int
        let comments: Int
        let zaps: Int
        let reposts: Int
        
        var total: Int {
            likes + comments + zaps + reposts
        }
        
        func value(for metric: MetricType) -> Int {
            switch metric {
            case .all: return total
            case .likes: return likes
            case .comments: return comments
            case .zaps: return zaps
            case .reposts: return reposts
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header with controls
                headerSection
                
                // Main chart
                chartSection
                    .frame(height: 300)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                
                // Metric cards
                metricCardsSection
                    .padding(.horizontal, DesignSystem.Spacing.large)
                
                // Insights section
                if showInsights {
                    insightsSection
                        .padding(.horizontal, DesignSystem.Spacing.large)
                        .transition(.asymmetric(
                            insertion: .push(from: .bottom).combined(with: .opacity),
                            removal: .push(from: .top).combined(with: .opacity)
                        )
                }
                
                // Trending highlights
                trendingHighlightsSection
            }
            .padding(.vertical, DesignSystem.Spacing.large)
        }
        .background(DesignSystem.Colors.background)
        .onAppear {
            loadEngagementData()
            startAnimations()
            loadTrendingHighlights()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Engagement Analytics")
                        .font(.ds.title, weight: .bold, design: .rounded)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Track your content performance")
                        .font(.ds.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showInsights.toggle()
                        HapticManager.shared.impact(.light)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.ds.callout)
                        Text("Insights")
                            .font(.ds.callout).fontWeight(.medium)
                    }
                    .foregroundColor(showInsights ? Color.white : DesignSystem.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(showInsights ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.1)
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            // Time range selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        TimeRangeButton(
                            range: range,
                            isSelected: selectedTimeRange == range,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedTimeRange = range
                                    loadEngagementData()
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Metric selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        MetricButton(
                            metric: metric,
                            isSelected: selectedMetric == metric,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedMetric = metric
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        )
                    }
                }
            }
            
            // Chart
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        selectedMetric.color.opacity(0.1),
                        selectedMetric.color.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)
                
                if !engagementData.isEmpty {
                    Chart(engagementData) { dataPoint in
                        // Area chart
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", animateChart ? dataPoint.value(for: selectedMetric) : 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    selectedMetric.color.opacity(0.6),
                                    selectedMetric.color.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        // Line chart
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", animateChart ? dataPoint.value(for: selectedMetric) : 0)
                        )
                        .foregroundStyle(selectedMetric.color)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        .interpolationMethod(.catmullRom)
                        
                        // Points
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", animateChart ? dataPoint.value(for: selectedMetric) : 0)
                        )
                        .foregroundStyle(Color.white)
                        .symbolSize(hoveredDataPoint?.id == dataPoint.id ? 100 : 60)
                        .annotation(position: .top) {
                            if hoveredDataPoint?.id == dataPoint.id {
                                VStack(spacing: 4) {
                                    Text("\(dataPoint.value(for: selectedMetric))")
                                        .font(.ds.callout).fontWeight(.bold)
                                        .foregroundColor(selectedMetric.color)
                                    
                                    Text(dataPoint.date, style: .time)
                                        .font(.ds.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DesignSystem.Colors.surface)
                                        .shadow(radius: 4)
                                )
                                .transition(.scale.combined(with: .opacity)
                            }
                        }
                    }
                    .chartYScale(domain: 0...maxChartValue)
                    .chartXAxis {
                        AxisMarks(preset: .aligned) { value in
                            AxisValueLabel()
                                .font(.ds.caption)
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel()
                                .font(.ds.caption)
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                            
                            AxisGridLine()
                                .foregroundStyle(DesignSystem.Colors.divider.opacity(0.5))
                        }
                    }
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animateChart)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedMetric)
                    .onTapGesture { location in
                        // Handle tap to show data point details
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
                    .shadow(color: DesignSystem.Shadow.medium.color, radius: DesignSystem.Shadow.medium.radius)
            )
        }
    }
    
    // MARK: - Metric Cards
    
    private var metricCardsSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                AnimatedMetricCard(
                    title: "Total Engagement",
                    value: totalEngagement,
                    change: engagementChange,
                    icon: "chart.line.uptrend.xyaxis",
                    color: DesignSystem.Colors.primary
                )
                
                AnimatedMetricCard(
                    title: "Avg. per Highlight",
                    value: averageEngagement,
                    change: 0.15,
                    icon: "divide.circle.fill",
                    color: DesignSystem.Colors.primary
                )
            }
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                AnimatedMetricCard(
                    title: "Best Performing",
                    value: bestPerformingCount,
                    change: 0.32,
                    icon: "trophy.fill",
                    color: DesignSystem.Colors.secondary
                )
                
                AnimatedMetricCard(
                    title: "Growth Rate",
                    value: growthRate,
                    change: growthRateChange,
                    icon: "arrow.up.right.circle.fill",
                    color: DesignSystem.Colors.success
                )
            }
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Engagement Insights")
                .font(.ds.title3).fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                // Peak engagement time based on actual data
                if let peakHour = calculatePeakEngagementHour() {
                    InsightCard(
                        icon: "lightbulb.fill",
                        title: "Peak Engagement Time",
                        description: "Your highlights get the most engagement around \(formatHour(peakHour))",
                        color: DesignSystem.Colors.warning
                    )
                }
                
                // Average engagement metrics
                if averageEngagement > 0 {
                    InsightCard(
                        icon: "chart.bar.fill",
                        title: "Average Engagement",
                        description: "Each highlight receives an average of \(averageEngagement) interactions",
                        color: DesignSystem.Colors.primary
                    )
                }
                
                // Growth trend
                if growthRate != 0 {
                    InsightCard(
                        icon: growthRate > 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill",
                        title: "Engagement Trend",
                        description: growthRate > 0 ? "Your engagement is up \(abs(growthRate))% compared to the previous period" : "Your engagement is down \(abs(growthRate))% compared to the previous period",
                        color: growthRate > 0 ? DesignSystem.Colors.success : DesignSystem.Colors.secondary
                    )
                }
                
                // Best performing content type (if we have enough data)
                if bestPerformingCount > 0 {
                    InsightCard(
                        icon: "trophy.fill",
                        title: "High Performers",
                        description: "\(bestPerformingCount) of your highlights performed exceptionally well",
                        color: DesignSystem.Colors.primary
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.05),
                            DesignSystem.Colors.secondary.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Trending Highlights
    
    private var trendingHighlightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Trending Highlights")
                    .font(.ds.title2).fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.ds.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    if trendingHighlights.isEmpty {
                        ForEach(0..<3) { index in
                            TrendingHighlightPlaceholder(index: index)
                                .frame(width: 280)
                        }
                    } else {
                        ForEach(Array(trendingHighlights.prefix(10).enumerated()), id: \.element.id) { index, highlight in
                            RealTrendingHighlightCard(index: index, highlight: highlight)
                                .frame(width: 280)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var maxChartValue: Int {
        engagementData.map { $0.value(for: selectedMetric) }.max() ?? 100
    }
    
    private var totalEngagement: Int {
        engagementData.reduce(0) { $0 + $1.total }
    }
    
    private var averageEngagement: Int {
        guard !engagementData.isEmpty else { return 0 }
        return totalEngagement / engagementData.count
    }
    
    private var bestPerformingCount: Int {
        engagementData.filter { $0.total > averageEngagement * 2 }.count
    }
    
    private var growthRate: Int {
        guard engagementData.count >= 2 else { return 0 }
        let recent = engagementData.suffix(engagementData.count / 2).reduce(0) { $0 + $1.total }
        let past = engagementData.prefix(engagementData.count / 2).reduce(0) { $0 + $1.total }
        return past > 0 ? Int(((Double(recent) / Double(past)) - 1) * 100) : 0
    }
    
    private var engagementChange: Double {
        guard engagementData.count >= 2 else { return 0 }
        let current = engagementData.last?.total ?? 0
        let previous = engagementData.dropLast().last?.total ?? 1
        return Double(current - previous) / Double(previous)
    }
    
    private var growthRateChange: Double {
        growthRate > 0 ? 0.01 * Double(growthRate) : -0.01 * Double(abs(growthRate))
    }
    
    // MARK: - Helper Methods
    
    private func calculatePeakEngagementHour() -> Int? {
        guard !engagementData.isEmpty else { return nil }
        
        // Group engagement by hour of day
        var hourlyEngagement: [Int: Int] = [:]
        
        for dataPoint in engagementData {
            let hour = Calendar.current.component(.hour, from: dataPoint.date)
            hourlyEngagement[hour, default: 0] += dataPoint.total
        }
        
        // Find the hour with maximum engagement
        return hourlyEngagement.max(by: { $0.value < $1.value })?.key
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date)
    }
    
    private func loadEngagementData() {
        Task {
            guard let ndk = appState.ndk, let signer = appState.activeSigner else { return }
            
            do {
                let pubkey = try await signer.pubkey
                
                // Calculate time interval based on selected range
                let now = Date()
                let startDate: Date
                switch selectedTimeRange {
                case .day:
                    startDate = now.addingTimeInterval(-86400) // 24 hours
                case .week:
                    startDate = now.addingTimeInterval(-604800) // 7 days
                case .month:
                    startDate = now.addingTimeInterval(-2592000) // 30 days
                case .year:
                    startDate = now.addingTimeInterval(-31536000) // 365 days
                }
                
                // Fetch user's highlights to analyze engagement
                let highlightFilter = NDKFilter(
                    authors: [pubkey],
                    kinds: [9802], // NIP-84 highlights
                    since: Int64(startDate.timeIntervalSince1970),
                    limit: 500
                )
                
                let highlightDataSource = await ndk.outbox.observe(
                    filter: highlightFilter,
                    maxAge: 300,
                    cachePolicy: .cacheWithNetwork
                )
                
                var highlights: [NDKEvent] = []
                for await event in highlightDataSource.events {
                    highlights.append(event)
                }
                
                // Now fetch reactions for these highlights
                var dataPoints: [Date: EngagementDataPoint] = [:]
                
                // Initialize data points based on time range
                let interval: TimeInterval
                let bucketCount: Int
                
                switch selectedTimeRange {
                case .day:
                    interval = 3600 // 1 hour buckets
                    bucketCount = 24
                case .week:
                    interval = 86400 // 1 day buckets
                    bucketCount = 7
                case .month:
                    interval = 86400 // 1 day buckets
                    bucketCount = 30
                case .year:
                    interval = 2592000 // 30 day buckets
                    bucketCount = 12
                }
                
                // Initialize buckets
                for i in 0..<bucketCount {
                    let bucketDate = now.addingTimeInterval(-Double(i) * interval)
                    let normalizedDate = Date(timeIntervalSince1970: floor(bucketDate.timeIntervalSince1970 / interval) * interval)
                    dataPoints[normalizedDate] = EngagementDataPoint(
                        date: normalizedDate,
                        likes: 0,
                        comments: 0,
                        zaps: 0,
                        reposts: 0
                    )
                }
                
                // For each highlight, get its engagement
                for highlight in highlights {
                    let highlightDate = Date(timeIntervalSince1970: Double(highlight.createdAt))
                    let bucketDate = Date(timeIntervalSince1970: floor(highlightDate.timeIntervalSince1970 / interval) * interval)
                    
                    // Fetch reactions for this highlight
                    var tagsFilter: [String: Set<String>] = [:]
                    tagsFilter["e"] = [highlight.id]
                    
                    let reactionFilter = NDKFilter(
                        kinds: [7], // Reactions
                        limit: 1000,
                        tags: tagsFilter
                    )
                    
                    let reactionDataSource = await ndk.outbox.observe(
                        filter: reactionFilter,
                        maxAge: 300,
                        cachePolicy: .cacheWithNetwork
                    )
                    
                    var likes = 0
                    for await reaction in reactionDataSource.events {
                        if reaction.content == "🤙" || reaction.content == "+" || reaction.content == "❤️" {
                            likes += 1
                        }
                    }
                    
                    // Count replies (kind 1 with e tag)
                    let replyFilter = NDKFilter(
                        kinds: [1], // Text notes
                        limit: 100,
                        tags: tagsFilter
                    )
                    
                    let replyDataSource = await ndk.outbox.observe(
                        filter: replyFilter,
                        maxAge: 300,
                        cachePolicy: .cacheWithNetwork
                    )
                    
                    var comments = 0
                    for await _ in replyDataSource.events {
                        comments += 1
                    }
                    
                    // Count reposts
                    let repostFilter = NDKFilter(
                        kinds: [6], // Reposts
                        limit: 100,
                        tags: tagsFilter
                    )
                    
                    let repostDataSource = await ndk.outbox.observe(
                        filter: repostFilter,
                        maxAge: 300,
                        cachePolicy: .cacheWithNetwork
                    )
                    
                    var reposts = 0
                    for await _ in repostDataSource.events {
                        reposts += 1
                    }
                    
                    // Count zaps (kind 9735)
                    let zapFilter = NDKFilter(
                        kinds: [9735], // Zap receipts
                        limit: 100,
                        tags: tagsFilter
                    )
                    
                    let zapDataSource = await ndk.outbox.observe(
                        filter: zapFilter,
                        maxAge: 300,
                        cachePolicy: .cacheWithNetwork
                    )
                    
                    var zaps = 0
                    for await _ in zapDataSource.events {
                        zaps += 1
                    }
                    
                    // Update the data point
                    if var dataPoint = dataPoints[bucketDate] {
                        dataPoint = EngagementDataPoint(
                            date: dataPoint.date,
                            likes: dataPoint.likes + likes,
                            comments: dataPoint.comments + comments,
                            zaps: dataPoint.zaps + zaps,
                            reposts: dataPoint.reposts + reposts
                        )
                        dataPoints[bucketDate] = dataPoint
                    }
                }
                
                // Convert to array and sort by date
                let sortedData = dataPoints.values.sorted { $0.date < $1.date }
                
                await MainActor.run {
                    self.engagementData = sortedData
                }
                
            } catch {
                // If we can't load real data, show empty state
                await MainActor.run {
                    self.engagementData = []
                }
            }
        }
    }
    
    private func loadTrendingHighlights() {
        Task {
            guard let ndk = appState.ndk else { return }
            
            // Fetch recent highlights with high engagement
            let filter = NDKFilter(
                kinds: [9802],
                since: Timestamp(Date().addingTimeInterval(-7 * 24 * 60 * 60).timeIntervalSince1970),
                limit: 50
            )
            
            let dataSource = await ndk.outbox.observe(
                filter: filter,
                maxAge: CachePolicies.shortTerm,
                cachePolicy: .cacheWithNetwork
            )
            
            var highlights: [HighlightEvent] = []
            
            for await event in dataSource.events {
                if let highlight = try? HighlightEvent(from: event) {
                    highlights.append(highlight)
                }
            }
            
            // Sort by engagement (approximated by recent creation time for now)
            let sortedHighlights = highlights.sorted { $0.createdAt > $1.createdAt }
            
            await MainActor.run {
                self.trendingHighlights = Array(sortedHighlights.prefix(10))
            }
        }
    }
    
    private func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animateChart = true
            }
        }
    }
}

// MARK: - Supporting Views

struct TimeRangeButton: View {
    let range: EngagementVisualization.TimeRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(range.rawValue)
                .font(.ds.callout, weight: isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.white : DesignSystem.Colors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.surfaceSecondary)
                )
        }
    }
}

struct MetricButton: View {
    let metric: EngagementVisualization.MetricType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: metric.icon)
                    .font(.ds.callout)
                Text(metric.rawValue)
                    .font(.ds.callout).fontWeight(.medium)
            }
            .foregroundColor(isSelected ? Color.white : metric.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? metric.color : metric.color.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(metric.color, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
    }
}

struct AnimatedMetricCard: View {
    let title: String
    let value: Int
    let change: Double
    let icon: String
    let color: Color
    
    @State private var animatedValue: Int = 0
    @State private var showValue = false
    
    var body: some View {
        UnifiedCard(variant: .standard) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                HStack {
                    Image(systemName: icon)
                        .font(.ds.title3)
                        .foregroundColor(color)
                        .rotationEffect(.degrees(showValue ? 0 : -180))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showValue)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.ds.caption).fontWeight(.bold)
                        Text("\(Int(abs(change * 100)))%")
                            .font(.ds.caption).fontWeight(.bold)
                    }
                    .foregroundColor(change > 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                }
                
                Text("\(animatedValue)")
                    .font(.ds.title, weight: .bold, design: .rounded)
                    .foregroundColor(DesignSystem.Colors.text)
                    .contentTransition(.numericText())
                    .opacity(showValue ? 1 : 0)
                    .offset(y: showValue ? 0 : 20)
                
                Text(title)
                    .font(.ds.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedValue = value
                showValue = true
            }
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        UnifiedCard(variant: .standard) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: icon)
                    .font(.ds.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.ds.body).fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(description)
                        .font(.ds.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
    }
}

struct TrendingHighlightPlaceholder: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("#\(index + 1)")
                    .font(.ds.callout, weight: .bold, design: .rounded)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(width: 60, height: 16)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(width: 180, height: 16)
            }
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                        .frame(width: 50, height: 14)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
        .redacted(reason: .placeholder)
    }
}

struct RealTrendingHighlightCard: View {
    let index: Int
    let highlight: HighlightEvent
    @State private var reactions: [String: Int] = [:]
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("#\(index + 1)")
                    .font(.ds.callout, weight: .bold, design: .rounded)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                Label("Trending", systemImage: "flame.fill")
                    .font(.ds.caption).fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
            
            Text(highlight.content)
                .font(.ds.body).fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.text)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(PubkeyFormatter.formatCompact(highlight.author))
                    .font(.ds.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("·")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                    .font(.ds.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                Spacer()
                
                if highlight.context != nil {
                    Image(systemName: "text.bubble")
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
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

#Preview {
    NavigationStack {
        EngagementVisualization()
            .environmentObject(AppState())
    }
}