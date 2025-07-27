import SwiftUI

struct EmptyHighlightsView: View {
    @State private var isPressed = false
    @State private var iconRotation: Double = 0
    @State private var glowAnimation = false
    @State private var particlesAnimation = false
    let onCreateHighlight: (() -> Void)?
    
    init(onCreateHighlight: (() -> Void)? = nil) {
        self.onCreateHighlight = onCreateHighlight
    }
    
    var body: some View {
        ZStack {
            // Subtle animated particles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.15),
                                DesignSystem.Colors.secondary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 40...80))
                    .blur(radius: 10)
                    .offset(
                        x: particlesAnimation ? CGFloat.random(in: -150...150) : 0,
                        y: particlesAnimation ? CGFloat.random(in: -200...200) : 0
                    )
                    .opacity(particlesAnimation ? 0.6 : 0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: particlesAnimation
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Enhanced animated icon
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 45,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(glowAnimation ? 1.1 : 0.9)
                        .opacity(glowAnimation ? 1 : 0.7)
                    
                    // Main circle with glass effect
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.primary.opacity(0.8),
                                            DesignSystem.Colors.secondary.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: DesignSystem.Colors.primary.opacity(0.3),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
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
                        .rotationEffect(.degrees(iconRotation))
                }
                
                VStack(spacing: 20) {
                    Text("Your Wisdom Awaits")
                        .font(.ds.title)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Transform your reading into a curated collection of insights.\nHighlight the ideas that shape your thinking.")
                        .font(.ds.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .lineSpacing(6)
                        .opacity(0.9)
                }
                
                // Enhanced CTA Button with gradient
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onCreateHighlight?()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "highlighter")
                            .font(.ds.headline)
                        
                        Text("Begin Highlighting")
                            .font(.ds.bodyMedium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary,
                                        DesignSystem.Colors.primary.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0.05, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                }, perform: {})
                
                Spacer()
                
                // Enhanced bottom suggestions
                VStack(spacing: 20) {
                    Text("Get Started")
                        .font(.ds.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    HStack(spacing: 16) {
                        ActionPill(
                            icon: "doc.text.fill",
                            text: "Import",
                            color: DesignSystem.Colors.primary
                        )
                        ActionPill(
                            icon: "sparkle.magnifyingglass",
                            text: "Explore",
                            color: DesignSystem.Colors.secondary
                        )
                        ActionPill(
                            icon: "person.2.fill",
                            text: "Connect",
                            color: DesignSystem.Colors.success
                        )
                    }
                }
                .padding(.bottom, 50)
                .opacity(0.9)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                particlesAnimation = true
            }
            
            withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                iconRotation = 10
            }
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
                .font(.ds.callout)
                .foregroundColor(isHovered ? .white : color)
            Text(text)
                .font(.ds.footnote)
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