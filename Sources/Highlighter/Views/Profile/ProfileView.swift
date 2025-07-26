import SwiftUI
import NDKSwift

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var userHighlights: [HighlightEvent] = []
    @State private var userCurations: [ArticleCuration] = []
    @State private var isLoading = true
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Profile Header
                    ProfileHeaderView(
                        profile: appState.currentUserProfile,
                        isLoading: isLoading
                    )
                    
                    // Stats
                    StatsView(
                        highlightsCount: userHighlights.count,
                        curationsCount: userCurations.count,
                        isLoading: isLoading
                    )
                    
                    // Content Tabs
                    ProfileContentTabs(
                        selectedTab: $selectedTab,
                        highlights: userHighlights,
                        curations: userCurations,
                        isLoading: isLoading
                    )
                    
                    // Settings Section
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        // Lightning Wallet button
                        // Lightning wallet will be enabled when Lightning service is integrated
                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .yellow],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text("Lightning Wallet")
                                    .fontWeight(.medium)
                                    .foregroundColor(.ds.text)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.ds.textTertiary)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.08),
                                        Color.orange.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .magneticHover()
                        
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadUserContent()
            }
        }
        .task {
            await loadUserContent()
        }
        .confirmationDialog("Logout", isPresented: $showLogoutConfirmation) {
            Button("Logout", role: .destructive) {
                Task {
                    HapticManager.shared.impact(.light)
                    await appState.logout()
                }
            }
            Button("Cancel", role: .cancel) {
                HapticManager.shared.impact(.light)
            }
        } message: {
            Text("Are you sure you want to logout? This will clear your session.")
        }
    }
    
    private func loadUserContent() async {
        guard let ndk = appState.ndk, let signer = appState.activeSigner else { return }
        
        isLoading = true
        
        do {
            let pubkey = try await signer.pubkey
            
            // Load user's highlights
            let highlightFilter = NDKFilter(
                authors: [pubkey],
                kinds: [9802],
                limit: 100
            )
            
            let highlightDataSource = await ndk.outbox.observe(
                filter: highlightFilter,
                maxAge: 300, // 5 minute cache
                cachePolicy: .cacheWithNetwork
            )
            
            // Load user's curations
            let curationFilter = NDKFilter(
                authors: [pubkey],
                kinds: [30004],
                limit: 50
            )
            
            let curationDataSource = await ndk.outbox.observe(
                filter: curationFilter,
                maxAge: 600, // 10 minute cache
                cachePolicy: .cacheWithNetwork
            )
            
            // Process highlights
            Task {
                var highlights: [HighlightEvent] = []
                for await event in highlightDataSource.events {
                    if let highlight = try? HighlightEvent(from: event) {
                        highlights.append(highlight)
                    }
                }
                
                await MainActor.run {
                    userHighlights = highlights.sorted { $0.createdAt > $1.createdAt }
                }
            }
            
            // Process curations
            Task {
                var curations: [ArticleCuration] = []
                for await event in curationDataSource.events {
                    if let curation = try? ArticleCuration(from: event) {
                        curations.append(curation)
                    }
                }
                
                await MainActor.run {
                    userCurations = curations.sorted { $0.updatedAt > $1.updatedAt }
                }
            }
            
            // Wait for initial data to load
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await MainActor.run {
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                print("Failed to load user content: \(error)")
            }
        }
    }
}

struct ProfileHeaderView: View {
    let profile: NDKUserProfile?
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Profile Image/Avatar
            if let picture = profile?.picture, let url = URL(string: picture) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    profilePlaceholder
                }
            } else {
                profilePlaceholder
            }
            
            VStack(spacing: DesignSystem.Spacing.small) {
                // Display Name
                Group {
                    if isLoading {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                            .frame(width: 120, height: 20)
                            .shimmer()
                    } else {
                        Text(profile?.displayName ?? profile?.name ?? "Anonymous")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.text)
                    }
                }
                
                // About/Bio
                Group {
                    if isLoading {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                                .frame(width: 200, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                                .frame(width: 160, height: 14)
                        }
                        .shimmer()
                    } else {
                        Text(profile?.about ?? "Nostr user sharing highlights and insights")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var profilePlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.3),
                        DesignSystem.Colors.secondary.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundColor(DesignSystem.Colors.primary)
            )
    }
}

struct StatsView: View {
    let highlightsCount: Int
    let curationsCount: Int
    let isLoading: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            StatItem(
                value: isLoading ? "..." : "\(highlightsCount)",
                label: "Highlights",
                isLoading: isLoading
            )
            StatItem(
                value: isLoading ? "..." : "\(curationsCount)",
                label: "Curations",
                isLoading: isLoading
            )
            StatItem(
                value: isLoading ? "..." : "0", // TODO: Implement zap counting
                label: "Zaps Earned",
                isLoading: isLoading
            )
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.micro) {
            Group {
                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                        .frame(width: 30, height: 18)
                        .shimmer()
                } else {
                    Text(value)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

struct ProfileContentTabs: View {
    @Binding var selectedTab: Int
    let highlights: [HighlightEvent]
    let curations: [ArticleCuration]
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Picker("Content", selection: $selectedTab) {
                Text("Highlights").tag(0)
                Text("Curations").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Content based on selection
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.medium) {
                    if isLoading {
                        // Loading placeholders
                        ForEach(0..<3, id: \.self) { _ in
                            ContentItemPlaceholder()
                        }
                    } else {
                        switch selectedTab {
                        case 0:
                            if highlights.isEmpty {
                                ProfileEmptyStateView(
                                    icon: "quote.bubble",
                                    title: "No Highlights Yet",
                                    subtitle: "Your highlights will appear here"
                                )
                            } else {
                                ForEach(highlights, id: \.id) { highlight in
                                    HighlightCard(highlight: highlight)
                                }
                            }
                            
                        case 1:
                            if curations.isEmpty {
                                ProfileEmptyStateView(
                                    icon: "list.bullet.rectangle",
                                    title: "No Curations Yet",
                                    subtitle: "Your article curations will appear here"
                                )
                            } else {
                                ForEach(curations, id: \.id) { curation in
                                    CurationCard(curation: curation)
                                }
                            }
                            
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(minHeight: 300)
        }
    }
}

struct ContentItemPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(width: 80, height: 12)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                    .frame(width: 40, height: 10)
            }
            
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                .frame(height: 16)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystem.Colors.textTertiary.opacity(0.3))
                .frame(width: 200, height: 14)
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(12)
        .shimmer()
    }
}

struct ProfileEmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

// CurationCard is now defined in SearchView.swift to avoid duplication

#Preview {
    ProfileView()
        .environmentObject(AppState())
}