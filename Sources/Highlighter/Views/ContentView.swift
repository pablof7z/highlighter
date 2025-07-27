import SwiftUI
import NDKSwift

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var authManager = NDKAuthManager.shared
    @State private var selectedTab = Tab.home
    @State private var tabBarVisible = true
    @State private var tabTransition: AnyTransition = .identity
    @State private var contentOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showTabSwitchAnimation = false
    @State private var tabSwitchProgress: CGFloat = 0
    @State private var activeTabGlow: CGFloat = 0
    @State private var navigationHapticTriggered = false
    @State private var contentAppeared = false
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
                                HybridFeedView()
                            case .feed:
                                HighlightsFeedView(tabBarVisible: $tabBarVisible)
                            case .discover:
                                AdvancedSearchView()
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
                // Add padding to prevent content from going under tab bar
                .padding(.bottom, tabBarVisible ? 88 : 0)
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
                        .easeInOut(duration: 4)
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
                
                
                if tabBarVisible {
                    VStack(spacing: 0) {
                        
                        EnhancedTabBar(selectedTab: $selectedTab)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(DesignSystem.Animation.springSnappy, value: tabBarVisible)
                }
            }
            .background(DesignSystem.Colors.background)
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
