import SwiftUI
import NDKSwift

struct FollowPackDetailView: View {
    let followPack: FollowPack
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var profiles: [String: NDKUserProfile] = [:]
    @State private var showSuccess = false
    @State private var creator: NDKUserProfile?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    creatorSection
                    importSection
                    profilesSection
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Follow Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .task {
            await loadProfiles()
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 48)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(followPack.profiles.count)")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text("Profiles")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(followPack.title)
                    .font(DesignSystem.Typography.headline)
                
                if let description = followPack.description {
                    Text(description)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var creatorSection: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.ds.title2)
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Created by")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(creator?.name ?? creator?.displayName ?? PubkeyFormatter.formatShort(followPack.author)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.1),
                    DesignSystem.Colors.secondary.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DesignSystem.CornerRadius.large)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var importSection: some View {
        Button(action: importFollowPack) {
            HStack {
                Image(systemName: showSuccess ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(showSuccess ? "Imported!" : "Import Follow Pack")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if showSuccess {
                        Color.green
                    } else {
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .disabled(showSuccess)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profiles in this pack")
                .font(DesignSystem.Typography.headline)
                .padding(.horizontal)
            
            ForEach(followPack.profiles, id: \.self) { pubkey in
                ProfileRow(pubkey: pubkey, profile: profiles[pubkey])
                    .padding(.horizontal)
            }
        }
    }
    
    private func loadProfiles() async {
        guard let ndk = appState.ndk else { return }
        
        // Load creator profile
        for await profile in await ndk.profileManager.observe(for: followPack.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.creator = profile
            }
            break
        }
        
        // Load profiles in the pack
        for pubkey in followPack.profiles {
            Task {
                for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                    await MainActor.run {
                        self.profiles[pubkey] = profile
                    }
                    break
                }
            }
        }
    }
    
    private func importFollowPack() {
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                guard let ndk = appState.ndk,
                      let signer = appState.activeSigner else {
                    throw AuthError.noSigner
                }
                
                // Get current contact list
                let pubkey = try await signer.pubkey
                let filter = NDKFilter(
                    authors: [pubkey],
                    kinds: [3],
                    limit: 1
                )
                
                let dataSource = await ndk.outbox.observe(filter: filter)
                var currentFollows: Set<String> = []
                
                // Parse existing follows
                for await event in dataSource.events {
                    currentFollows = Set(event.tags
                        .filter { $0.first == "p" && $0.count > 1 }
                        .compactMap { $0[1] })
                    break // Only need the first event
                }
                
                // Add follow pack members to current follows
                for pubkey in followPack.profiles {
                    currentFollows.insert(pubkey)
                }
                
                // Create new contact list event
                var tags: [[String]] = []
                for follow in currentFollows {
                    tags.append(["p", follow])
                }
                
                let contactEvent = try await NDKEventBuilder(ndk: ndk)
                    .kind(3)
                    .content("")
                    .tags(tags)
                    .build(signer: signer)
                
                _ = try await ndk.publish(contactEvent)
                
                await MainActor.run {
                    showSuccess = true
                    HapticManager.shared.notification(.success)
                    
                    // Reset after delay
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            showSuccess = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
}

struct ProfileRow: View {
    let pubkey: String
    let profile: NDKUserProfile?
    @State private var isFollowing = false
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40)
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile?.name ?? profile?.displayName ?? String(pubkey.prefix(16))
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.medium)
                
                if let about = profile?.about {
                    Text(about)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Button(action: { isFollowing.toggle() }) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.mini)
                    .background(isFollowing ? Color.gray : DesignSystem.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(DesignSystem.CornerRadius.large)
            }
        }
        .modernCard()
    }
}

#Preview {
    FollowPackDetailView(
        followPack: FollowPack(
            id: "1",
            event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 39089, tags: [], content: "", sig: ""),
            name: "bitcoin-devs",
            title: "Bitcoin Developers",
            description: "Core Bitcoin developers and contributors",
            image: nil,
            author: "test",
            createdAt: Date(),
            profiles: ["pubkey1", "pubkey2", "pubkey3"]
        )
    )
    .environmentObject(AppState())
}
