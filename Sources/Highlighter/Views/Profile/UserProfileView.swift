import SwiftUI
import NDKSwift
import NDKSwiftUI

struct UserProfileView: View {
    let pubkey: String
    @EnvironmentObject var appState: AppState
    @State private var metadata: NDKUserMetadata?
    @State private var highlights: [HighlightEvent] = []
    @State private var articles: [Article] = []
    @State private var comments: [NDKEvent] = []
    @State private var collections: [ArticleCuration] = []
    @State private var stats = ProfileStats()
    @State private var selectedTab = ProfileTab.highlights
    @State private var showingFollowConfirmation = false
    @State private var isFollowing = false
    
    private func formatNpub(_ pubkey: String) -> String {
        // Convert hex pubkey to npub using proper bech32 encoding
        let user = NDKUser(pubkey: pubkey)
        return user.npub
    }
    
    struct ProfileStats {
        var highlightCount = 0
        var articleCount = 0
        var followerCount = 0
        var followingCount = 0
    }
    
    enum ProfileTab: String, CaseIterable {
        case highlights = "Highlights"
        case articles = "Articles"
        case comments = "Comments"
        case collections = "Collections"
        
        var icon: String {
            switch self {
            case .highlights: return "highlighter"
            case .articles: return "doc.richtext"
            case .comments: return "bubble.left.and.bubble.right"
            case .collections: return "folder"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header
                    profileHeader
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    
                    // Stats Bar
                    statsBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Tab Selection
                    tabSelector
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    
                    // Content based on selected tab
                    tabContent
                        .padding(.horizontal, 20)
                }
            }
            .background(Color.ds.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { shareProfile() }) {
                            Label("Share Profile", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { copyNpub() }) {
                            Label("Copy npub", systemImage: "doc.on.doc")
                        }
                        
                        if isFollowing {
                            Button(role: .destructive, action: { toggleFollow() }) {
                                Label("Unfollow", systemImage: "person.badge.minus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.ds.body)
                            .foregroundColor(.ds.primary)
                    }
                }
            }
        }
        .task {
            // Start streaming profile updates
            // Profile streaming is handled by NDK's profile manager
            
            // Load profile data
            await loadProfileData()
            checkFollowStatus()
        }
        .onChange(of: pubkey) { _, newPubkey in
            Task {
                // Profile updates for new pubkey
                // Profile streaming is handled by NDK's profile manager
                await loadProfileData()
                checkFollowStatus()
            }
        }
        // Profile updates are handled through loadProfileData()
    }
    
    // MARK: - Profile Header
    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            if let picture = metadata?.picture, let url = URL(string: picture) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    case .failure(_), .empty:
                        avatarPlaceholder
                    @unknown default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
            
            // Name and username
            VStack(spacing: 8) {
                if let name = metadata?.name {
                    Text(name)
                        .font(.ds.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ds.text)
                }
                
                Text(formatNpub(pubkey))
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
                    .textSelection(.enabled)
            }
            
            // Bio
            if let about = metadata?.about {
                Text(about)
                    .font(.ds.body)
                    .foregroundColor(.ds.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.top, 8)
            }
            
            // Follow/Message buttons
            HStack(spacing: 12) {
                Button(action: { toggleFollow() }) {
                    HStack {
                        Image(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus")
                        Text(isFollowing ? "Following" : "Follow")
                    }
                    .font(.ds.footnoteMedium)
                    .foregroundColor(isFollowing ? .ds.text : .white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isFollowing ? Color.ds.surfaceSecondary : Color.ds.primary)
                    )
                }
                
                Button(action: { /* Open DM */ }) {
                    Image(systemName: "envelope")
                        .font(.ds.body)
                        .foregroundColor(.ds.primary)
                        .padding(12)
                        .background(
                            Circle()
                                .stroke(Color.ds.primary, lineWidth: 1)
                        )
                }
            }
            .padding(.top, 12)
        }
    }
    
    // MARK: - Avatar Placeholder
    @ViewBuilder
    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Text(String(pubkey.prefix(2)).uppercased())
                .font(.ds.bodyMedium)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Stats Bar
    @ViewBuilder
    private var statsBar: some View {
        HStack(spacing: 0) {
            ProfileStatItem(
                value: "\(stats.highlightCount)",
                label: "Highlights",
                color: .orange
            )
            
            Divider()
                .frame(height: 40)
            
            ProfileStatItem(
                value: "\(stats.articleCount)",
                label: "Articles",
                color: .blue
            )
            
            Divider()
                .frame(height: 40)
            
            ProfileStatItem(
                value: "\(stats.followerCount)",
                label: "Followers",
                color: .purple
            )
            
            Divider()
                .frame(height: 40)
            
            ProfileStatItem(
                value: "\(stats.followingCount)",
                label: "Following",
                color: .green
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ds.surfaceSecondary)
        )
    }
    
    // MARK: - Tab Selector
    @ViewBuilder
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    UserProfileTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        count: countForTab(tab)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .highlights:
            HighlightsListView(highlights: highlights)
        case .articles:
            ArticlesListView(articles: articles)
        case .comments:
            CommentsListView(comments: comments)
        case .collections:
            CollectionsListView(collections: collections)
        }
    }
    
    // MARK: - Helper Methods
    private func countForTab(_ tab: ProfileTab) -> Int {
        switch tab {
        case .highlights: return highlights.count
        case .articles: return articles.count
        case .comments: return comments.count
        case .collections: return collections.count
        }
    }
    
    private func checkFollowStatus() {
        Task {
            do {
                isFollowing = try await appState.isFollowing(pubkey)
            } catch {
                // Error checking follow status
                isFollowing = false
            }
        }
    }
    
    private func toggleFollow() {
        Task {
            await performToggleFollow()
        }
    }
    
    private func performToggleFollow() async {
        let wasFollowing = isFollowing
        isFollowing.toggle()
        HapticManager.shared.impact(.light)
        
        do {
            if isFollowing {
                try await appState.followUser(pubkey)
                await MainActor.run {
                    stats.followerCount += 1
                }
            } else {
                try await appState.unfollowUser(pubkey)
                await MainActor.run {
                    stats.followerCount = max(0, stats.followerCount - 1)
                }
            }
        } catch {
            // Revert on error
            await MainActor.run {
                isFollowing = wasFollowing
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func shareProfile() {
        // Share profile implementation
    }
    
    private func copyNpub() {
        let npub = formatNpub(pubkey)
        if !npub.isEmpty {
            UIPasteboard.general.string = npub
            HapticManager.shared.notification(.success)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadProfileData() async {
        let ndk = appState.ndk
        
        // Get profile from NDK
        for await profile in await ndk.profileManager.subscribe(for: pubkey, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.metadata = profile
            }
            break // Only need first value
        }
        
        // Load all content in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadHighlights(pubkey: pubkey, ndk: ndk) }
            group.addTask { await self.loadArticles(pubkey: pubkey, ndk: ndk) }
            group.addTask { await self.loadComments(pubkey: pubkey, ndk: ndk) }
            group.addTask { await self.loadCollections(pubkey: pubkey, ndk: ndk) }
            group.addTask { await self.loadStats(pubkey: pubkey, ndk: ndk) }
        }
    }
    
    private func loadHighlights(pubkey: String, ndk: NDK) async {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [9802]
        )
        
        var events: Set<NDKEvent> = []
        let dataSource = ndk.subscribe(filter: filter)
        for await event in dataSource.events {
            events.insert(event)
            if events.count >= 50 { break }
        }
        let highlights = events.compactMap { try? HighlightEvent(from: $0) }
        await MainActor.run {
            self.highlights = highlights.sorted { $0.createdAt > $1.createdAt }
            self.stats.highlightCount = highlights.count
        }
    }
    
    private func loadArticles(pubkey: String, ndk: NDK) async {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [30023]
        )
        
        var events: Set<NDKEvent> = []
        let dataSource = ndk.subscribe(filter: filter)
        for await event in dataSource.events {
            events.insert(event)
            if events.count >= 50 { break }
        }
        if !events.isEmpty {
            let articles = events.compactMap { try? Article(from: $0) }
            await MainActor.run {
                self.articles = articles.sorted { $0.publishedAt ?? $0.createdAt > $1.publishedAt ?? $1.createdAt }
                self.stats.articleCount = articles.count
            }
        }
    }
    
    private func loadComments(pubkey: String, ndk: NDK) async {
        // NIP-22 comments on articles
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [1111],
            tags: ["K": Set(["30023"])]
        )
        
        let dataSource = ndk.subscribe(filter: filter)
        var collectedEvents: [NDKEvent] = []
        for await event in dataSource.events {
            collectedEvents.append(event)
        }
        if !collectedEvents.isEmpty {
            let sortedEvents = collectedEvents.sorted { $0.createdAt > $1.createdAt }
            await MainActor.run {
                self.comments = sortedEvents.prefix(50).map { $0 }
            }
        }
    }
    
    private func loadCollections(pubkey: String, ndk: NDK) async {
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [30004]
        )
        
        var events: Set<NDKEvent> = []
        let dataSource = ndk.subscribe(filter: filter)
        for await event in dataSource.events {
            events.insert(event)
            if events.count >= 50 { break }
        }
        if !events.isEmpty {
            let collections = events.compactMap { try? ArticleCuration(from: $0) }
            await MainActor.run {
                self.collections = collections.sorted { $0.createdAt > $1.createdAt }
            }
        }
    }
    
    private func loadStats(pubkey: String, ndk: NDK) async {
        // Load follow stats
        let followFilter = NDKFilter(
            kinds: [3],
            tags: ["p": Set([pubkey])]
        )
        
        var followerCount = 0
        let dataSource = ndk.subscribe(filter: followFilter)
        for await _ in dataSource.events {
            followerCount += 1
        }
        
        // Load following count from contact list
        let followingFilter = NDKFilter(
            authors: [pubkey],
            kinds: [3]
        )
        
        var followingCount = 0
        let followingDataSource = ndk.subscribe(filter: followingFilter)
        for await event in followingDataSource.events {
            // Count the "p" tags in the contact list
            followingCount = event.tags.filter { $0.count >= 2 && $0[0] == "p" }.count
            break // Only need first contact list
        }
        
        await MainActor.run {
            self.stats.followerCount = followerCount
            self.stats.followingCount = followingCount
        }
    }
}

// MARK: - Supporting Views

struct ProfileStatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.ds.headline)
                .fontWeight(.semibold)
                .foregroundColor(.ds.text)
            
            Text(label)
                .font(.ds.caption)
                .foregroundColor(.ds.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UserProfileTabButton: View {
    let tab: UserProfileView.ProfileTab
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.ds.footnote)
                
                Text(tab.rawValue)
                    .font(.ds.footnoteMedium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.ds.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.ds.primary.opacity(0.2) : Color.ds.surfaceSecondary)
                        )
                }
            }
            .foregroundColor(isSelected ? .ds.primary : .ds.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.ds.primary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.ds.primary : Color.clear, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Content List Views

struct HighlightsListView: View {
    let highlights: [HighlightEvent]
    
    var body: some View {
        VStack(spacing: 16) {
            if highlights.isEmpty {
                UserProfileEmptyStateView(
                    icon: "highlighter",
                    title: "No highlights yet",
                    description: "This user hasn't created any highlights"
                )
                .padding(.vertical, 40)
            } else {
                ForEach(highlights, id: \.id) { highlight in
                    HighlightCard(highlight: highlight)
                }
            }
        }
    }
}

struct ArticlesListView: View {
    let articles: [Article]
    
    var body: some View {
        VStack(spacing: 16) {
            if articles.isEmpty {
                UserProfileEmptyStateView(
                    icon: "doc.richtext",
                    title: "No articles yet",
                    description: "This user hasn't written any articles"
                )
                .padding(.vertical, 40)
            } else {
                ForEach(articles, id: \.id) { article in
                    ArticleRowCard(article: article)
                }
            }
        }
    }
}

struct CommentsListView: View {
    let comments: [NDKEvent]
    
    var body: some View {
        VStack(spacing: 16) {
            if comments.isEmpty {
                UserProfileEmptyStateView(
                    icon: "bubble.left.and.bubble.right",
                    title: "No comments yet",
                    description: "This user hasn't commented on any articles"
                )
                .padding(.vertical, 40)
            } else {
                ForEach(comments, id: \.id) { comment in
                    CommentCard(comment: comment)
                }
            }
        }
    }
}

struct CollectionsListView: View {
    let collections: [ArticleCuration]
    
    var body: some View {
        VStack(spacing: 16) {
            if collections.isEmpty {
                UserProfileEmptyStateView(
                    icon: "folder",
                    title: "No collections yet",
                    description: "This user hasn't created any collections"
                )
                .padding(.vertical, 40)
            } else {
                ForEach(collections, id: \.id) { collection in
                    CollectionCard(collection: collection)
                }
            }
        }
    }
}

struct CommentCard: View {
    let comment: NDKEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(comment.content)
                .font(.ds.body)
                .foregroundColor(.ds.text)
                .lineLimit(3)
            
            HStack {
                NDKUIRelativeTime(timestamp: comment.createdAt)
                    .font(.ds.caption)
                    .foregroundColor(.ds.textTertiary)
                
                Spacer()
                
                // Reference to article
                if comment.tags.first(where: { $0.count >= 2 && $0[0] == "a" }) != nil {
                    Label("View Article", systemImage: "doc.text")
                        .font(.ds.caption)
                        .foregroundColor(.ds.primary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ds.surfaceSecondary)
        )
    }
}

struct CollectionCard: View {
    let collection: ArticleCuration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let image = collection.image, let url = URL(string: image) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        default:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.ds.surfaceSecondary)
                                .frame(width: 60, height: 60)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.title)
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                        .lineLimit(1)
                    
                    if let description = collection.description {
                        Text(description)
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Label("\(collection.articles.count) articles", systemImage: "doc.text")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                        
                        Spacer()
                        
                        NDKUIRelativeTime(timestamp: Int64(collection.updatedAt.timeIntervalSince1970))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ds.surfaceSecondary)
        )
    }
}

struct UserProfileEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.ds.textTertiary)
            
            Text(title)
                .font(.ds.headline)
                .foregroundColor(.ds.text)
            
            Text(description)
                .font(.ds.caption)
                .foregroundColor(.ds.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}


// MARK: - Preview

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(pubkey: "npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m")
            .environmentObject(AppState())
    }
}