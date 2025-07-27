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
                .fill(Color.ds.primaryDark.opacity(0.2))
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
                                .font(.system(size: 24))
                                .foregroundColor(.ds.primaryDark)
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.ds.primaryDark)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(profile.displayName ?? profile.name ?? formatPubkey(pubkey))
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                // Username if different from display name
                if let name = profile.name, 
                   let displayName = profile.displayName,
                   name != displayName {
                    Text("@\(name)")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(1)
                }
                
                // About
                if let about = profile.about {
                    Text(about)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
                
                // Stats
                HStack(spacing: 12) {
                    Label("\(highlightCount)", systemImage: "highlighter")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                    
                    if profile.lud16 != nil || profile.lud06 != nil {
                        Image(systemName: "bolt.fill")
                            .font(.ds.caption)
                            .foregroundColor(.ds.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Follow button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isFollowing.toggle()
                }
                HapticManager.shared.impact(HapticManager.ImpactStyle.light)
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.ds.footnoteMedium)
            }
            .unifiedPrimaryButton(enabled: true, variant: isFollowing ? .standard : .compact)
        }
        .padding()
        .modernCard()
        .task {
            await loadUserStats()
        }
    }
    
    private func formatPubkey(_ pubkey: String) -> String {
        String(pubkey.prefix(8)) + "..."
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
        if let signer = appState.activeSigner {
            do {
                let currentUser = try await signer.pubkey
                let contactSource = await ndk.outbox.observe(
                    filter: NDKFilter(
                        authors: [currentUser],
                        kinds: [3],
                        limit: 1
                    ),
                    maxAge: 3600,
                    cachePolicy: .cacheWithNetwork
                )
                
                for await event in contactSource.events {
                    // Check if this pubkey is in the contact list
                    let tags = event.tags.filter { $0.count >= 2 && $0[0] == "p" }
                    let isInContacts = tags.contains { $0[1] == pubkey }
                    
                    await MainActor.run {
                        self.isFollowing = isInContacts
                    }
                    break
                }
            } catch {
            }
        }
    }
}

// Type-erasing wrapper for button styles
struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    
    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}