import SwiftUI
import NDKSwift

struct UserDiscoveryView: View {
    let searchText: String
    @EnvironmentObject var appState: AppState
    @State private var users: [(pubkey: String, profile: NDKUserProfile)] = []
    
    var filteredUsers: [(pubkey: String, profile: NDKUserProfile)] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.profile.displayName?.localizedCaseInsensitiveContains(searchText) == true ||
            user.profile.name?.localizedCaseInsensitiveContains(searchText) == true ||
            user.profile.about?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredUsers, id: \.pubkey) { user in
                    UserCard(pubkey: user.pubkey, profile: user.profile)
                }
            }
            .padding()
        }
        .task {
            await loadUsers()
        }
    }
    
    private func loadUsers() async {
        guard let ndk = appState.ndk else { return }
        
        // For now, load some popular users or recent profile updates
        let profileSource = await ndk.outbox.observe(
            filter: NDKFilter(kinds: [0], limit: 100),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileSource.events {
            if let profile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                await MainActor.run {
                    if !users.contains(where: { $0.pubkey == event.pubkey }) {
                        users.append((pubkey: event.pubkey, profile: profile))
                        // Sort by display name
                        users.sort { 
                            ($0.profile.displayName ?? $0.profile.name ?? "") < 
                            ($1.profile.displayName ?? $1.profile.name ?? "")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - User Card

struct UserCard: View {
    let pubkey: String
    let profile: NDKUserProfile
    @EnvironmentObject var appState: AppState
    @State private var isFollowing = false
    @State private var highlightCount = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile picture
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay {
                    if let picture = profile.picture, let url = URL(string: picture) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(profile.displayName ?? profile.name ?? PubkeyFormatter.formatShort(pubkey))
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(1)
                
                // Username if different from display name
                if let name = profile.name, 
                   let displayName = profile.displayName,
                   name != displayName {
                    Text("@\(name)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                // About
                if let about = profile.about {
                    Text(about)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                // Stats
                HStack(spacing: 12) {
                    Label("\(highlightCount)", systemImage: "highlighter")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    if profile.lud16 != nil || profile.lud06 != nil {
                        Image(systemName: "bolt.fill")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Follow button
            Button {
                Task { @MainActor in
                    await toggleFollow()
                }
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(DesignSystem.Typography.footnoteMedium)
            }
            .unifiedPrimaryButton(enabled: true, variant: isFollowing ? .standard : .compact)
        }
        .padding()
        .modernCard()
        .task {
            await loadUserStats()
        }
    }
    
    private func toggleFollow() async {
        let wasFollowing = isFollowing
        isFollowing.toggle()
        HapticManager.shared.impact(.light)
        
        do {
            if isFollowing {
                try await appState.followUser(pubkey)
            } else {
                try await appState.unfollowUser(pubkey)
            }
        } catch {
            // Revert on error
            await MainActor.run {
                isFollowing = wasFollowing
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func loadUserStats() async {
        guard let ndk = appState.ndk else { return }
        
        // Count highlights by this user
        let highlightSource = await ndk.outbox.observe(
            filter: NDKFilter(
                authors: [pubkey],
                kinds: [9802],
                limit: 100
            ),
            maxAge: 3600,
            cachePolicy: .cacheOnly
        )
        
        var count = 0
        for await _ in highlightSource.events {
            count += 1
        }
        
        await MainActor.run {
            self.highlightCount = count
        }
        
        // Check if following
        do {
            isFollowing = try await appState.isFollowing(pubkey)
        } catch {
            isFollowing = false
        }
    }
}