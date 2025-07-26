import SwiftUI
import NDKSwift

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var authManager = NDKAuthManager.shared
    @State private var selectedTab = Tab.home
    @State private var tabBarVisible = true
    @State private var showCreateHighlight = false
    @State private var fabScale: CGFloat = 1.0
    @State private var fabRotation: Double = 0
    @State private var tabTransition: AnyTransition = .identity
    @State private var contentOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showTabSwitchAnimation = false
    @State private var tabSwitchProgress: CGFloat = 0
    @State private var activeTabGlow: CGFloat = 0
    @State private var navigationHapticTriggered = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    enum Tab: CaseIterable {
        case home, feed, discover, library, profile
    }
    
    var body: some View {
        if !hasCompletedOnboarding || !authManager.isAuthenticated {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        } else {
            ZStack(alignment: .bottom) {
                // Content with custom transitions
                ZStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Group {
                            switch tab {
                            case .home:
                                SimplifiedHybridFeedView()
                            case .feed:
                                TimelineFeedView()
                            case .discover:
                                SearchView()
                            case .library:
                                LibraryView()
                            case .profile:
                                EnhancedProfileView()
                            }
                        }
                        .opacity(selectedTab == tab ? 1 : 0)
                        .scaleEffect(selectedTab == tab ? 1 : 0.92)
                        .offset(x: offsetForTab(tab), y: selectedTab == tab ? 0 : 10)
                        .blur(radius: selectedTab == tab ? 0 : 3)
                        .rotation3DEffect(
                            .degrees(selectedTab == tab ? 0 : 5),
                            axis: (x: 1, y: 0, z: 0),
                            perspective: 0.5
                        )
                        .allowsHitTesting(selectedTab == tab)
                        .transition(transitionForTab(tab))
                        .zIndex(selectedTab == tab ? 1 : 0)
                    }
                }
                .animation(
                    .interactiveSpring(
                        response: 0.45,
                        dampingFraction: 0.75,
                        blendDuration: 0.25
                    ),
                    value: selectedTab
                )
                .background(
                    // Ambient glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.3 * activeTabGlow),
                                    DesignSystem.Colors.secondary.opacity(0.2 * activeTabGlow),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 50)
                        .offset(y: -100)
                        .allowsHitTesting(false)
                )
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                    ) {
                        activeTabGlow = 1
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if abs(value.translation.width) > threshold {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    if value.translation.width > 0 {
                                        // Swipe right - go to previous tab
                                        switchToPreviousTab()
                                    } else {
                                        // Swipe left - go to next tab
                                        switchToNextTab()
                                    }
                                }
                            }
                            dragOffset = 0
                        }
                )
                
                // Live Activity Indicator (floating)
                if selectedTab == .home || selectedTab == .feed {
                    LiveActivityWidget()
                        .zIndex(100)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: contentAppeared)
                }
                
                if tabBarVisible {
                    VStack(spacing: 0) {
                        // Floating Action Button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                HapticManager.shared.impact(.medium)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    fabScale = 1.2
                                    fabRotation += 180
                                    showTabSwitchAnimation = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        fabScale = 1.0
                                    }
                                }
                                showCreateHighlight = true
                                showTabSwitchAnimation = true
                            }) {
                                ZStack {
                                    // Outer glow
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    DesignSystem.Colors.secondary.opacity(0.4),
                                                    DesignSystem.Colors.secondary.opacity(0)
                                                ],
                                                center: .center,
                                                startRadius: 20,
                                                endRadius: 40
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                        .blur(radius: 10)
                                        .opacity(fabScale > 1 ? 1 : 0.6)
                                    
                                    // Gradient background
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [DesignSystem.Colors.secondary, DesignSystem.Colors.secondary.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                    
                                    // Shadow layers for depth
                                    Circle()
                                        .fill(DesignSystem.Colors.secondary.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                        .blur(radius: 8)
                                        .offset(y: 4)
                                    
                                    // Icon with enhanced animation
                                    ZStack {
                                        Image(systemName: "highlighter")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(fabRotation))
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                        
                                        // Particle burst on tap
                                        if showTabSwitchAnimation {
                                            ForEach(0..<8, id: \.self) { index in
                                                Circle()
                                                    .fill(DesignSystem.Colors.secondary)
                                                    .frame(width: 4, height: 4)
                                                    .offset(
                                                        x: showTabSwitchAnimation ? cos(CGFloat(index) * .pi / 4) * 30 : 0,
                                                        y: showTabSwitchAnimation ? sin(CGFloat(index) * .pi / 4) * 30 : 0
                                                    )
                                                    .opacity(showTabSwitchAnimation ? 0 : 1)
                                                    .animation(
                                                        .easeOut(duration: 0.6)
                                                        .delay(Double(index) * 0.02),
                                                        value: showTabSwitchAnimation
                                                    )
                                            }
                                        }
                                    }
                                }
                                .scaleEffect(fabScale)
                                .rotation3DEffect(
                                    .degrees(fabScale > 1 ? 10 : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                            }
                            .padding(.trailing, DesignSystem.Spacing.large)
                            .padding(.bottom, DesignSystem.Spacing.medium)
                            .shadow(color: DesignSystem.Colors.secondary.opacity(0.4), radius: DesignSystem.Shadow.medium.radius, x: DesignSystem.Shadow.medium.x, y: DesignSystem.Shadow.medium.y)
                        }
                        
                        EnhancedTabBar(selectedTab: $selectedTab)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(DesignSystem.Animation.springSnappy, value: tabBarVisible)
                }
            }
            .background(DesignSystem.Colors.background)
            .fullScreenCover(isPresented: $showCreateHighlight) {
                CreateHighlightView()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func offsetForTab(_ tab: Tab) -> CGFloat {
        guard selectedTab != tab else { return 0 }
        
        let currentIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
        let tabIndex = Tab.allCases.firstIndex(of: tab) ?? 0
        let indexDifference = tabIndex - currentIndex
        
        return CGFloat(indexDifference) * 20 + dragOffset * 0.3
    }
    
    private func transitionForTab(_ tab: Tab) -> AnyTransition {
        let currentIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
        let tabIndex = Tab.allCases.firstIndex(of: tab) ?? 0
        
        if tabIndex < currentIndex {
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        } else {
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        }
    }
    
    private func switchToNextTab() {
        let currentIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
        let nextIndex = (currentIndex + 1) % Tab.allCases.count
        
        // Trigger advanced transition
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            tabSwitchProgress = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = Tab.allCases[nextIndex]
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                tabSwitchProgress = 0
            }
        }
        
        if !navigationHapticTriggered {
            HapticManager.shared.impact(.light)
            navigationHapticTriggered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                navigationHapticTriggered = false
            }
        }
    }
    
    private func switchToPreviousTab() {
        let currentIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : Tab.allCases.count - 1
        
        // Trigger advanced transition
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            tabSwitchProgress = -1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = Tab.allCases[previousIndex]
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                tabSwitchProgress = 0
            }
        }
        
        if !navigationHapticTriggered {
            HapticManager.shared.impact(.light)
            navigationHapticTriggered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                navigationHapticTriggered = false
            }
        }
    }
}

// MARK: - Tab Extensions

extension ContentView.Tab {
    var icon: String {
        switch self {
        case .home: return "house"
        case .feed: return "play.rectangle"
        case .discover: return "magnifyingglass"
        case .library: return "books.vertical"
        case .profile: return "person"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .home: return "house.fill"
        case .feed: return "play.rectangle.fill"
        case .discover: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .feed: return "Feed"
        case .discover: return "Discover"
        case .library: return "Library"
        case .profile: return "Profile"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
