import Foundation
import NDKSwift
import Combine

/// Manages user profile loading and caching
/// Follows SRP by focusing solely on profile management operations
@MainActor
class ProfileManager: ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentUserProfile: NDKUserProfile?
    @Published private(set) var cachedProfiles: [String: NDKUserProfile] = [:]
    
    // MARK: - Private Properties
    private weak var ndk: NDK?
    private var profileTasks: [Task<Void, Never>] = []
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Configuration
    func configure(with ndk: NDK) {
        self.ndk = ndk
    }
    
    // MARK: - Profile Loading
    
    /// Load the current user's profile
    func loadCurrentUserProfile(for signer: NDKSigner) async {
        guard let ndk = ndk else { return }
        
        let pubkey: String
        do {
            pubkey = try await signer.pubkey
        } catch {
            print("Failed to get pubkey: \(error)")
            return
        }
        
        // Check cache first and set immediately if available
        if let cachedProfile = cachedProfiles[pubkey] {
            currentUserProfile = cachedProfile
        }
        
        // Always stream for updates - following "never wait, always stream" principle
        let profileTask = Task {
            for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                await MainActor.run {
                    self.currentUserProfile = profile
                    if let profile = profile {
                        self.cachedProfiles[pubkey] = profile
                    }
                }
            }
        }
        profileTasks.append(profileTask)
    }
    
    /// Stream profile for any pubkey with caching
    func streamProfile(for pubkey: String) {
        guard let ndk = ndk else { return }
        
        // Start streaming profile updates
        let task = Task {
            for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                await MainActor.run {
                    if let profile = profile {
                        self.cachedProfiles[pubkey] = profile
                    }
                }
            }
        }
        profileTasks.append(task)
    }
    
    /// Get cached profile if available (no waiting)
    func getCachedProfile(for pubkey: String) -> NDKUserProfile? {
        return cachedProfiles[pubkey]
    }
    
    /// Clear current user profile (e.g., on logout)
    func clearCurrentUserProfile() {
        currentUserProfile = nil
    }
    
    /// Clear all cached profiles
    func clearCache() {
        cachedProfiles.removeAll()
        currentUserProfile = nil
    }
    
    /// Stop all active profile loading tasks
    func stopAllTasks() {
        for task in profileTasks {
            task.cancel()
        }
        profileTasks.removeAll()
    }
    
    // MARK: - Utility Methods
    
    /// Get display name for a pubkey, with fallback to formatted pubkey
    func displayName(for pubkey: String) -> String {
        if let profile = cachedProfiles[pubkey] {
            return PubkeyFormatter.displayName(from: profile, pubkey: pubkey)
        }
        return PubkeyFormatter.formatShort(pubkey)
    }
    
    /// Check if profile is cached
    func isCached(_ pubkey: String) -> Bool {
        return cachedProfiles[pubkey] != nil
    }
    
    // MARK: - Cleanup
    deinit {
        // Tasks will be automatically cancelled when the instance is deallocated
    }
}