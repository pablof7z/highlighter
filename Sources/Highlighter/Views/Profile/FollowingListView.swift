import SwiftUI
import NDKSwift

struct FollowingListView: View {
    let pubkey: String
    @EnvironmentObject var appState: AppState
    @State private var following: [(pubkey: String, profile: NDKUserProfile?)] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ModernLoadingView(message: "Loading following...", style: .dots)
                } else if following.isEmpty {
                    ModernEmptyStateView(
                        icon: "person.2",
                        title: "Not Following Anyone",
                        subtitle: "This user hasn't followed anyone yet"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(following.enumerated()), id: \.element.pubkey) { index, item in
                                UserRow(
                                    pubkey: item.pubkey,
                                    profile: item.profile,
                                    showFollowButton: true
                                )
                                .premiumEntrance()
                                
                                if index < following.count - 1 {
                                    Divider()
                                        .background(DesignSystem.Colors.divider)
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .padding(.vertical, .ds.small)
                    }
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Following")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadFollowing()
        }
    }
    
    private func loadFollowing() async {
        guard let ndk = appState.ndk else { return }
        
        let filter = NDKFilter(
            authors: [pubkey],
            kinds: [3],
            limit: 1
        )
        
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        var followingList: [(pubkey: String, profile: NDKUserProfile?)] = []
        
        for await event in dataSource.events {
            // Extract following pubkeys from p tags
            let followingPubkeys = event.tags
                .filter { $0.first == "p" }
                .compactMap { $0.count > 1 ? $0[1] : nil }
            
            // Load profiles for each pubkey
            for followPubkey in followingPubkeys {
                // Get cached profile if available
                let profile = appState.profileManager.getCachedProfile(for: followPubkey)
                followingList.append((pubkey: followPubkey, profile: profile)
            }
            
            break // We only need the first event
        }
        
        await MainActor.run {
            following = followingList
            isLoading = false
        }
    }
}

// Preview
#Preview {
    FollowingListView(pubkey: "testpubkey")
        .environmentObject(AppState())
}