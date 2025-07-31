import SwiftUI
import NDKSwift

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    // Auth manager is now accessed through appState
    @State private var selectedTab = Tab.home
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    enum Tab: CaseIterable {
        case home, feed, discover, library, profile
    }
    
    var body: some View {
        if !hasCompletedOnboarding || !appState.auth.isAuthenticated {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        } else {
            TabView(selection: $selectedTab) {
                SimplifiedHybridFeedView()
                    .tabItem {
                        Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                HighlightsFeedView()
                    .tabItem {
                        Image(systemName: selectedTab == .feed ? "play.rectangle.fill" : "play.rectangle")
                        Text("Feed")
                    }
                    .tag(Tab.feed)
                
                AdvancedSearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Discover")
                    }
                    .tag(Tab.discover)
                
                LibraryView()
                    .tabItem {
                        Image(systemName: selectedTab == .library ? "books.vertical.fill" : "books.vertical")
                        Text("Library")
                    }
                    .tag(Tab.library)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
            }
            .tint(DesignSystem.Colors.primary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
