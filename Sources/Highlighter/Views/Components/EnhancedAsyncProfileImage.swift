import SwiftUI
import NDKSwift

// MARK: - Enhanced Async Profile Image with Blur Hash Support

struct EnhancedAsyncProfileImage: View {
    let pubkey: String
    let size: CGFloat
    
    @EnvironmentObject var appState: AppState
    @State private var profile: NDKUserProfile?
    @State private var imageState: ImageLoadState = .loading
    @State private var blurHashImage: Image?
    @State private var profileImage: Image?
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseAnimation = false
    
    enum ImageLoadState: Equatable {
        case loading
        case loaded(Image)
        case failed
        case placeholder
        
        static func == (lhs: ImageLoadState, rhs: ImageLoadState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.failed, .failed), (.placeholder, .placeholder):
                return true
            case (.loaded(_), .loaded(_)):
                return true
            default:
                return false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient placeholder
            Circle()
                .fill(gradientForPubkey())
                .overlay(
                    // Shimmer effect while loading
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .opacity(imageState == .loading ? 1 : 0)
                )
                .mask(Circle())
            
            // Content based on state
            switch imageState {
            case .loading:
                // Show blurhash or initials while loading
                if let blurHashImage = blurHashImage {
                    blurHashImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .blur(radius: 10)
                        .transition(.opacity)
                } else {
                    initialsView
                        .scaleEffect(pulseAnimation ? 1.05 : 0.95)
                        .opacity(pulseAnimation ? 0.8 : 1)
                }
                
            case .loaded(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.1).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                
            case .failed, .placeholder:
                initialsView
            }
            
            // Premium glass overlay for depth
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.clear,
                            Color.black.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
            
            // Border with gradient
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: borderColors(),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: borderWidth()
                )
        }
        .frame(width: size, height: size)
        .shadow(color: shadowColor(), radius: shadowRadius(), y: 2)
        .task {
            await loadProfile()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Subviews
    
    private var initialsView: some View {
        Text(PubkeyFormatter.formatForAvatar(pubkey))
            .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    private func gradientForPubkey() -> LinearGradient {
        // Generate consistent gradient based on pubkey
        let hash = pubkey.hashValue
        let hue1 = Double(abs(hash % 360)) / 360.0
        let hue2 = (hue1 + 0.1).truncatingRemainder(dividingBy: 1.0)
        
        return LinearGradient(
            colors: [
                Color(hue: hue1, saturation: 0.7, brightness: 0.8),
                Color(hue: hue2, saturation: 0.6, brightness: 0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func borderColors() -> [Color] {
        switch imageState {
        case .loaded:
            return [
                Color.white.opacity(0.5),
                Color.white.opacity(0.2)
            ]
        case .loading:
            return [
                DesignSystem.Colors.primary.opacity(0.6),
                DesignSystem.Colors.secondary.opacity(0.4)
            ]
        default:
            return [
                Color.white.opacity(0.3),
                Color.white.opacity(0.1)
            ]
        }
    }
    
    private func borderWidth() -> CGFloat {
        size >= 60 ? 2 : 1
    }
    
    private func shadowColor() -> Color {
        switch imageState {
        case .loaded:
            return Color.black.opacity(0.2)
        case .loading:
            return DesignSystem.Colors.primary.opacity(0.3)
        default:
            return Color.black.opacity(0.1)
        }
    }
    
    private func shadowRadius() -> CGFloat {
        size >= 60 ? 6 : 3
    }
    
    // MARK: - Data Loading
    
    private func loadProfile() async {
        guard let ndk = appState.ndk else {
            imageState = .placeholder
            return
        }
        
        // Subscribe to profile updates
        for await profile in await ndk.profileManager.observe(for: pubkey, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.profile = profile
            }
            
            // Load actual image
            if let picture = profile?.picture, let url = URL(string: picture) {
                await loadImage(from: url)
            } else {
                await MainActor.run {
                    imageState = .placeholder
                }
            }
            
            break // Only need current value
        }
    }
    
    // BlurHash support can be added later when NDKUserProfile includes it
    
    private func loadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        profileImage = Image(uiImage: uiImage)
                        imageState = .loaded(Image(uiImage: uiImage))
                    }
                }
            } else {
                await MainActor.run {
                    imageState = .failed
                }
            }
        } catch {
            await MainActor.run {
                imageState = .failed
            }
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Shimmer animation
        withAnimation(
            .linear(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 200
        }
        
        // Pulse animation for placeholder
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
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
                EnhancedAsyncProfileImage(pubkey: pubkey, size: size)
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
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .frame(width: size, height: size)
                    .overlay(
                        Text("+\(pubkeys.count - maxCount)")
                            .font(.system(size: size * 0.35, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
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
            EnhancedAsyncProfileImage(pubkey: "test1", size: 80)
            EnhancedAsyncProfileImage(pubkey: "test2", size: 60)
            EnhancedAsyncProfileImage(pubkey: "test3", size: 40)
            EnhancedAsyncProfileImage(pubkey: "test4", size: 32)
        }
        
        // Profile grid
        ProfileImageGrid(
            pubkeys: ["test1", "test2", "test3", "test4", "test5"],
            size: 40
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
    .environmentObject(AppState())
}