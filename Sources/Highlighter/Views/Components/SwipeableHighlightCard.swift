import SwiftUI
import NDKSwift

struct SwipeableHighlightCard: View {
    let highlight: HighlightEvent
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onTap: () -> Void
    
    @EnvironmentObject var appState: AppState
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isDragging = false
    @State private var showLeftIcon = false
    @State private var showRightIcon = false
    @State private var hapticTriggered = false
    @State private var glowAnimation = false
    @State private var particleAnimation = false
    @State private var engagement: EngagementService.EngagementMetrics?
    
    // Gesture thresholds
    private let swipeThreshold: CGFloat = 120
    private let rotationFactor: Double = 0.001
    private let scaleFactor: CGFloat = 0.95
    
    var body: some View {
        ZStack {
            // Card content
            cardContent
                .offset(offset)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .gesture(dragGesture)
                .onTapGesture(perform: onTap)
            
            // Swipe indicators
            if isDragging {
                swipeIndicators
            }
            
            // Particle effects
            if particleAnimation {
                ParticleEffectView()
                    .allowsHitTesting(false)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: offset)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: rotation)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: scale)
        .onAppear {
            startGlowAnimation()
        }
        .task {
            await loadEngagement()
        }
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with author info
            HStack(spacing: 12) {
                ProfileImage(pubkey: highlight.author, size: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(PubkeyFormatter.formatCompact(highlight.author))
                        .font(.ds.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.ds.caption)
                        Text(RelativeTimeFormatter.shortRelativeTime(from: highlight.createdAt))
                            .font(.ds.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Menu button
                Menu {
                    Button(action: {
                        Task {
                            try? await appState.bookmarkService.toggleHighlightBookmark(highlight)
                            HapticManager.shared.impact(.light)
                        }
                    }) {
                        Label(appState.bookmarkService.isHighlightBookmarked(highlight.id) ? "Unsave" : "Save", 
                              systemImage: appState.bookmarkService.isHighlightBookmarked(highlight.id) ? "bookmark.fill" : "bookmark")
                    }
                    Button(action: {
                        shareHighlight()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        UIPasteboard.general.string = highlight.content
                        HapticManager.shared.impact(.light)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.ds.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(8)
                        .background(Circle().fill(DesignSystem.Colors.surfaceSecondary))
                }
            }
            
            // Highlight content with quote styling
            ZStack(alignment: .topLeading) {
                Text("\u{201C}")
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.15))
                    .offset(x: -8, y: -20)
                
                Text(highlight.content)
                    .font(.ds.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineSpacing(6)
                    .padding(.top, 8)
                    .background(
                        GeometryReader { geometry in
                            // Animated highlight effect
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DesignSystem.Colors.highlightSubtle.opacity(0.3))
                                .frame(width: glowAnimation ? geometry.size.width : 0)
                                .animation(
                                    .easeInOut(duration: 2)
                                    .delay(0.5),
                                    value: glowAnimation
                                )
                        }
                        .padding(.horizontal, -4)
                    )
            }
            
            // Context or source
            if let url = highlight.url {
                HStack(spacing: 6) {
                    Image(systemName: "link.circle.fill")
                        .font(.ds.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(ContentFormatter.extractDomain(from: url))
                        .font(.ds.footnote)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Engagement metrics
            HStack(spacing: 24) {
                if let metrics = engagement {
                    EngagementMetric(icon: "heart", value: metrics.likes, color: .red)
                    EngagementMetric(icon: "bubble.right", value: metrics.comments, color: .blue)
                    EngagementMetric(icon: "arrow.2.squarepath", value: metrics.reposts, color: .green)
                    EngagementMetric(icon: "bolt.fill", value: metrics.zaps, color: .orange)
                } else {
                    // Loading state
                    ForEach(0..<4) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                            .frame(width: 50, height: 20)
                            .shimmer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
                
                // Gradient overlay
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.05),
                        DesignSystem.Colors.secondary.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                // Border gradient
                RoundedRectangle(cornerRadius: 24, style: .continuous)
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
            }
        )
        .shadow(
            color: isDragging ? DesignSystem.Colors.primary.opacity(0.3) : DesignSystem.Shadow.large.color,
            radius: isDragging ? 30 : DesignSystem.Shadow.large.radius,
            y: isDragging ? 15 : DesignSystem.Shadow.large.y
        )
    }
    
    // MARK: - Swipe Indicators
    
    private var swipeIndicators: some View {
        ZStack {
            // Left swipe indicator (Archive/Hide)
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(showLeftIcon ? 0.2 : 0))
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                    
                    Image(systemName: "archivebox.fill")
                        .font(.ds.largeTitle)
                        .foregroundColor(Color.red)
                        .opacity(showLeftIcon ? 1 : 0)
                        .scaleEffect(showLeftIcon ? 1.2 : 0.8)
                }
                .offset(x: -40)
                
                Spacer()
            }
            
            // Right swipe indicator (Save/Bookmark)
            HStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(showRightIcon ? 0.2 : 0))
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                    
                    Image(systemName: "bookmark.fill")
                        .font(.ds.largeTitle)
                        .foregroundColor(Color.green)
                        .opacity(showRightIcon ? 1 : 0)
                        .scaleEffect(showRightIcon ? 1.2 : 0.8)
                }
                .offset(x: 40)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showLeftIcon)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showRightIcon)
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Update position
                offset = value.translation
                rotation = Double(value.translation.width) * rotationFactor * 20
                
                // Scale effect
                if !isDragging {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isDragging = true
                        scale = scaleFactor
                    }
                }
                
                // Show swipe indicators
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showLeftIcon = value.translation.width < -50
                    showRightIcon = value.translation.width > 50
                }
                
                // Haptic feedback at threshold
                if abs(value.translation.width) > swipeThreshold && !hapticTriggered {
                    HapticManager.shared.impact(.medium)
                    hapticTriggered = true
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    if value.translation.width < -swipeThreshold {
                        // Swipe left - Archive
                        offset = CGSize(width: -UIScreen.main.bounds.width * 1.5, height: 0)
                        rotation = -30
                        HapticManager.shared.notification(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeLeft()
                        }
                    } else if value.translation.width > swipeThreshold {
                        // Swipe right - Save
                        offset = CGSize(width: UIScreen.main.bounds.width * 1.5, height: 0)
                        rotation = 30
                        HapticManager.shared.notification(.success)
                        triggerParticleEffect()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeRight()
                        }
                    } else {
                        // Return to center
                        offset = .zero
                        rotation = 0
                    }
                    
                    // Reset states
                    isDragging = false
                    scale = 1.0
                    showLeftIcon = false
                    showRightIcon = false
                    hapticTriggered = false
                }
            }
    }
    
    // MARK: - Helper Methods
    
    private func startGlowAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            glowAnimation = true
        }
    }
    
    private func triggerParticleEffect() {
        particleAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particleAnimation = false
        }
    }
    
    private func loadEngagement() async {
        let metrics = await appState.engagementService.fetchEngagement(for: highlight.id)
        
        await MainActor.run {
            self.engagement = metrics
        }
    }
    
    private func shareHighlight() {
        let activityVC = UIActivityViewController(
            activityItems: [highlight.content],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        
        HapticManager.shared.impact(.light)
    }
}

// MARK: - Supporting Views

struct EngagementMetric: View {
    let icon: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.ds.body)
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.ds.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let color: Color
        var opacity: Double = 1.0
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                size: CGFloat.random(in: 4...12),
                color: [Color.green, Color.blue, Color.purple, Color.orange].randomElement()!
            )
        }
    }
    
    private func animateParticles() {
        for index in particles.indices {
            withAnimation(.easeOut(duration: 1.5)) {
                particles[index].x += CGFloat.random(in: -150...150)
                particles[index].y += CGFloat.random(in: -150...150)
                particles[index].opacity = 0
            }
        }
    }
}

// MARK: - Card Stack View

struct SwipeableCardStack: View {
    @EnvironmentObject var appState: AppState
    @State private var currentIndex = 0
    @State private var showDetail = false
    @State private var selectedHighlight: HighlightEvent?
    
    var body: some View {
        ZStack {
            ForEach(Array(appState.highlights.enumerated()), id: \.offset) { index, highlight in
                if index >= currentIndex && index < currentIndex + 3 {
                    SwipeableHighlightCard(
                        highlight: highlight,
                        onSwipeRight: {
                            saveHighlight(highlight)
                            nextCard()
                        },
                        onSwipeLeft: {
                            archiveHighlight(highlight)
                            nextCard()
                        },
                        onTap: {
                            selectedHighlight = highlight
                            showDetail = true
                        }
                    )
                    .offset(y: CGFloat(index - currentIndex) * 10)
                    .scaleEffect(1 - CGFloat(index - currentIndex) * 0.05)
                    .opacity(index == currentIndex ? 1 : 0.8)
                    .zIndex(Double(appState.highlights.count - index))
                }
            }
            
            if appState.highlights.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("No highlights to swipe")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            if let highlight = selectedHighlight {
                NavigationView {
                    HighlightDetailView(highlight: highlight)
                }
            }
        }
    }
    
    private func nextCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentIndex += 1
        }
    }
    
    private func saveHighlight(_ highlight: HighlightEvent) {
        Task {
            do {
                // Toggle bookmark
                try await appState.bookmarkService.toggleHighlightBookmark(highlight)
                
                // Show success feedback
                HapticManager.shared.notification(.success)
            } catch {
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func archiveHighlight(_ highlight: HighlightEvent) {
        Task {
            do {
                try await appState.archiveService.archiveHighlight(highlight)
                HapticManager.shared.notification(.success)
            } catch {
                HapticManager.shared.notification(.error)
                // Archive failed - error feedback provided via haptics
            }
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemBackground)
            .ignoresSafeArea()
        
        SwipeableCardStack()
            .padding()
    }
    .environmentObject(AppState())
}