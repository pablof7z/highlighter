import SwiftUI
import NDKSwift

struct FollowersListView: View {
    let pubkey: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var followers: [UserListItem] = []
    @State private var isLoading = true
    @State private var searchText = ""
    
    struct UserListItem: Identifiable {
        let id: String
        let pubkey: String
        let metadata: NDKUserMetadata?
    }
    
    var filteredFollowers: [UserListItem] {
        if searchText.isEmpty {
            return followers
        }
        
        return followers.filter { follower in
            let name = follower.metadata?.displayName ?? follower.metadata?.name ?? ""
            let about = follower.metadata?.about ?? ""
            return name.localizedCaseInsensitiveContains(searchText) ||
                   about.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LoadingView(message: "Loading followers...", style: .dots)
                } else if followers.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Followers Yet",
                        subtitle: "Share great content to build your following"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredFollowers) { follower in
                                UserRow(
                                    pubkey: follower.pubkey,
                                    metadata: follower.metadata
                                )
                                .premiumEntrance()
                                
                                if follower.id != filteredFollowers.last?.id {
                                    Divider()
                                        .background(DesignSystem.Colors.divider)
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .padding(.vertical, .ds.small)
                    }
                    .searchable(text: $searchText, prompt: "Search followers")
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Followers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadFollowers()
        }
    }
    
    private func loadFollowers() async {
        let ndk = appState.ndk
        
        // Get contact list events (NIP-02) for people who follow this pubkey
        let filter = NDKFilter(
            kinds: [3], // Contact list
            tags: ["p": [pubkey]]
        )
        
        await MainActor.run {
            followers.removeAll()
        }
        
        // Use NDK's observe method
        let dataSource = ndk.subscribe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in dataSource.events {
            let followerPubkey = event.pubkey
            
            // Load profile data for each follower using NDK's profileManager
            for await profile in await ndk.profileManager.subscribe(for: followerPubkey, maxAge: TimeConstants.hour) {
                await MainActor.run {
                    let userItem = UserListItem(
                        id: followerPubkey,
                        pubkey: followerPubkey,
                        metadata: profile
                    )
                    
                    // Avoid duplicates
                    if !followers.contains(where: { $0.id == followerPubkey }) {
                        followers.append(userItem)
                    }
                }
                break // Only need current value
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

// MARK: - User Row Component

struct UserRow: View {
    let pubkey: String
    let metadata: NDKUserMetadata?
    var showFollowButton: Bool = false
    @State private var isFollowing = false
    @State private var showUserProfile = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            // Avatar
            ProfileImage(pubkey: pubkey, size: 48)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(metadata?.displayName ?? metadata?.name ?? String(pubkey.prefix(16)))
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    if metadata?.nip05 != nil {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.ds.caption)
                            .foregroundColor(.ds.primary)
                    }
                }
                
                if let about = metadata?.about {
                    Text(about)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Follow button
            if showFollowButton {
                Button(action: toggleFollow) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.ds.captionMedium)
                        .foregroundColor(isFollowing ? .ds.text : Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isFollowing ? Color.ds.textTertiary.opacity(0.2) : Color.ds.primary)
                        )
                }
                .unifiedScaleButton()
            }
        }
        .padding(.horizontal, .ds.screenPadding)
        .padding(.vertical, .ds.small)
        .contentShape(Rectangle())
        .onTapGesture {
            showUserProfile = true
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(pubkey: pubkey)
                .environmentObject(appState)
        }
        .task {
            if showFollowButton {
                isFollowing = appState.following.contains(pubkey)
            }
        }
    }
    
    private var avatarPlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.ds.primary.opacity(0.3), Color.ds.primaryLight.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 48, height: 48)
            .overlay(
                Text(String((metadata?.displayName ?? metadata?.name ?? "A").prefix(1)))
                    .font(.ds.bodyMedium)
                    .foregroundColor(Color.white)
            )
    }
    
    private func toggleFollow() {
        Task {
            do {
                if isFollowing {
                    try await appState.unfollowUser(pubkey)
                } else {
                    try await appState.followUser(pubkey)
                }
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFollowing.toggle()
                        HapticManager.shared.impact(.light)
                    }
                }
            } catch {
                // Silent error handling - UI state already reverted
            }
        }
    }
}

