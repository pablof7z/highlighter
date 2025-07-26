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
    @Published private(set) var isLoadingProfile = false
    
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
        
        isLoadingProfile = true
        
        let pubkey: String
        do {
            pubkey = try await signer.pubkey
        } catch {
            print("Failed to get pubkey: \(error)")
            isLoadingProfile = false
            return
        }
        
        // Check cache first
        if let cachedProfile = cachedProfiles[pubkey] {
            currentUserProfile = cachedProfile
            isLoadingProfile = false
            return
        }
        
        // Use profile manager for efficient caching
        let profileTask = Task {
            for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                await MainActor.run {
                    self.currentUserProfile = profile
                    self.cachedProfiles[pubkey] = profile
                    self.isLoadingProfile = false
                }
                break // Only need current value
            }
        }
        profileTasks.append(profileTask)
    }
    
    /// Load profile for any pubkey with caching
    func loadProfile(for pubkey: String) async -> NDKUserProfile? {
        guard let ndk = ndk else { return nil }
        
        // Check cache first
        if let cachedProfile = cachedProfiles[pubkey] {
            return cachedProfile
        }
        
        // Load from network
        return await withCheckedContinuation { continuation in
            let task = Task {
                for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
                    await MainActor.run {
                        self.cachedProfiles[pubkey] = profile
                    }
                    continuation.resume(returning: profile)
                    return
                }
                continuation.resume(returning: nil)
            }
            profileTasks.append(task)
        }
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