import SwiftUI

// MARK: - Unified Animation System
// Consolidates all animation functionality into a single, cohesive system
// Following DRY principles to eliminate duplication across the codebase

struct AnimationSystem {
    
    // MARK: - Animation Curves (From DesignSystem + PremiumAnimations)
    
    enum Curves {
        /// Ultra-smooth spring animation for premium feel
        static let premiumSpring = Animation.interpolatingSpring(
            mass: 1.0,
            stiffness: 100,
            damping: 20,
            initialVelocity: 0
        )
        
        /// Subtle spring for responsive interactions
        static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.9)
        
        /// Smooth spring for general animations
        static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.85)
        
        /// Gentle spring for subtle interactions
        static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.95)
        
        /// Minimal bounce for refined emphasis
        static let elasticBounce = Animation.interpolatingSpring(
            mass: 1.0,
            stiffness: 120,
            damping: 18,
            initialVelocity: 0
        )
        
        /// Standard timing curves
        static let instant = Animation.easeOut(duration: 0.15)
        static let quick = Animation.easeOut(duration: 0.2)
        static let standard = Animation.easeOut(duration: 0.25)
        static let smooth = Animation.easeOut(duration: 0.35)
        
        /// Quick responsive animation for immediate feedback
        static let quickResponse = Animation.timingCurve(0.2, 0.8, 0.2, 1.0, duration: 0.15)
        
        /// Smooth entrance animation with slight overshoot
        static let smoothEntrance = Animation.timingCurve(0.05, 0.7, 0.1, 1.05, duration: 0.4)
        
        /// Gentle fade with scale for content appearance
        static let gentleFadeScale = Animation.timingCurve(0.23, 1, 0.32, 1, duration: 0.5)
        
        /// Interactive animations
        static let interactive = Animation.interactiveSpring(response: 0.15, dampingFraction: 0.86, blendDuration: 0.25)
    }
    
    // MARK: - Staggered Animation Helpers
    
    /// Create staggered animations for list items
    static func staggered(index: Int, delay: Double = 0.1) -> Animation {
        return Curves.smoothEntrance.delay(Double(index) * delay)
    }
    
    /// Create wave-like staggered animations
    static func wave(index: Int, total: Int, duration: Double = 1.0) -> Animation {
        let normalizedIndex = Double(index) / Double(max(total - 1, 1))
        let waveDelay = sin(normalizedIndex * .pi) * 0.3
        return Curves.premiumSpring.delay(waveDelay)
    }
}

// MARK: - Scale Animations (Consolidating SpringyScale, HeroScale, etc.)

struct ScaleEffect: ViewModifier {
    let isActive: Bool
    let scale: CGFloat
    let animation: Animation
    let includeShadow: Bool
    
    init(
        isActive: Bool,
        scale: CGFloat = 1.1,
        animation: Animation = AnimationSystem.Curves.springSnappy,
        includeShadow: Bool = false
    ) {
        self.isActive = isActive
        self.scale = scale
        self.animation = animation
        self.includeShadow = includeShadow
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? scale : 1.0)
            .shadow(
                color: includeShadow ? DesignSystem.Colors.primary.opacity(isActive ? 0.2 : 0) : Color.clear,
                radius: includeShadow && isActive ? 20 : 0,
                x: 0,
                y: includeShadow && isActive ? 10 : 0
            )
            .animation(animation, value: isActive)
    }
}

// MARK: - Slide Animations

struct SlideEffect: ViewModifier {
    let isVisible: Bool
    let edge: Edge
    let animation: Animation
    
    init(
        isVisible: Bool,
        edge: Edge = .bottom,
        animation: Animation = AnimationSystem.Curves.springSmooth
    ) {
        self.isVisible = isVisible
        self.edge = edge
        self.animation = animation
    }
    
    func body(content: Content) -> some View {
        content
            .offset(slideOffset)
            .opacity(isVisible ? 1 : 0)
            .animation(animation, value: isVisible)
    }
    
    private var slideOffset: CGSize {
        guard !isVisible else { return .zero }
        
        switch edge {
        case .top:
            return CGSize(width: 0, height: -UIScreen.main.bounds.height)
        case .bottom:
            return CGSize(width: 0, height: UIScreen.main.bounds.height)
        case .leading:
            return CGSize(width: -UIScreen.main.bounds.width, height: 0)
        case .trailing:
            return CGSize(width: UIScreen.main.bounds.width, height: 0)
        }
    }
}

// MARK: - Bounce Effect (From Animations.swift)

struct BounceEffect: ViewModifier {
    @State private var bounceScale: CGFloat = 1
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(bounceScale)
            .onChange(of: trigger) { _, _ in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                    bounceScale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                    bounceScale = 1.0
                }
            }
    }
}

// MARK: - Typewriter Effect (From Animations.swift)

struct TypewriterEffect: ViewModifier {
    let text: String
    let speed: Double
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    func body(content: Content) -> some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
            .onChange(of: text) { _, newValue in
                displayedText = ""
                currentIndex = 0
                animateText()
            }
    }
    
    private func animateText() {
        guard currentIndex < text.count else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            let index = text.index(text.startIndex, offsetBy: currentIndex)
            displayedText += String(text[index])
            currentIndex += 1
            animateText()
        }
    }
}

// MARK: - Morphing Card (From ModernAnimations.swift)

struct MorphingCard: ViewModifier {
    let isExpanded: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isExpanded ? 1.02 : 1.0)
            .shadow(
                color: Color.black.opacity(isExpanded ? 0.15 : 0.08),
                radius: isExpanded ? 20 : 10,
                x: 0,
                y: isExpanded ? 10 : 5
            )
            .animation(
                AnimationSystem.Curves.springSmooth,
                value: isExpanded
            )
    }
}

// MARK: - Parallax Effect (From ModernAnimations.swift)

struct ParallaxEffect: ViewModifier {
    let offset: CGFloat
    let multiplier: CGFloat
    
    init(offset: CGFloat, multiplier: CGFloat = 0.5) {
        self.offset = offset
        self.multiplier = multiplier
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset * multiplier)
    }
}

// MARK: - Ripple Effect (From ModernAnimations.swift)

struct RippleEffect: ViewModifier {
    let trigger: Bool
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(DesignSystem.Colors.primary)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.easeOut(duration: 0.6), value: scale)
                    .animation(.easeOut(duration: 0.6), value: opacity)
            )
            .onChange(of: trigger) { _, _ in
                scale = 0
                opacity = 0.5
                
                withAnimation {
                    scale = 3
                    opacity = 0
                }
            }
    }
}

// MARK: - Premium Entrance (From PremiumAnimations.swift)

struct PremiumEntranceModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                withAnimation(AnimationSystem.Curves.smoothEntrance.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Premium Hover (From PremiumAnimations.swift)

struct PremiumHoverModifier: ViewModifier {
    @State private var isHovered = false
    let scale: CGFloat
    let shadowRadius: CGFloat
    
    init(scale: CGFloat = 1.03, shadowRadius: CGFloat = 12) {
        self.scale = scale
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .shadow(
                color: DesignSystem.Colors.primary.opacity(isHovered ? 0.2 : 0.1),
                radius: isHovered ? shadowRadius : 6,
                x: 0,
                y: isHovered ? 6 : 3
            )
            .animation(AnimationSystem.Curves.premiumSpring, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Premium Press (From PremiumAnimations.swift)

struct PremiumPressModifier: ViewModifier {
    @State private var isPressed = false
    let hapticStyle: HapticManager.ImpactStyle
    let scale: CGFloat
    
    init(hapticStyle: HapticManager.ImpactStyle = .light, scale: CGFloat = 0.96) {
        self.hapticStyle = hapticStyle
        self.scale = scale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(AnimationSystem.Curves.quickResponse, value: isPressed)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                    if pressing {
                        HapticManager.shared.impact(hapticStyle)
                    }
                },
                perform: {}
            )
    }
}

// MARK: - Floating Animation (From PremiumAnimations.swift)

struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    let amplitude: CGFloat
    let duration: Double
    
    init(amplitude: CGFloat = 3, duration: Double = 3.0) {
        self.amplitude = amplitude
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - Shimmer Effect (Consolidating multiple implementations)

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    let brightness: Double
    
    init(duration: Double = 1.5, brightness: Double = 0.6) {
        self.duration = duration
        self.brightness = brightness
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(brightness),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(15))
                    .offset(x: -200 + (phase * 400))
                    .animation(
                        .linear(duration: duration).repeatForever(autoreverses: false),
                        value: phase
                    )
            )
            .clipped()
            .onAppear {
                phase = 1
            }
    }
}

// MARK: - Magnetic Hover Effect (From ModernAnimations.swift)

struct MagneticHover: ViewModifier {
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .onHover { hovering in
                if !hovering {
                    offset = .zero
                    isDragging = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let maxOffset: CGFloat = 10
                        offset = CGSize(
                            width: min(max(value.translation.width * 0.1, -maxOffset), maxOffset),
                            height: min(max(value.translation.height * 0.1, -maxOffset), maxOffset)
                        )
                    }
                    .onEnded { _ in
                        offset = .zero
                        isDragging = false
                    }
            )
    }
}

// MARK: - Glow Effect (From PremiumAnimations.swift)

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let isActive: Bool
    
    init(color: Color = DesignSystem.Colors.secondary, radius: CGFloat = 8, isActive: Bool = true) {
        self.color = color
        self.radius = radius
        self.isActive = isActive
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                content
                    .blur(radius: radius / 2)
                    .opacity(isActive ? 0.8 : 0)
                    .blendMode(.multiply)
            )
            .shadow(
                color: color.opacity(isActive ? 0.6 : 0),
                radius: radius,
                x: 0,
                y: 0
            )
            .animation(AnimationSystem.Curves.gentleFadeScale, value: isActive)
    }
}

// MARK: - Pulse Effects (Consolidating multiple pulse implementations)

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let style: PulseStyle
    
    enum PulseStyle {
        case gentle
        case standard
        case strong
        
        var scale: CGFloat {
            switch self {
            case .gentle: return 1.02
            case .standard: return 1.05
            case .strong: return 1.1
            }
        }
        
        var duration: Double {
            switch self {
            case .gentle: return 2.5
            case .standard: return 1.0
            case .strong: return 0.8
            }
        }
        
        var opacity: (from: Double, to: Double) {
            switch self {
            case .gentle: return (1.0, 0.9)
            case .standard: return (1.0, 1.0)
            case .strong: return (1.0, 0.8)
            }
        }
    }
    
    init(style: PulseStyle = .standard) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? style.scale : 1.0)
            .opacity(isPulsing ? style.opacity.to : style.opacity.from)
            .animation(
                .easeInOut(duration: style.duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions (Unified from all files)

extension View {
    // Scale animations
    func scaleEffect(isActive: Bool, scale: CGFloat = 1.1, includeShadow: Bool = false) -> some View {
        modifier(ScaleEffect(isActive: isActive, scale: scale, includeShadow: includeShadow))
    }
    
    func heroScale(isActive: Bool, scale: CGFloat = 1.05) -> some View {
        modifier(ScaleEffect(isActive: isActive, scale: scale, includeShadow: true))
    }
    
    // Slide animations
    func slideEffect(isVisible: Bool, from edge: Edge = .bottom) -> some View {
        modifier(SlideEffect(isVisible: isVisible, edge: edge))
    }
    
    // Bounce effect
    func bounceEffect(trigger: Bool) -> some View {
        modifier(BounceEffect(trigger: trigger))
    }
    
    // Typewriter effect
    func typewriter(_ text: String, speed: Double = 0.05) -> some View {
        modifier(TypewriterEffect(text: text, speed: speed))
    }
    
    // Card animations
    func morphingCard(isExpanded: Bool) -> some View {
        modifier(MorphingCard(isExpanded: isExpanded))
    }
    
    // Parallax
    func parallax(offset: CGFloat, multiplier: CGFloat = 0.5) -> some View {
        modifier(ParallaxEffect(offset: offset, multiplier: multiplier))
    }
    
    // Ripple effect
    func rippleEffect(trigger: Bool) -> some View {
        modifier(RippleEffect(trigger: trigger))
    }
    
    // Premium animations
    func premiumEntrance(delay: Double = 0) -> some View {
        modifier(PremiumEntranceModifier(delay: delay))
    }
    
    func premiumHover(scale: CGFloat = 1.03, shadowRadius: CGFloat = 12) -> some View {
        #if os(macOS)
        modifier(PremiumHoverModifier(scale: scale, shadowRadius: shadowRadius))
        #else
        self
        #endif
    }
    
    func premiumPress(hapticStyle: HapticManager.ImpactStyle = .light, scale: CGFloat = 0.96) -> some View {
        modifier(PremiumPressModifier(hapticStyle: hapticStyle, scale: scale))
    }
    
    func floating(amplitude: CGFloat = 3, duration: Double = 3.0) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration))
    }
    
    func shimmer(duration: Double = 1.5, brightness: Double = 0.6) -> some View {
        modifier(ShimmerModifier(duration: duration, brightness: brightness))
    }
    
    func glow(color: Color = DesignSystem.Colors.secondary, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(GlowModifier(color: color, radius: radius, isActive: isActive))
    }
    
    func pulse(style: PulseModifier.PulseStyle = .standard) -> some View {
        modifier(PulseModifier(style: style))
    }
    
    func magneticHover() -> some View {
        modifier(MagneticHover())
    }
    
    // Convenience methods
    func premiumCardInteraction() -> some View {
        self
            .premiumHover()
            .premiumPress()
    }
    
    func staggeredEntrance(index: Int, delay: Double = 0.1) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(AnimationSystem.staggered(index: index, delay: delay)) {
                    // SwiftUI automatically animates to the view's natural state
                }
            }
    }
}

// MARK: - Transition Extensions

extension AnyTransition {
    /// Premium fade with scale
    static var premiumFadeScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
        .animation(AnimationSystem.Curves.gentleFadeScale)
    }
    
    /// Premium slide with overshoot
    static func premiumSlide(from edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge).combined(with: .opacity)
        )
        .animation(AnimationSystem.Curves.smoothEntrance)
    }
}

// MARK: - Animated Components (From ModernAnimations.swift)

// MARK: - Mesh Gradient Background
// Note: MeshGradientBackground is defined in Views/Components/MeshGradientBackground.swift


struct ModernProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                
                // Progress
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary,
                                DesignSystem.Colors.secondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                
                // Glow effect
                if progress > 0 {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: geometry.size.height * 0.5)
                        .offset(y: -geometry.size.height * 0.25)
                        .blur(radius: 2)
                }
            }
        }
        .frame(height: 20)
    }
}

// MARK: - Animated Number (From ModernAnimations.swift)

struct AnimatedNumber: View {
    let value: Int
    let duration: Double
    let suffix: String
    @State private var displayValue: Int = 0
    
    init(value: Int, duration: Double = 0.5, suffix: String = "") {
        self.value = value
        self.duration = duration
        self.suffix = suffix
    }
    
    var body: some View {
        Text("\(displayValue)\(suffix)")
            .contentTransition(.numericText(countsDown: value < displayValue))
            .onAppear {
                animate()
            }
            .onChange(of: value) { _, _ in
                animate()
            }
    }
    
    private func animate() {
        withAnimation(.easeInOut(duration: duration)) {
            displayValue = value
        }
    }
}

// MARK: - Animated Checkmark (From Animations.swift)

struct AnimatedCheckmark: View {
    let isChecked: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .foregroundColor(.gray.opacity(0.3))
                .frame(width: 24, height: 24)
            
            if isChecked {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.secondary, DesignSystem.Colors.secondaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .transition(.scale.combined(with: .opacity))
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
    }
}

// MARK: - Animation Preview

#Preview {
    VStack(spacing: 40) {
        Text("Unified Animation System")
            .font(.largeTitle)
            .heroScale(isActive: true)
        
        RoundedRectangle(cornerRadius: 20)
            .fill(DesignSystem.Colors.primary)
            .frame(width: 200, height: 100)
            .morphingCard(isExpanded: true)
        
        ModernLoadingView()
        
        ModernProgressBar(progress: 0.7)
            .padding(.horizontal, 40)
        
        AnimatedNumber(value: 42)
            .font(.system(size: 48, weight: .bold, design: .rounded))
        
        AnimatedCheckmark(isChecked: true)
    }
    .padding()
}