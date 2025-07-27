import SwiftUI
import NDKSwift
import PhotosUI

struct EnhancedProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = ProfileTab.highlights
    @State private var userHighlights: [HighlightEvent] = []
    @State private var userCurations: [ArticleCuration] = []
    @State private var isLoading = true
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var showFollowers = false
    @State private var showFollowing = false
    @State private var headerOffset: CGFloat = 0
    @State private var profileHeaderHeight: CGFloat = 300
    @State private var currentPubkey: String = ""
    
    // Stats animation
    @State private var animateStats = false
    @State private var statsValues = StatsValues()
    
    // Profile editing
    @State private var editedProfile = EditableProfile()
    
    enum ProfileTab: String, CaseIterable {
        case highlights = "Highlights"
        case curations = "Curations"
        case activity = "Activity"
        
        var icon: String {
            switch self {
            case .highlights: return "highlighter"
            case .curations: return "books.vertical"
            case .activity: return "bolt.heart"
            }
        }
    }
    
    struct StatsValues {
        var highlights: Int = 0
        var curations: Int = 0
        var followers: Int = 0
        var following: Int = 0
        var zapsReceived: Int = 0
    }
    
    struct EditableProfile {
        var displayName: String = ""
        var about: String = ""
        var picture: String = ""
        var banner: String = ""
        var website: String = ""
        var nip05: String = ""
        var lud16: String = ""
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Parallax header
                            profileHeader
                                .offset(y: headerOffset > 0 ? -headerOffset : 0)
                                .scaleEffect(headerOffset > 0 ? 1 + headerOffset / 500 : 1)
                            
                            // Content
                            VStack(spacing: .ds.large) {
                                // Enhanced stats with animations
                                animatedStatsView
                                
                                // Modern tab selector
                                modernTabSelector
                                
                                // Tab content
                                tabContent
                                    .transition(.asymmetric(
                                        insertion: .push(from: .trailing).combined(with: .opacity),
                                        removal: .push(from: .leading).combined(with: .opacity)
                                    ))
                            }
                            .padding(.top, .ds.medium)
                            .background(
                                DesignSystem.Colors.background
                                    .clipShape(
                                        UnevenRoundedRectangle(
                                            topLeadingRadius: 32,
                                            topTrailingRadius: 32
                                        )
                                    )
                                    .ignoresSafeArea(edges: .bottom)
                                    .shadow(color: .black.opacity(0.1), radius: 20, y: -10)
                            )
                        }
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        headerOffset = value
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if headerOffset < -100 {
                        Text(appState.currentUserProfile?.displayName ?? "Profile")
                            .font(.ds.headline)
                            .transition(.opacity)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showEditProfile = true }) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.ds.text)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .magneticHover()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.ds.text)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .magneticHover()
                    }
                }
            }
            .refreshable {
                await loadUserContent()
            }
        }
        .task {
            if let signer = appState.activeSigner {
                do {
                    currentPubkey = try await signer.pubkey
                } catch {
                    print("Failed to get pubkey: \(error)")
                }
            }
            await loadUserContent()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: $editedProfile, onSave: saveProfile)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showFollowers) {
            FollowersListView(pubkey: currentPubkey)
        }
        .sheet(isPresented: $showFollowing) {
            FollowingListView(pubkey: currentPubkey)
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Banner image with gradient overlay
            if let banner = appState.currentUserProfile?.banner,
               let url = URL(string: banner) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: profileHeaderHeight)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0),
                                    Color.black.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } placeholder: {
                    bannerPlaceholder
                }
            } else {
                bannerPlaceholder
            }
            
            // Profile info overlay
            VStack(spacing: .ds.medium) {
                // Avatar with edit button
                ZStack(alignment: .bottomTrailing) {
                    if let picture = appState.currentUserProfile?.picture,
                       let url = URL(string: picture) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .shadow(radius: 10)
                        } placeholder: {
                            avatarPlaceholder
                        }
                    } else {
                        avatarPlaceholder
                    }
                    
                    // Verified badge if NIP-05
                    if appState.currentUserProfile?.nip05 != nil {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, Color.blue)
                            .background(Circle().fill(Color.white).frame(width: 28, height: 28))
                            .offset(x: 5, y: 5)
                    }
                }
                
                // Name and bio
                VStack(spacing: .ds.small) {
                    Text(appState.currentUserProfile?.displayName ?? "Anonymous")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let nip05 = appState.currentUserProfile?.nip05 {
                        Label(nip05, systemImage: "checkmark.seal")
                            .font(.ds.callout)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if let about = appState.currentUserProfile?.about {
                        Text(about)
                            .font(.ds.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, .ds.large)
                    }
                }
            }
            .padding(.bottom, .ds.large)
        }
        .frame(height: profileHeaderHeight)
    }
    
    private var bannerPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated pattern
            GeometryReader { geo in
                ForEach(0..<5) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .offset(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .blur(radius: 30)
                        .animation(
                            .easeInOut(duration: Double.random(in: 10...20))
                            .repeatForever(autoreverses: true),
                            value: animateStats
                        )
                }
            }
        }
        .frame(height: profileHeaderHeight)
    }
    
    private var avatarPlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(radius: 10)
    }
    
    // MARK: - Stats View
    
    private var animatedStatsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .ds.medium) {
                AnimatedStatCard(
                    value: statsValues.highlights,
                    label: "Highlights",
                    icon: "highlighter",
                    color: .orange,
                    animate: animateStats
                )
                
                AnimatedStatCard(
                    value: statsValues.curations,
                    label: "Curations",
                    icon: "books.vertical.fill",
                    color: .purple,
                    animate: animateStats
                )
                
                AnimatedStatCard(
                    value: statsValues.followers,
                    label: "Followers",
                    icon: "person.2.fill",
                    color: .blue,
                    animate: animateStats,
                    action: { showFollowers = true }
                )
                
                AnimatedStatCard(
                    value: statsValues.following,
                    label: "Following",
                    icon: "person.2.fill",
                    color: .green,
                    animate: animateStats,
                    action: { showFollowing = true }
                )
                
                AnimatedStatCard(
                    value: statsValues.zapsReceived,
                    label: "Zaps",
                    icon: "bolt.fill",
                    color: .yellow,
                    animate: animateStats
                )
            }
            .padding(.horizontal, .ds.screenPadding)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateStats = true
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var modernTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                ProfileTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                            HapticManager.shared.impact(.light)
                        }
                    }
                )
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.surfaceSecondary)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .padding(.horizontal, .ds.screenPadding)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .highlights:
            HighlightsTabView(highlights: userHighlights, isLoading: isLoading)
        case .curations:
            CurationsTabView(curations: userCurations, isLoading: isLoading)
        case .activity:
            ActivityTabView()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadUserContent() async {
        guard let ndk = appState.ndk, let signer = appState.activeSigner else { return }
        
        isLoading = true
        
        do {
            let pubkey = try await signer.pubkey
            
            // Load all data in parallel
            async let highlights = loadHighlights(pubkey: pubkey, ndk: ndk)
            async let curations = loadCurations(pubkey: pubkey, ndk: ndk)
            async let social = loadSocialStats(pubkey: pubkey, ndk: ndk)
            
            let (highlightsResult, curationsResult, socialResult) = await (highlights, curations, social)
            
            await MainActor.run {
                userHighlights = highlightsResult
                userCurations = curationsResult
                
                // Animate stats updates
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    statsValues.highlights = highlightsResult.count
                    statsValues.curations = curationsResult.count
                    statsValues.followers = socialResult.followers
                    statsValues.following = socialResult.following
                }
                
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                print("Failed to load user content: \(error)")
            }
        }
    }
    
    private func loadHighlights(pubkey: String, ndk: NDK) async -> [HighlightEvent] {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [9802],
            limit: 100
        )
        
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var events: [HighlightEvent] = []
        for await event in dataSource.events {
            if let highlight = try? HighlightEvent(from: event) {
                events.append(highlight)
                if events.count >= 100 { break }
            }
        }
        
        return events.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func loadCurations(pubkey: String, ndk: NDK) async -> [ArticleCuration] {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [30004],
            limit: 50
        )
        
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 600,
            cachePolicy: .cacheWithNetwork
        )
        
        var events: [ArticleCuration] = []
        for await event in dataSource.events {
            if let curation = try? ArticleCuration(from: event) {
                events.append(curation)
                if events.count >= 50 { break }
            }
        }
        
        return events.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    private func loadSocialStats(pubkey: String, ndk: NDK) async -> (followers: Int, following: Int) {
        // Load follower count
        let followerFilter = NDKFilter(
            kinds: [3],
            limit: 1000,
            tags: ["p": [pubkey]]
        )
        
        // Load following count
        let followingFilter = NDKFilter(
            authors: [pubkey],
            kinds: [3],
            limit: 1
        )
        
        // Fetch followers
        let followerDataSource = await ndk.outbox.observe(
            filter: followerFilter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var followerCount = 0
        for await _ in followerDataSource.events {
            followerCount += 1
            if followerCount >= 1000 { break }
        }
        
        // Fetch following
        let followingDataSource = await ndk.outbox.observe(
            filter: followingFilter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var followingCount = 0
        for await event in followingDataSource.events {
            followingCount = event.tags.filter { $0.first == "p" }.count
            break // We only need the first event
        }
        
        return (followers: followerCount, following: followingCount)
    }
    
    private func saveProfile() {
        // Save profile implementation
        Task {
            // Update profile metadata
            guard appState.ndk != nil, appState.activeSigner != nil else { return }
            
            // Create metadata event (kind 0)
            // Implementation would go here
        }
    }
}

// MARK: - Supporting Views

struct AnimatedStatCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    let animate: Bool
    var action: (() -> Void)? = nil
    
    @State private var displayValue: Int = 0
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: .ds.small) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animate ? 0 : -180))
                
                Text("\(displayValue)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                    .contentTransition(.numericText())
                
                Text(label)
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(action == nil)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                displayValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                displayValue = newValue
            }
        }
    }
}

struct ProfileTabButton: View {
    let tab: EnhancedProfileView.ProfileTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .symbolRenderingMode(.hierarchical)
                
                Text(tab.rawValue)
                    .font(.ds.caption)
            }
            .foregroundColor(isSelected ? .ds.primary : .ds.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, .ds.small)
            .background(
                Capsule()
                    .fill(isSelected ? Color.ds.primary.opacity(0.1) : Color.clear)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            )
        }
    }
}

// MARK: - Tab Views

struct HighlightsTabView: View {
    let highlights: [HighlightEvent]
    let isLoading: Bool
    
    var body: some View {
        LazyVStack(spacing: .ds.medium) {
            if isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    HighlightCardSkeleton()
                }
            } else if highlights.isEmpty {
                HighlightsEmptyStateView()
                .padding(.top, 40)
            } else {
                ForEach(highlights, id: \.id) { highlight in
                    ModernHighlightCard(highlight: highlight)
                        .premiumEntrance()
                }
            }
        }
        .padding(.horizontal, .ds.screenPadding)
    }
}

struct CurationsTabView: View {
    let curations: [ArticleCuration]
    let isLoading: Bool
    
    var body: some View {
        LazyVStack(spacing: .ds.medium) {
            if isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    CurationCardSkeleton()
                }
            } else if curations.isEmpty {
                CurationsEmptyStateView()
                .padding(.top, 40)
            } else {
                ForEach(curations, id: \.id) { curation in
                    CurationCard(curation: curation)
                        .premiumEntrance()
                }
            }
        }
        .padding(.horizontal, .ds.screenPadding)
    }
}

struct ActivityTabView: View {
    var body: some View {
        VStack(spacing: .ds.large) {
            ActivityEmptyStateView()
            .padding(.top, 40)
        }
        .padding(.horizontal, .ds.screenPadding)
    }
}

// MARK: - Skeleton Views

struct HighlightCardSkeleton: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.base) {
            // Header skeleton
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 16)
            }
            
            // Footer skeleton
            HStack {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 28)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(.ds.medium)
        .overlay(
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 100)
                .offset(x: shimmerOffset)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = geometry.size.width + 100
                    }
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: .ds.medium)
            )
        )
    }
}

struct CurationCardSkeleton: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image skeleton
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 150)
            
            VStack(alignment: .leading, spacing: .ds.small) {
                // Title skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                // Description skeleton
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 14)
                }
                
                // Stats skeleton
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 12)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 12)
                }
                .padding(.top, .ds.small)
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(.ds.medium)
        .overlay(
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 100)
                .offset(x: shimmerOffset)
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = geometry.size.width + 100
                    }
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: .ds.medium)
            )
        )
    }
}

// MARK: - Helper Views

// EmptyStateView is defined in CurationManagementView.swift

// ModernHighlightCard is defined in UnifiedCard.swift

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Empty State Views

struct HighlightsEmptyStateView: View {
    var body: some View {
        VStack(spacing: .ds.large) {
            Image(systemName: "highlighter")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: .ds.small) {
                Text("No Highlights Yet")
                    .font(.ds.title3)
                    .foregroundColor(.ds.text)
                
                Text("Start highlighting content to build your knowledge base")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to create highlight
            }) {
                Text("Create First Highlight")
                    .font(.ds.bodyMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct CurationsEmptyStateView: View {
    var body: some View {
        VStack(spacing: .ds.large) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: .ds.small) {
                Text("No Curations Yet")
                    .font(.ds.title3)
                    .foregroundColor(.ds.text)
                
                Text("Create collections of your favorite articles")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to create curation
            }) {
                Text("Create First Curation")
                    .font(.ds.bodyMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ActivityEmptyStateView: View {
    var body: some View {
        VStack(spacing: .ds.large) {
            Image(systemName: "bolt.heart")
                .font(.system(size: 60))
                .foregroundColor(.yellow.opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: .ds.small) {
                Text("Activity Coming Soon")
                    .font(.ds.title3)
                    .foregroundColor(.ds.text)
                
                Text("See your zaps, reactions, and engagement metrics")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}