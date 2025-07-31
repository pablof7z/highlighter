import SwiftUI
import NDKSwift
import NDKSwiftUI

/// Wrapper around NDKUIProfilePicture to maintain API compatibility
/// while leveraging NDKSwiftUI's proven implementation
struct ProfileImage: View {
    let pubkey: String
    let size: CGFloat
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NDKUIProfilePicture(ndk: appState.ndk, pubkey: pubkey)
            .frame(width: size, height: size)
    }
}

// MARK: - Convenience Modifiers

extension View {
    func profileImageStyle(size: CGFloat) -> some View {
        self
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 3, y: 2)
    }
}

// MARK: - Static Profile Image Grid (for discovery)

struct ProfileImageGrid: View {
    let pubkeys: [String]
    let size: CGFloat
    let maxCount: Int
    
    init(pubkeys: [String], size: CGFloat = 32, maxCount: Int = 4) {
        self.pubkeys = pubkeys
        self.size = size
        self.maxCount = maxCount
    }
    
    var body: some View {
        HStack(spacing: -size * 0.3) {
            ForEach(Array(pubkeys.prefix(maxCount).enumerated()), id: \.element) { index, pubkey in
                ProfileImage(pubkey: pubkey, size: size)
                    .zIndex(Double(maxCount - index))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    ))
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(Double(index) * 0.05),
                        value: pubkeys
                    )
            }
            
            if pubkeys.count > maxCount {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: size, height: size)
                    .overlay(
                        Text("+\(pubkeys.count - maxCount)")
                            .font(.system(size: size * 0.35, weight: .semibold))
                            .foregroundColor(.secondary)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 3, y: 2)
                    .zIndex(0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        // Different sizes
        HStack(spacing: 20) {
            ProfileImage(pubkey: "test1", size: 80)
            ProfileImage(pubkey: "test2", size: 60)
            ProfileImage(pubkey: "test3", size: 40)
            ProfileImage(pubkey: "test4", size: 32)
        }
        
        // Profile grid
        ProfileImageGrid(
            pubkeys: ["test1", "test2", "test3", "test4", "test5"],
            size: 40
        )
    }
    .padding()
    .background(Color(.systemBackground))
}