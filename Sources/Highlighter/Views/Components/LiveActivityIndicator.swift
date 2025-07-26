import SwiftUI
import NDKSwift

struct LiveActivityIndicator: View {
    @EnvironmentObject var appState: AppState
    @State private var activities: [LiveActivity] = []
    @State private var isExpanded = false
    @State private var pulseAnimation = false
    @State private var newActivityAnimation = false
    @State private var currentActivityIndex = 0
    @State private var autoRotateTimer: Timer?
    
    struct LiveActivity: Identifiable {
        let id = UUID()
        let type: ActivityType
        let user: String
        let content: String
        let timestamp: Date
        
        enum ActivityType {
            case highlight, comment, zap, follow, repost
            
            var icon: String {
                switch self {
                case .highlight: return "highlighter"
                case .comment: return "bubble.left.fill"
                case .zap: return "bolt.fill"
                case .follow: return "person.badge.plus.fill"
                case .repost: return "arrow.2.squarepath"
                }
            }
            
            var color: Color {
                switch self {
                case .highlight: return .orange
                case .comment: return .blue
                case .zap: return .yellow
                case .follow: return .purple
                case .repost: return .green
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            if isExpanded {
                expandedView
            } else {
                compactView
            }
        }
        .onAppear {
            startAnimations()
            loadMockActivities()
            startAutoRotation()
        }
        .onDisappear {
            autoRotateTimer?.invalidate()
        }
    }
    
    // MARK: - Compact View
    
    private var compactView: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded = true
                HapticManager.shared.impact(.light)
            }
        }) {
            ZStack {
                // Pulsing background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.3),
                                DesignSystem.Colors.primary.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                    .opacity(pulseAnimation ? 0 : 0.6)
                    .animation(
                        .easeOut(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.4), radius: 10, y: 5)
                
                // Activity icon
                if !activities.isEmpty {
                    Image(systemName: activities[currentActivityIndex].type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .scale(scale: 1.5).combined(with: .opacity)
                        ))
                        .id("activity-\(currentActivityIndex)")
                }
                
                // Activity count badge
                if activities.count > 1 {
                    Text("\(activities.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.red))
                        .offset(x: 20, y: -20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Live indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 20, y: 20)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0.8 : 1.0)
                    .animation(
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Expanded View
    
    private var expandedView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )
                    
                    Text("Live Activity")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = false
                        HapticManager.shared.impact(.light)
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(8)
                        .background(Circle().fill(DesignSystem.Colors.surfaceSecondary))
                }
            }
            .padding(DesignSystem.Spacing.medium)
            
            Divider()
            
            // Activity list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                        ActivityRow(activity: activity)
                            .transition(.asymmetric(
                                insertion: .push(from: .top).combined(with: .opacity),
                                removal: .push(from: .bottom).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.05),
                                value: activities.count
                            )
                        
                        if index < activities.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.large.color, radius: DesignSystem.Shadow.large.radius)
        )
        .frame(width: 320)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(DesignSystem.Colors.divider, lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func startAnimations() {
        pulseAnimation = true
    }
    
    private func loadMockActivities() {
        // Simulate live activities
        activities = [
            LiveActivity(
                type: .highlight,
                user: "Alice",
                content: "highlighted your article",
                timestamp: Date()
            ),
            LiveActivity(
                type: .zap,
                user: "Bob",
                content: "zapped your highlight",
                timestamp: Date().addingTimeInterval(-60)
            ),
            LiveActivity(
                type: .comment,
                user: "Charlie",
                content: "commented on your highlight",
                timestamp: Date().addingTimeInterval(-180)
            ),
            LiveActivity(
                type: .follow,
                user: "David",
                content: "started following you",
                timestamp: Date().addingTimeInterval(-300)
            ),
            LiveActivity(
                type: .repost,
                user: "Eve",
                content: "reposted your highlight",
                timestamp: Date().addingTimeInterval(-600)
            )
        ]
        
        // Simulate new activities
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            addNewActivity()
        }
    }
    
    private func startAutoRotation() {
        autoRotateTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            if !isExpanded && !activities.isEmpty {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentActivityIndex = (currentActivityIndex + 1) % activities.count
                }
            }
        }
    }
    
    private func addNewActivity() {
        let types: [LiveActivity.ActivityType] = [.highlight, .comment, .zap, .follow, .repost]
        let users = ["Frank", "Grace", "Henry", "Iris", "Jack"]
        let actions = [
            "highlighted your article",
            "commented on your highlight",
            "zapped your content",
            "started following you",
            "reposted your highlight"
        ]
        
        let randomType = types.randomElement()!
        let randomUser = users.randomElement()!
        let randomAction = actions[types.firstIndex(of: randomType)!]
        
        let newActivity = LiveActivity(
            type: randomType,
            user: randomUser,
            content: randomAction,
            timestamp: Date()
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            activities.insert(newActivity, at: 0)
            if activities.count > 10 {
                activities.removeLast()
            }
            newActivityAnimation = true
        }
        
        HapticManager.shared.notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            newActivityAnimation = false
        }
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let activity: LiveActivityIndicator.LiveActivity
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(activity.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activity.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(activity.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(activity.user)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(activity.content)
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Text(RelativeTimeFormatter.shortRelativeTime(from: activity.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            // Action button
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.impact(.light)
        }
    }
}

// MARK: - Floating Position Modifier

struct FloatingActivityModifier: ViewModifier {
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false
    
    func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            // Snap to edges
                            let screenWidth = UIScreen.main.bounds.width
                            let threshold = screenWidth / 2
                            
                            if value.location.x < threshold {
                                dragOffset.width = -screenWidth / 2 + 80
                            } else {
                                dragOffset.width = screenWidth / 2 - 80
                            }
                            
                            // Keep vertical position
                            dragOffset.height = value.translation.height
                        }
                    }
            )
            .scaleEffect(isDragging ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDragging)
    }
}

// MARK: - Live Activity Widget

struct LiveActivityWidget: View {
    var body: some View {
        LiveActivityIndicator()
            .modifier(FloatingActivityModifier())
            .position(x: UIScreen.main.bounds.width - 40, y: 200)
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemBackground)
            .ignoresSafeArea()
        
        LiveActivityWidget()
    }
    .environmentObject(AppState())
}