import SwiftUI
import NDKSwift
import NDKSwiftUI

struct UserDiscoveryView: View {
    let searchText: String
    @EnvironmentObject var appState: AppState
    @State private var users: [(pubkey: String, metadata: NDKUserMetadata)] = []
    
    var filteredUsers: [(pubkey: String, metadata: NDKUserMetadata)] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.metadata.displayName?.localizedCaseInsensitiveContains(searchText) == true ||
            user.metadata.name?.localizedCaseInsensitiveContains(searchText) == true ||
            user.metadata.about?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredUsers, id: \.pubkey) { user in
                    UserCard(pubkey: user.pubkey, metadata: user.metadata)
                }
            }
            .padding()
        }
        .task {
            await loadUsers()
        }
    }
    
    private func loadUsers() async {
        let ndk = appState.ndk
        
        // For now, load some popular users or recent profile updates
        let profileSource = ndk.subscribe(
            filter: NDKFilter(kinds: [0]),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileSource.events {
            if event.kind == 0 {
                let metadata = NDKUserMetadata(event: event)
                await MainActor.run {
                    if !users.contains(where: { $0.pubkey == event.pubkey }) {
                        users.append((pubkey: event.pubkey, metadata: metadata))
                        // Sort by display name
                        users.sort { 
                            ($0.metadata.displayName ?? $0.metadata.name ?? "") < 
                            ($1.metadata.displayName ?? $1.metadata.name ?? "")
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
    let metadata: NDKUserMetadata
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
                    if let picture = metadata.picture, let url = URL(string: picture) {
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
                Text(metadata.displayName ?? metadata.name ?? String(pubkey.prefix(16)))
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(1)
                
                // Username if different from display name
                if let name = metadata.name, 
                   let displayName = metadata.displayName,
                   name != displayName {
                    Text("@\(name)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                // About
                if let about = metadata.about {
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
                    
                    if metadata.lud16 != nil || metadata.lud06 != nil {
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
        let ndk = appState.ndk
        
        // Count highlights by this user
        let highlightSource = ndk.subscribe(
            filter: NDKFilter(
                authors: [pubkey],
                kinds: [9802]
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
        isFollowing = (try? await appState.isFollowing(pubkey)) ?? false
    }
}