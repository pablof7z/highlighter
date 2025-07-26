import SwiftUI

struct ImmersiveGradientBackground: View {
    @Binding var animate: Bool
    @State private var gradientOffset: CGFloat = 0
    
    var body: some View {
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
            .offset(y: animate ? gradientOffset : -gradientOffset)
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
                .offset(x: animate ? 50 : -50, y: animate ? 50 : -50)
                
                RadialGradient(
                    colors: [
                        DesignSystem.Colors.secondary.opacity(0.3),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 50,
                    endRadius: 400
                )
                .offset(x: animate ? -50 : 50, y: animate ? -50 : 50)
                
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 300
                )
                .scaleEffect(animate ? 1.2 : 0.8)
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
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                gradientOffset = 200
            }
        }
    }
}