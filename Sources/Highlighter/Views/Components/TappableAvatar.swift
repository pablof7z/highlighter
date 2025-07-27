import SwiftUI
import NDKSwift

struct TappableAvatar: View {
    let pubkey: String
    let size: CGFloat
    let profile: NDKUserProfile?
    let showOnlineIndicator: Bool
    let enableHoverEffect: Bool
    
    @State private var showingProfile = false
    @State private var isPressed = false
    @State private var isHovering = false
    @State private var loadingProgress: CGFloat = 0
    @Namespace private var animationNamespace
    
    init(
        pubkey: String,
        size: CGFloat = 40,
        profile: NDKUserProfile? = nil,
        showOnlineIndicator: Bool = false,
        enableHoverEffect: Bool = true
    ) {
        self.pubkey = pubkey
        self.size = size
        self.profile = profile
        self.showOnlineIndicator = showOnlineIndicator
        self.enableHoverEffect = enableHoverEffect
    }
    
    var body: some View {
        Button(action: {
            showingProfile = true
            HapticManager.shared.impact(.light)
        }) {
            ZStack {
                // Main avatar
                avatarView
                    .scaleEffect(isPressed ? 0.92 : (isHovering && enableHoverEffect ? 1.05 : 1.0)
                    .animation(AnimationSystem.Curves.springBouncy, value: isPressed)
                    .animation(AnimationSystem.Curves.springSmooth, value: isHovering)
                    .shadow(
                        color: Color.black.opacity(isHovering ? 0.15 : 0.1),
                        radius: isHovering ? 12 : 6,
                        x: 0,
                        y: isHovering ? 4 : 2
                    )
                
                // Online indicator
                if showOnlineIndicator {
                    Circle()
                        .fill(Color.green)
                        .frame(width: size * 0.25, height: size * 0.25)
                        .overlay(
                            Circle()
                                .stroke(Color.ds.background, lineWidth: 2)
                        )
                        .offset(x: size * 0.35, y: size * 0.35)
                        .scaleEffect(isHovering ? 1.2 : 1.0)
                        .animation(AnimationSystem.Curves.springBouncy, value: isHovering)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(AnimationSystem.Curves.springSmooth) {
                isHovering = hovering
            }
        }
        .pressEvents(
            onPress: {
                withAnimation(AnimationSystem.Curves.springBouncy) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(AnimationSystem.Curves.springBouncy) {
                    isPressed = false
                }
            }
        )
        .sheet(isPresented: $showingProfile) {
            UserProfileView(pubkey: pubkey)
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
                .presentationCornerRadius(24)
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        if let picture = profile?.picture, let url = URL(string: picture) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle()
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .transition(.opacity.combined(with: .scale)
                case .failure(_):
                    placeholderAvatar
                        .overlay(
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: size * 0.3)
                                .foregroundColor(.white.opacity(0.8)
                        )
                case .empty:
                    ZStack {
                        placeholderAvatar
                        
                        // Loading animation
                        Circle()
                            .trim(from: 0, to: loadingProgress)
                            .stroke(
                                Color.white.opacity(0.3),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: size - 4, height: size - 4)
                            .rotationEffect(.degrees(-90)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                    loadingProgress = 1
                                }
                            }
                    }
                @unknown default:
                    placeholderAvatar
                }
            }
        } else {
            placeholderAvatar
        }
    }
    
    @ViewBuilder
    private var placeholderAvatar: some View {
        AvatarUtilities.placeholderAvatar(pubkey: pubkey, size: size)
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size * 0.7
                        )
                    )
            )
    }
    
}

// MARK: - Convenience Modifier

extension View {
    func tappableAvatar(
        pubkey: String,
        size: CGFloat = 40,
        profile: NDKUserProfile? = nil,
        showOnlineIndicator: Bool = false,
        enableHoverEffect: Bool = true
    ) -> some View {
        self.overlay(
            TappableAvatar(
                pubkey: pubkey,
                size: size,
                profile: profile,
                showOnlineIndicator: showOnlineIndicator,
                enableHoverEffect: enableHoverEffect
            )
        )
    }
}

// MARK: - Press Events Modifier

private struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    @GestureState private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        if !state {
                            state = true
                            onPress()
                        }
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease)
    }
}