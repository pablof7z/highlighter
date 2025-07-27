import Foundation
import NDKSwift
import Combine

@MainActor
class AppState: ObservableObject {
    // NDK Core
    @Published private(set) var ndk: NDK?
    
    // Auth Manager
    @Published private var authManager = NDKAuthManager.shared
    
    // Service Dependencies
    @Published private(set) var dataStreamManager = DataStreamManager()
    @Published private(set) var publishingService = PublishingService()
    @Published private(set) var bookmarkService = BookmarkService()
    @Published private(set) var commentService = CommentService()
    @Published private(set) var engagementService = EngagementService()
    @Published private(set) var lightningService = LightningService()
    @Published private(set) var readingProgressService = ReadingProgressService()
    @Published private(set) var archiveService = ArchiveService()
    
    // Content State - these need to be @Published for UI updates
    @Published var highlights: [HighlightEvent] = []
    @Published var curations: [ArticleCuration] = []
    @Published var userCurations: [ArticleCuration] = []
    @Published var followPacks: [FollowPack] = []
    @Published var articles: [Article] = []
    @Published var savedArticles: [Article] = []
    @Published var currentUserProfile: NDKUserProfile?
    
    // App-level state
    @Published private(set) var following: Set<String> = []
    @Published var selectedTab = 0
    @Published var errorMessage: String?
    
    var isAuthenticated: Bool {
        authManager.isAuthenticated
    }
    
    var activeSigner: NDKSigner? {
        authManager.activeSigner
    }
    
    @Published var userPubkey: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Sync DataStreamManager content with AppState
        dataStreamManager.$highlights
            .receive(on: DispatchQueue.main)
            .assign(to: &$highlights)
        
        dataStreamManager.$curations
            .receive(on: DispatchQueue.main)
            .assign(to: &$curations)
        
        dataStreamManager.$followPacks
            .receive(on: DispatchQueue.main)
            .assign(to: &$followPacks)
        
        dataStreamManager.$articles
            .receive(on: DispatchQueue.main)
            .assign(to: &$articles)
        
        // User curations will be filtered based on current user
        dataStreamManager.$curations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allCurations in
                guard let self = self, let userPubkey = self.userPubkey else {
                    self?.userCurations = []
                    return
                }
                self.userCurations = allCurations.filter { $0.author == userPubkey }
            }
            .store(in: &cancellables)
    }
    
    private func configureServices(ndk: NDK, signer: NDKSigner?) {
        dataStreamManager.configure(with: ndk)
        publishingService.configure(with: ndk, signer: signer)
        bookmarkService.configure(with: ndk, signer: signer)
        commentService.configure(with: ndk, signer: signer)
        engagementService.configure(with: ndk, signer: signer)
        archiveService.configure(with: ndk, signer: signer)
        lightningService.setNDK(ndk, signer: signer)
        ImageUploadService.shared.configure(with: ndk)
    }
    
    func initialize() async {
        do {
            // Configure logging for debugging
            #if DEBUG
            NDKLogger.configure(
                logLevel: .debug,
                enabledCategories: [.relay, .outbox, .subscription, .event, .auth],
                logNetworkTraffic: false // Set to true to see raw network messages
            )
            #endif
            
            // Setup NDK with cache
            let cache = try await NDKSQLiteCache(path: nil)
            ndk = NDK(
                relayUrls: RelayConstants.extendedRelays.dropLast(),
                cache: cache
            )
            
            // Configure services with NDK instance
            guard let ndk = ndk else { return }
            configureServices(ndk: ndk, signer: authManager.activeSigner)
            
            // Connect to relays asynchronously
            Task {
                await ndk.connect()
            }
            
            // Set NDK instance in auth manager
            authManager.setNDK(ndk)
            
            // Initialize auth manager (restores sessions automatically)
            await authManager.initialize()
            
            // Set user pubkey if authenticated
            if let signer = activeSigner {
                userPubkey = try? await signer.pubkey
            }
            
            // Start NIP-77 sync in background
            Task {
                await syncHighlights()
            }
            
            // If authenticated after restore, start services immediately
            if authManager.isAuthenticated {
                // Start streaming data
                await dataStreamManager.startAllStreams()
                
                // Load user profile in background
                if let signer = authManager.activeSigner {
                    Task {
                        await loadCurrentUserProfile(for: signer)
                    }
                }
                
                // Load following list
                Task {
                    try? await loadFollowingList()
                }
            }
        } catch {
            errorMessage = "Failed to initialize: \(error.localizedDescription)"
        }
    }
    
    func createAccount() async throws {
        guard let ndk = ndk else { throw AuthError.noSigner }
        
        let signer = try NDKPrivateKeySigner.generate()
        
        // Start NDK session first
        try await ndk.startSession(
            signer: signer,
            config: NDKSessionConfiguration(
                dataRequirements: [.followList, .muteList],
                preloadStrategy: .progressive
            )
        )
        
        // Create persistent auth session
        let session = try await authManager.createSession(
            with: signer,
            requiresBiometric: true
        )
        
        try await authManager.switchToSession(session)
        
        // Update services with new signer
        configureServices(ndk: ndk, signer: signer)
        
        // Set user pubkey
        userPubkey = try? await signer.pubkey
        
        // Start streaming data
        await dataStreamManager.startAllStreams()
        
        // Following list will be empty for new accounts
    }
    
    func importAccount(nsec: String) async throws {
        guard let ndk = ndk else { throw AuthError.noSigner }
        
        let signer = try NDKPrivateKeySigner(nsec: nsec)
        
        // Start NDK session first
        try await ndk.startSession(
            signer: signer,
            config: NDKSessionConfiguration(
                dataRequirements: [.followList, .muteList],
                preloadStrategy: .progressive
            )
        )
        
        // Create persistent auth session
        let session = try await authManager.createSession(
            with: signer,
            requiresBiometric: true
        )
        
        try await authManager.switchToSession(session)
        
        // Update services with new signer
        configureServices(ndk: ndk, signer: signer)
        
        // Set user pubkey
        userPubkey = try? await signer.pubkey
        
        // Start streaming data
        await dataStreamManager.startAllStreams()
        
        // Load user profile
        await loadCurrentUserProfile(for: signer)
        
        // Load following list
        try? await loadFollowingList()
    }
    
    private func loadCurrentUserProfile(for signer: NDKSigner) async {
        guard let ndk = ndk else { return }
        
        do {
            let pubkey = try await signer.pubkey
            
            // Use NDK's profile manager to observe profile updates
            Task {
                for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                    await MainActor.run {
                        self.currentUserProfile = profile
                    }
                }
            }
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }
    
    func logout() async {
        // Stop all services
        dataStreamManager.stopAllStreams()
        
        // Clear service state
        await dataStreamManager.refresh()
        currentUserProfile = nil
        following = []
        
        // Proper logout implementation - clear cache and delete sessions from keychain
        Task {
            // Clear cache data
            if let cache = ndk?.cache {
                try? await cache.clear()
            }
            
            // Delete ALL sessions from keychain - this is critical!
            for session in authManager.availableSessions {
                try? await authManager.deleteSession(session)
            }
        }
        
        // Clear memory state
        authManager.logout()
    }
    
    // MARK: - Private Methods
    
    private func syncHighlights() async {
        guard let ndk = ndk else { return }
        
        do {
            // Check if relay supports NIP-77
            let supportsNegentropy = await ndk.relaySupportsNegentropy("wss://relay.damus.io")
            
            if supportsNegentropy {
                // Create filter for kind 9802 (highlights) with time limit for efficiency
                let weekAgo = Int64(Date().timeIntervalSince1970 - 7 * 24 * 60 * 60)
                let highlightFilter = NDKFilter(
                    kinds: [9802],
                    since: Timestamp(weekAgo)
                )
                
                NDKLogger.log(.info, category: .sync, "Starting NIP-77 sync for highlights from relay.damus.io")
                
                // Perform NIP-77 sync with relay.damus.io
                let result = try await ndk.syncEvents(
                    filter: highlightFilter,
                    relay: "wss://relay.damus.io",
                    direction: .receive // Only download, don't upload
                )
                
                NDKLogger.log(.info, category: .sync, """
                    NIP-77 sync completed:
                    - Downloaded events: \(result.downloadedEvents.count)
                    - Message rounds: \(result.messageRounds)
                    - Efficiency ratio: \(result.efficiencyRatio)%
                    - Duration: \(String(format: "%.2f", result.duration))s
                """)
                
                // Let the DataStreamManager handle the highlights after sync
                await dataStreamManager.refresh()
            } else {
                NDKLogger.log(.info, category: .sync, "Relay doesn't support NIP-77, using standard subscription")
            }
            
        } catch {
            NDKLogger.log(.warning, category: .sync, "NIP-77 sync failed: \(error.localizedDescription)")
            // Don't show error to user, continue with normal operation
        }
    }
    
    // MARK: - Publishing Methods (delegated to PublishingService)
    
    func publishHighlight(_ highlight: HighlightEvent) async throws {
        try await publishingService.publishHighlight(highlight)
    }
    
    func createCuration(name: String, title: String, description: String?, image: String?) async throws {
        try await publishingService.createCuration(name: name, title: title, description: description, image: image)
    }
    
    // MARK: - Follow Management (NIP-02)
    
    /// Follow a user by adding them to the contact list
    func followUser(_ pubkey: String) async throws {
        guard let ndk = ndk else {
            throw AuthError.noSigner
        }
        
        let userToFollow = NDKUser(pubkey: pubkey)
        
        // Use NDK's built-in follow method
        try await ndk.follow(userToFollow)
        
        // Update local following set
        following.insert(pubkey)
    }
    
    /// Unfollow a user by removing them from the contact list
    func unfollowUser(_ pubkey: String) async throws {
        guard let ndk = ndk else {
            throw AuthError.noSigner
        }
        
        let userToUnfollow = NDKUser(pubkey: pubkey)
        
        // Use NDK's built-in unfollow method
        try await ndk.unfollow(userToUnfollow)
        
        // Update local following set
        following.remove(pubkey)
    }
    
    /// Check if the current user is following a specific user
    func isFollowing(_ pubkey: String) async throws -> Bool {
        // First check local cache
        if following.contains(pubkey) {
            return true
        }
        
        guard let ndk = ndk else {
            throw AuthError.noSigner
        }
        
        // Get contact list
        guard let contactList = try await ndk.fetchContactList() else {
            return false
        }
        
        // Check if following
        let isFollowing = contactList.isFollowing(pubkey)
        
        // Update local cache
        if isFollowing {
            following.insert(pubkey)
        }
        
        return isFollowing
    }
    
    /// Load the current user's following list
    func loadFollowingList() async throws {
        guard let ndk = ndk else {
            throw AuthError.noSigner
        }
        
        // Get contact list
        guard let contactList = try await ndk.fetchContactList() else {
            following = []
            return
        }
        
        // Update local following set
        following = Set(contactList.contactPubkeys)
    }
    
    // MARK: - Relay Monitoring
    
    /// Get current relay connection status
    func getRelayConnectionStatus() async -> [(url: String, isConnected: Bool)] {
        // This functionality requires access to internal NDKSwift APIs
        // Return empty array for now
        return []
    }
    
    /// Monitor relay selection for a specific event
    func monitorRelaySelection(for event: NDKEvent) async {
        guard ndk != nil else { return }
        
        // Log the relays that would be used for publishing this event
        NDKLogger.log(.info, category: .outbox, """
            Publishing event \(event.id) to configured relays
        """)
    }
    
    /// Check if using optimized Negentropy sync is beneficial
    func shouldUseNegentropySync() async -> Bool {
        guard ndk != nil else { return false }
        
        // Check if we have substantial data to sync
        let highlightCount = highlights.count
        let curationCount = curations.count
        
        // Use Negentropy for large datasets
        return (highlightCount + curationCount) > 100
    }
}

enum AuthError: LocalizedError {
    case invalidPrivateKey
    case noSigner
    
    var errorDescription: String? {
        switch self {
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .noSigner:
            return "No signer configured"
        }
    }
}
