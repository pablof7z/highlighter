import SwiftUI
import Charts

struct EngagementVisualization: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeRange = TimeRange.week
    @State private var engagementData: [EngagementDataPoint] = []
    @State private var animateChart = false
    @State private var selectedMetric: MetricType = .all
    @State private var showInsights = false
    @State private var hoveredDataPoint: EngagementDataPoint?
    
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
            case .all: return .purple
            case .likes: return .red
            case .comments: return .blue
            case .zaps: return .orange
            case .reposts: return .green
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
                        ))
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
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Engagement Analytics")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Track your content performance")
                        .font(.system(size: 16))
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
                            .font(.system(size: 14))
                        Text("Insights")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(showInsights ? .white : DesignSystem.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(showInsights ? DesignSystem.Colors.primary : DesignSystem.Colors.primary.opacity(0.1))
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
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
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
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                        
                        // Points
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", animateChart ? dataPoint.value(for: selectedMetric) : 0)
                        )
                        .foregroundStyle(.white)
                        .symbolSize(hoveredDataPoint?.id == dataPoint.id ? 100 : 60)
                        .annotation(position: .top) {
                            if hoveredDataPoint?.id == dataPoint.id {
                                VStack(spacing: 4) {
                                    Text("\(dataPoint.value(for: selectedMetric))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(selectedMetric.color)
                                    
                                    Text(dataPoint.date, style: .time)
                                        .font(.system(size: 12))
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DesignSystem.Colors.surface)
                                        .shadow(radius: 4)
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .chartYScale(domain: 0...maxChartValue)
                    .chartXAxis {
                        AxisMarks(preset: .aligned) { value in
                            AxisValueLabel()
                                .font(.system(size: 12))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel()
                                .font(.system(size: 12))
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
                    color: .purple
                )
                
                AnimatedMetricCard(
                    title: "Avg. per Highlight",
                    value: averageEngagement,
                    change: 0.15,
                    icon: "divide.circle.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                AnimatedMetricCard(
                    title: "Best Performing",
                    value: bestPerformingCount,
                    change: 0.32,
                    icon: "trophy.fill",
                    color: .orange
                )
                
                AnimatedMetricCard(
                    title: "Growth Rate",
                    value: growthRate,
                    change: growthRateChange,
                    icon: "arrow.up.right.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("AI-Powered Insights")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                InsightCard(
                    icon: "lightbulb.fill",
                    title: "Peak Engagement Times",
                    description: "Your highlights get 3x more engagement when posted between 2-4 PM EST",
                    color: .yellow
                )
                
                InsightCard(
                    icon: "person.2.fill",
                    title: "Top Audience",
                    description: "Tech enthusiasts and Bitcoin community members engage most with your content",
                    color: .blue
                )
                
                InsightCard(
                    icon: "quote.bubble.fill",
                    title: "Content Recommendation",
                    description: "Philosophical quotes receive 45% more zaps than technical content",
                    color: .purple
                )
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
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(0..<5) { index in
                        TrendingHighlightCard(index: index)
                            .frame(width: 280)
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
    
    private func loadEngagementData() {
        // Generate mock data based on time range
        let dataPoints: Int
        switch selectedTimeRange {
        case .day: dataPoints = 24
        case .week: dataPoints = 7
        case .month: dataPoints = 30
        case .year: dataPoints = 12
        }
        
        engagementData = (0..<dataPoints).map { index in
            let date = Date().addingTimeInterval(-Double(index) * 3600 * (selectedTimeRange == .day ? 1 : 24))
            return EngagementDataPoint(
                date: date,
                likes: Int.random(in: 10...100),
                comments: Int.random(in: 5...50),
                zaps: Int.random(in: 20...200),
                reposts: Int.random(in: 2...30)
            )
        }.reversed()
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
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
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
                    .font(.system(size: 14))
                Text(metric.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : metric.color)
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(showValue ? 0 : -180))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showValue)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 12, weight: .bold))
                    Text("\(Int(abs(change * 100)))%")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(change > 0 ? .green : .red)
            }
            
            Text("\(animatedValue)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.text)
                .contentTransition(.numericText())
                .opacity(showValue ? 1 : 0)
                .offset(y: showValue ? 0 : 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.small.color, radius: DesignSystem.Shadow.small.radius)
        )
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
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DesignSystem.Colors.surface)
        )
    }
}

struct TrendingHighlightCard: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Text("#\(index + 1)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                Label("\(Int.random(in: 100...500))", systemImage: "flame.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
            }
            
            Text("The future belongs to those who believe in the beauty of their dreams.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.text)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    Text("\(Int.random(in: 50...200))")
                        .font(.system(size: 12))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text("\(Int.random(in: 10...50))")
                        .font(.system(size: 12))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(Int.random(in: 100...1000))")
                        .font(.system(size: 12))
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