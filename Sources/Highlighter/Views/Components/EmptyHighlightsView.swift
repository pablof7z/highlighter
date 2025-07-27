import SwiftUI

struct EmptyHighlightsView: View {
    @State private var animationPhase = false
    @State private var isPressed = false
    @State private var particleAnimation = false
    @State private var textGlow = false
    @State private var cardRotation: Double = 0
    let onCreateHighlight: (() -> Void)?
    
    init(onCreateHighlight: (() -> Void)? = nil) {
        self.onCreateHighlight = onCreateHighlight
    }
    
    var body: some View {
        ZStack {
            // Animated background particles
            ForEach(0..<6) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.3),
                                DesignSystem.Colors.secondary.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: particleAnimation ? CGFloat.random(in: 40...80) : 20)
                    .blur(radius: particleAnimation ? 15 : 5)
                    .offset(
                        x: particleAnimation ? CGFloat.random(in: -150...150) : 0,
                        y: particleAnimation ? CGFloat.random(in: -200...200) : 0
                    )
                    .opacity(particleAnimation ? 0 : 0.6)
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: particleAnimation
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Enhanced central visualization
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.4),
                                    DesignSystem.Colors.secondary.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animationPhase ? 1.1 : 0.95)
                        .opacity(animationPhase ? 0.6 : 0.3)
                        .blur(radius: 1)
                    
                    // Inner material circle
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: DesignSystem.Colors.primary.opacity(0.2),
                            radius: 20,
                            x: 0,
                            y: 5
                        )
                    
                    // Animated highlighter icon
                    Image(systemName: "highlighter")
                        .font(.system(size: 40, weight: .light))
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
                        .rotationEffect(.degrees(animationPhase ? -5 : 5))
                        .shadow(
                            color: textGlow ? DesignSystem.Colors.primary.opacity(0.6) : Color.clear,
                            radius: 10
                        )
                }
                .scaleEffect(animationPhase ? 1.02 : 0.98)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 1
                )
                
                VStack(spacing: 20) {
                    Text("Your Wisdom Awaits")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.text,
                                    DesignSystem.Colors.text.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animationPhase ? 1 : 0.8)
                        .shadow(
                            color: textGlow ? DesignSystem.Colors.text.opacity(0.3) : Color.clear,
                            radius: 8
                        )
                    
                    Text("Transform your reading into a curated collection of insights.\nHighlight the ideas that shape your thinking.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .lineSpacing(6)
                        .opacity(0.9)
                }
                
                // Enhanced CTA Button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onCreateHighlight?()
                }) {
                    ZStack {
                        // Button background with gradient
                        Capsule()
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
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        HStack(spacing: 12) {
                            Image(systemName: "highlighter")
                                .font(.system(size: 18, weight: .semibold))
                                .rotationEffect(.degrees(isPressed ? -10 : 0))
                            
                            Text("Begin Highlighting")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                    }
                    .frame(height: 52)
                    .frame(maxWidth: 220)
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.4),
                        radius: isPressed ? 6 : 12,
                        x: 0,
                        y: isPressed ? 3 : 6
                    )
                }
                .scaleEffect(isPressed ? 0.94 : 1.0)
                .onLongPressGesture(minimumDuration: 0.05, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                }, perform: {})
                
                Spacer()
                
                // Enhanced bottom suggestions
                VStack(spacing: 20) {
                    Text("Get Started")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    HStack(spacing: 16) {
                        ActionPill(
                            icon: "doc.text.fill",
                            text: "Import",
                            color: .blue
                        )
                        ActionPill(
                            icon: "sparkle.magnifyingglass",
                            text: "Explore",
                            color: .purple
                        )
                        ActionPill(
                            icon: "person.2.fill",
                            text: "Connect",
                            color: .green
                        )
                    }
                }
                .padding(.bottom, 50)
                .opacity(0.9)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            animationPhase = true
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            particleAnimation = true
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
            textGlow = true
        }
        
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            cardRotation = 5
        }
    }
}

struct ActionPill: View {
    let icon: String
    let text: String
    let color: Color
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isHovered ? .white : color)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isHovered ? .white : DesignSystem.Colors.text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                if isHovered {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: color.opacity(0.4),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                } else {
                    Capsule()
                        .fill(Color.ds.surfaceSecondary)
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        )
        .scaleEffect(isPressed ? 0.92 : (isHovered ? 1.08 : 1))
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            HapticManager.shared.impact(.light)
        }
    }
}