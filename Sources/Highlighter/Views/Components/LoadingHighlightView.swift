import SwiftUI

struct LoadingHighlightView: View {
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with subtle animation
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.1),
                        DesignSystem.Colors.secondary.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Animated highlight icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.2),
                                        DesignSystem.Colors.secondary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseScale)
                        
                        Image(systemName: "quote.opening")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary,
                                        DesignSystem.Colors.secondary
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(pulseScale * 0.9)
                    }
                    
                    VStack(spacing: 16) {
                        // Loading text with shimmer
                        Text("Loading Highlights")
                            .font(DesignSystem.Typography.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.text,
                                        DesignSystem.Colors.text.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Animated loading bars
                        VStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                LoadingBar(delay: Double(index) * 0.1)
                            }
                        }
                        .frame(width: 200)
                    }
                    
                    Spacer()
                    
                    // Subtle hint text
                    Text("Discovering the best highlights for you")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .opacity(0.6)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // Start pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

struct LoadingBar: View {
    let delay: Double
    @State private var offset: CGFloat = -200
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystem.Colors.surface)
                .frame(height: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    DesignSystem.Colors.primary.opacity(0.8),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100)
                        .offset(x: offset)
                )
                .clipped()
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                    ) {
                        offset = geometry.size.width + 100
                    }
                }
        }
        .frame(height: 4)
    }
}