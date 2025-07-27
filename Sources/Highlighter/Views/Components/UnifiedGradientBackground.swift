import SwiftUI

// Unified gradient background system combining mesh and immersive gradients
struct UnifiedGradientBackground: View {
    enum Style {
        case mesh
        case immersive
        case subtle
        case glow
    }
    
    let style: Style
    @State private var animationPhase: Double = 0
    @State private var gradientOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    init(style: Style = .subtle) {
        self.style = style
    }
    
    var body: some View {
        ZStack {
            switch style {
            case .mesh:
                meshGradient
            case .immersive:
                immersiveGradient
            case .subtle:
                subtleGradient
            case .glow:
                glowGradient
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Mesh Gradient (from MeshGradientBackground)
    
    private var meshGradient: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Create mesh points
                let rows = 4
                let cols = 4
                let spacing = size.width / CGFloat(cols - 1)
                
                for row in 0..<rows-1 {
                    for col in 0..<cols-1 {
                        let topLeft = meshPoint(row: row, col: col, spacing: spacing, time: time)
                        let topRight = meshPoint(row: row, col: col + 1, spacing: spacing, time: time)
                        let bottomLeft = meshPoint(row: row + 1, col: col, spacing: spacing, time: time)
                        let bottomRight = meshPoint(row: row + 1, col: col + 1, spacing: spacing, time: time)
                        
                        let path = Path { path in
                            path.move(to: topLeft)
                            path.addCurve(
                                to: topRight,
                                control1: CGPoint(x: topLeft.x + spacing/3, y: topLeft.y),
                                control2: CGPoint(x: topRight.x - spacing/3, y: topRight.y)
                            )
                            path.addCurve(
                                to: bottomRight,
                                control1: CGPoint(x: topRight.x, y: topRight.y + spacing/3),
                                control2: CGPoint(x: bottomRight.x, y: bottomRight.y - spacing/3)
                            )
                            path.addCurve(
                                to: bottomLeft,
                                control1: CGPoint(x: bottomRight.x - spacing/3, y: bottomRight.y),
                                control2: CGPoint(x: bottomLeft.x + spacing/3, y: bottomLeft.y)
                            )
                            path.addCurve(
                                to: topLeft,
                                control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y - spacing/3),
                                control2: CGPoint(x: topLeft.x, y: topLeft.y + spacing/3)
                            )
                        }
                        
                        let colors = meshGradientColors(for: row, col: col, time: time)
                        let gradient = Gradient(colors: colors)
                        
                        context.fill(path, with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: 1, y: 1)
                        ))
                    }
                }
            }
        }
        .blur(radius: 60)
        .opacity(colorScheme == .dark ? 0.5 : 0.3)
    }
    
    // MARK: - Immersive Gradient (from ImmersiveGradientBackground)
    
    private var immersiveGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.8),
                    DesignSystem.Colors.secondary.opacity(0.6),
                    DesignSystem.Colors.primary.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.secondary.opacity(0.3),
                    DesignSystem.Colors.primary.opacity(0.5),
                    Color.purple.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .offset(y: gradientOffset)
            .blendMode(.overlay)
            
            // Mesh gradient effect (simulated with radial gradients)
            ZStack {
                RadialGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.4),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 50,
                    endRadius: 400
                )
                .offset(x: sin(animationPhase) * 50, y: cos(animationPhase) * 50)
                
                RadialGradient(
                    colors: [
                        DesignSystem.Colors.secondary.opacity(0.3),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 50,
                    endRadius: 400
                )
                .offset(x: -sin(animationPhase) * 50, y: -cos(animationPhase) * 50)
                
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 300
                )
                .scaleEffect(1.0 + sin(animationPhase) * 0.2)
            }
            .blendMode(.screen)
            
            // Subtle noise texture overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
        }
    }
    
    // MARK: - Subtle Gradient (New default option)
    
    private var subtleGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignSystem.Colors.backgroundSecondary,
                    DesignSystem.Colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .offset(x: sin(animationPhase * 0.5) * 30)
            
            RadialGradient(
                colors: [
                    DesignSystem.Colors.secondary.opacity(0.05),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 400
            )
            .offset(x: -sin(animationPhase * 0.5) * 30)
        }
    }
    
    // MARK: - Glow Gradient (For ambient glow effects)
    
    private var glowGradient: some View {
        ZStack {
            Color.clear
            
            // Central glow effect
            RadialGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.3 * (0.5 + sin(animationPhase) * 0.5)),
                    DesignSystem.Colors.secondary.opacity(0.2 * (0.5 + sin(animationPhase) * 0.5)),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 200
            )
            .blur(radius: 50)
            .scaleEffect(1.0 + sin(animationPhase * 0.5) * 0.1)
        }
    }
    
    // MARK: - Helper Methods
    
    private func meshPoint(row: Int, col: Int, spacing: CGFloat, time: TimeInterval) -> CGPoint {
        let baseX = CGFloat(col) * spacing
        let baseY = CGFloat(row) * spacing
        
        // Add wave motion
        let waveX = sin(time * 0.5 + Double(row) * 0.3) * 20
        let waveY = cos(time * 0.4 + Double(col) * 0.2) * 20
        
        return CGPoint(x: baseX + waveX, y: baseY + waveY)
    }
    
    private func meshGradientColors(for row: Int, col: Int, time: TimeInterval) -> [Color] {
        let phase = time * 0.2 + Double(row + col) * 0.5
        
        let colors: [[Color]] = [
            [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
            [DesignSystem.Colors.secondary, DesignSystem.Colors.secondaryLight],
            [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
            [DesignSystem.Colors.primaryLight, DesignSystem.Colors.secondaryLight]
        ]
        
        let colorIndex = (row + col) % colors.count
        let baseColors = colors[colorIndex]
        
        return baseColors.map { color in
            color.opacity(0.3 + sin(phase) * 0.2)
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            gradientOffset = 200
        }
        
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            animationPhase = .pi * 2
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    func gradientBackground(_ style: UnifiedGradientBackground.Style = .subtle) -> some View {
        self.background(UnifiedGradientBackground(style: style))
    }
}

#Preview {
    VStack {
        HStack {
            Text("Subtle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gradientBackground(.subtle)
            
            Text("Mesh")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gradientBackground(.mesh)
        }
        
        HStack {
            Text("Immersive")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gradientBackground(.immersive)
            
            Text("Glow")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gradientBackground(.glow)
        }
    }
}