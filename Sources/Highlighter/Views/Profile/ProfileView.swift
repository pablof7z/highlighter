import SwiftUI
import NDKSwift
import NDKSwiftUI
import PhotosUI

struct ProfileView: View {
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
                                    )
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
                                .font(.ds.title3)
                                .foregroundColor(.ds.text)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .magneticHover()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.ds.title3)
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
                                colors: DesignSystem.ProfileHeader.overlayGradient,
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
                                .clipShape(Circle()
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
                            .font(.ds.title2)
                            .foregroundStyle(.white, Color.blue)
                            .background(Circle().fill(Color.white).frame(width: 28, height: 28)
                            .offset(x: 5, y: 5)
                    }
                }
                
                // Name and bio
                VStack(spacing: .ds.small) {
                    Text(appState.currentUserProfile?.displayName ?? "Anonymous")
                        .font(.ds.title).fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let nip05 = appState.currentUserProfile?.nip05 {
                        Label(nip05, systemImage: "checkmark.seal")
                            .font(.ds.callout)
                            .foregroundColor(.white.opacity(0.9)
                    }
                    
                    if let about = appState.currentUserProfile?.about {
                        Text(about)
                            .font(.ds.body)
                            .foregroundColor(.white.opacity(0.8)
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
                        .fill(Color.white.opacity(0.1)
                        .frame(width: 150, height: 150)
                        .offset(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .blur(radius: 30)
                        .animation(
                            .easeInOut(duration: Double.random(in: 10...20)
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
                    .font(.system(size: 40)
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
                UnifiedStatCard(
                    value: "\(statsValues.highlights)",
                    label: "Highlights",
                    icon: "highlighter",
                    color: .orange
                )
                
                UnifiedStatCard(
                    value: "\(statsValues.curations)",
                    label: "Curations",
                    icon: "books.vertical.fill",
                    color: .purple
                )
                
                UnifiedStatCard(
                    value: "\(statsValues.followers)",
                    label: "Followers",
                    icon: "person.2.fill",
                    color: .blue
                )
                .onTapGesture { showFollowers = true }
                
                UnifiedStatCard(
                    value: "\(statsValues.following)",
                    label: "Following",
                    icon: "person.2.fill",
                    color: .green
                )
                .onTapGesture { showFollowing = true }
                
                UnifiedStatCard(
                    value: "\(statsValues.zapsReceived)",
                    label: "Zaps",
                    icon: "bolt.fill",
                    color: .yellow
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                            HapticManager.shared.impact(.light)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.ds.body).fontWeight(.medium)
                            Text(tab.rawValue)
                        }
                        .unifiedTabPill(isSelected: selectedTab == tab)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, .ds.screenPadding)
        }
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
            }
        }
    }
    
    private func loadHighlights(pubkey: String, ndk: NDK) async -> [HighlightEvent] {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [9802],
            limit: 100
        )
        
        let dataSource = ndk.observe(
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
        
        let dataSource = ndk.observe(
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
        let followerDataSource = ndk.observe(
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
        let followingDataSource = ndk.observe(
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
        Task {
            guard let ndk = appState.ndk, let signer = appState.activeSigner else { return }
            
            do {
                // Create profile metadata
                var metadata: [String: String] = [:]
                
                if !editedProfile.displayName.isEmpty {
                    metadata["display_name"] = editedProfile.displayName
                    metadata["name"] = editedProfile.displayName
                }
                
                if !editedProfile.about.isEmpty {
                    metadata["about"] = editedProfile.about
                }
                
                if !editedProfile.picture.isEmpty {
                    metadata["picture"] = editedProfile.picture
                }
                
                if !editedProfile.banner.isEmpty {
                    metadata["banner"] = editedProfile.banner
                }
                
                if !editedProfile.website.isEmpty {
                    metadata["website"] = editedProfile.website
                }
                
                if !editedProfile.nip05.isEmpty {
                    metadata["nip05"] = editedProfile.nip05
                }
                
                if !editedProfile.lud16.isEmpty {
                    metadata["lud16"] = editedProfile.lud16
                }
                
                // Create and publish metadata event (kind 0)
                let metadataJSON = try JSONSerialization.data(withJSONObject: metadata, options: [])
                guard let metadataString = String(data: metadataJSON, encoding: .utf8) else { return }
                
                // Build and publish event
                let event = try await NDKEventBuilder(ndk: ndk)
                    .kind(0) // Metadata event
                    .content(metadataString)
                    .tags([])
                    .build(signer: signer)
                
                _ = try await ndk.publish(event)
                
                // Update local profile
                await MainActor.run {
                    // Profile will automatically update through NDK's profile manager
                    HapticManager.shared.notification(.success)
                }
                
            } catch {
                await MainActor.run {
                    appState.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
}

// MARK: - Supporting Views


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
                    HighlightCard(highlight: highlight)
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
    @EnvironmentObject var appState: AppState
    @State private var recentZaps: [(event: NDKEvent, amount: Int)] = []
    @State private var recentReactions: [NDKEvent] = []
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: .ds.large) {
                if isLoading {
                    // Loading state
                    ForEach(0..<3, id: \.self) { _ in
                        ActivityCardSkeleton()
                    }
                } else if recentZaps.isEmpty && recentReactions.isEmpty {
                    ActivityEmptyStateView()
                        .padding(.top, 40)
                } else {
                    // Recent Zaps Section
                    if !recentZaps.isEmpty {
                        VStack(alignment: .leading, spacing: .ds.medium) {
                            Label("Recent Zaps", systemImage: "bolt.fill")
                                .font(.ds.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ds.text)
                            
                            ForEach(recentZaps.prefix(10), id: \.event.id) { zap in
                                ZapActivityCard(event: zap.event, amount: zap.amount)
                                    .premiumEntrance()
                            }
                        }
                    }
                    
                    // Recent Reactions Section
                    if !recentReactions.isEmpty {
                        VStack(alignment: .leading, spacing: .ds.medium) {
                            Label("Recent Reactions", systemImage: "heart.fill")
                                .font(.ds.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ds.text)
                            
                            ForEach(recentReactions.prefix(10), id: \.id) { reaction in
                                ReactionActivityCard(event: reaction)
                                    .premiumEntrance()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, .ds.screenPadding)
        }
        .task {
            await loadActivity()
        }
    }
    
    private func loadActivity() async {
        guard let ndk = appState.ndk, let signer = appState.activeSigner else { return }
        
        isLoading = true
        
        do {
            let pubkey = try await signer.pubkey
            
            // Load zaps (kind 9735)
            let zapFilter = NDKFilter(
                kinds: [9735],
                limit: 50,
                tags: ["p": [pubkey]]
            )
            
            // Load reactions (kind 7) 
            let reactionFilter = NDKFilter(
                kinds: [7],
                limit: 50,
                tags: ["p": [pubkey]]
            )
            
            // Fetch data in parallel
            async let zapData = fetchEvents(filter: zapFilter, ndk: ndk)
            async let reactionData = fetchEvents(filter: reactionFilter, ndk: ndk)
            
            let (zaps, reactions) = await (zapData, reactionData)
            
            await MainActor.run {
                // Parse zap amounts from events
                recentZaps = zaps.compactMap { event in
                    // Extract amount from zap receipt
                    if let amountTag = event.tags.first(where: { $0.first == "amount" }),
                       amountTag.count > 1,
                       let amount = Int(amountTag[1]) {
                        return (event: event, amount: amount / 1000) // Convert millisats to sats
                    }
                    return nil
                }.sorted { $0.event.createdAt > $1.event.createdAt }
                
                recentReactions = reactions.sorted { $0.createdAt > $1.createdAt }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func fetchEvents(filter: NDKFilter, ndk: NDK) async -> [NDKEvent] {
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var events: [NDKEvent] = []
        for await event in dataSource.events {
            events.append(event)
            if events.count >= filter.limit ?? 50 { break }
        }
        
        return events
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
                    .fill(Color.gray.opacity(0.3)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 120, height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(width: 200, height: 16)
            }
            
            // Footer skeleton
            HStack {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 60, height: 28)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1)
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
                .fill(Color.gray.opacity(0.3)
                .frame(height: 150)
            
            VStack(alignment: .leading, spacing: .ds.small) {
                // Title skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(height: 20)
                
                // Description skeleton
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(height: 14)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 180, height: 14)
                }
                
                // Stats skeleton
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 80, height: 12)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3)
                        .frame(width: 60, height: 12)
                }
                .padding(.top, .ds.small)
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1)
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

// HighlightCard is defined in UnifiedCard.swift


// MARK: - Activity Cards

struct ZapActivityCard: View {
    let event: NDKEvent
    let amount: Int
    @State private var lightningAnimation = false
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            // Lightning icon
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2)
                    .frame(width: 44, height: 44)
                    .blur(radius: lightningAnimation ? 8 : 4)
                
                Image(systemName: "bolt.fill")
                    .font(.ds.title3)
                    .foregroundColor(.yellow)
                    .scaleEffect(lightningAnimation ? 1.1 : 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("⚡️ \(amount) sats")
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    Spacer()
                    
                    NDKRelativeTime(timestamp: Int64(event.createdAt.timeIntervalSince1970)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                }
                
                HStack(spacing: 4) {
                    Text("from")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                    
                    Text(String(event.pubkey.prefix(8))
                        .font(.ds.caption)
                        .foregroundColor(.ds.primary)
                }
                
                if !event.content.isEmpty {
                    Text(event.content)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                .fill(Color.yellow.opacity(0.05)
                .overlay(
                    RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                lightningAnimation = true
            }
        }
    }
}

struct ReactionActivityCard: View {
    let event: NDKEvent
    @State private var heartScale: CGFloat = 1
    
    var reactionContent: String {
        event.content.isEmpty ? "❤️" : event.content
    }
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            // Reaction icon
            Text(reactionContent)
                .font(.ds.largeTitle)
                .scaleEffect(heartScale)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Reaction on your content")
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    Spacer()
                    
                    NDKRelativeTime(timestamp: Int64(event.createdAt.timeIntervalSince1970)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                }
                
                HStack(spacing: 4) {
                    Text("from")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                    
                    Text(String(event.pubkey.prefix(8))
                        .font(.ds.caption)
                        .foregroundColor(.ds.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                .fill(Color.pink.opacity(0.05)
                .overlay(
                    RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                        .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                heartScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    heartScale = 1
                }
            }
        }
    }
}

struct ActivityCardSkeleton: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            // Icon skeleton
            Circle()
                .fill(Color.gray.opacity(0.3)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 8) {
                // Title skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(width: 180, height: 16)
                
                // Subtitle skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)
                    .frame(width: 120, height: 12)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1)
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

// MARK: - Empty State Views

struct HighlightsEmptyStateView: View {
    var body: some View {
        UnifiedEmptyState(
            icon: "pencil.tip",
            title: "No Highlights Yet",
            message: "Start highlighting content to build your knowledge base"
        )
    }
}

struct CurationsEmptyStateView: View {
    var body: some View {
        UnifiedEmptyState(
            icon: "books.vertical",
            title: "No Curations Yet",
            message: "Create collections of your favorite articles"
        )
    }
}

struct ActivityEmptyStateView: View {
    var body: some View {
        UnifiedEmptyState(
            icon: "bolt.heart",
            title: "No Activity Yet",
            message: "Zaps and reactions from other users will appear here"
        )
    }
}