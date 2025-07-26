import SwiftUI
import NDKSwift

struct FollowersListView: View {
    let pubkey: String
    @Environment(\.dismiss) var dismiss
    @State private var followers: [UserListItem] = []
    @State private var isLoading = true
    @State private var searchText = ""
    
    struct UserListItem: Identifiable {
        let id: String
        let pubkey: String
        let profile: NDKUserProfile?
    }
    
    var filteredFollowers: [UserListItem] {
        if searchText.isEmpty {
            return followers
        }
        
        return followers.filter { follower in
            let name = follower.profile?.displayName ?? follower.profile?.name ?? ""
            let about = follower.profile?.about ?? ""
            return name.localizedCaseInsensitiveContains(searchText) ||
                   about.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LoadingView()
                } else if followers.isEmpty {
                    FollowersEmptyStateView(
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
                                    profile: follower.profile
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
        // Implementation would load actual followers
        isLoading = false
    }
}

// MARK: - User Row Component

struct UserRow: View {
    let pubkey: String
    let profile: NDKUserProfile?
    var showFollowButton: Bool = false
    @State private var isFollowing = false
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            // Avatar
            if let picture = profile?.picture, let url = URL(string: picture) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } placeholder: {
                    avatarPlaceholder
                }
            } else {
                avatarPlaceholder
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile?.displayName ?? profile?.name ?? "Anonymous")
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    if profile?.nip05 != nil {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
                
                if let about = profile?.about {
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
                        .foregroundColor(isFollowing ? .ds.text : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isFollowing ? Color.gray.opacity(0.2) : Color.ds.primary)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, .ds.screenPadding)
        .padding(.vertical, .ds.small)
        .contentShape(Rectangle())
        .onTapGesture {
            // Navigate to user profile
        }
    }
    
    private var avatarPlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 48, height: 48)
            .overlay(
                Text(String((profile?.displayName ?? profile?.name ?? "A").prefix(1)))
                    .font(.ds.bodyMedium)
                    .foregroundColor(.white)
            )
    }
    
    private func toggleFollow() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isFollowing.toggle()
            HapticManager.shared.impact(.light)
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: .ds.large) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .ds.primary))
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View

struct FollowersEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: .ds.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.ds.primary.opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: .ds.small) {
                Text(title)
                    .font(.ds.title3)
                    .foregroundColor(.ds.text)
                
                Text(subtitle)
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}