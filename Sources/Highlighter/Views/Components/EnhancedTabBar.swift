import SwiftUI
import UIKit

// MARK: - Liquid Morphing Tab Bar with Advanced Animations
struct EnhancedTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var animatingTab: ContentView.Tab?
    @State private var tabWidths: [ContentView.Tab: CGFloat] = [:]
    @State private var tabOffsets: [ContentView.Tab: CGFloat] = [:]
    @State private var bubbleOffset: CGFloat = 0
    @State private var bubbleWidth: CGFloat = 60
    @State private var bubbleHeight: CGFloat = 52
    @State private var showTabLabels = true
    @State private var liquidMorphProgress: CGFloat = 0
    @State private var selectedTabScale: CGFloat = 1
    @State private var rippleEffect: Bool = false
    @State private var magneticPull: CGFloat = 0
    @State private var glowIntensity: Double = 0
    @State private var particles: [TabParticle] = []
    @Namespace private var animation
    
    // Haptic feedback
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Advanced glass morphism background
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            // Iridescent gradient overlay
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.6 + glowIntensity * 0.1, saturation: 0.2, brightness: 0.9).opacity(0.1),
                                    Color(hue: 0.7 + glowIntensity * 0.15, saturation: 0.3, brightness: 0.85).opacity(0.05),
                                    Color(hue: 0.8 + glowIntensity * 0.2, saturation: 0.25, brightness: 0.95).opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .blendMode(.plusLighter)
                        )
                        .overlay(
                            // Animated shimmer effect
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 100)
                            .rotationEffect(.degrees(30))
                            .offset(x: liquidMorphProgress * 400 - 200)
                            .animation(
                                .linear(duration: 3)
                                .repeatForever(autoreverses: false),
                                value: liquidMorphProgress
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                            )
                        )
                    
                    // Top glow border
                    VStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.5 + glowIntensity * 0.3),
                                        DesignSystem.Colors.secondary.opacity(0.3 + glowIntensity * 0.2),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 2)
                            .blur(radius: 1 + glowIntensity * 2)
                        
                        Spacer()
                    }
                }
                .frame(height: 88)
                .shadow(color: DesignSystem.Colors.primary.opacity(0.2 * glowIntensity), radius: 20, y: -5)
                
                // Liquid morphing selection indicator
                if let offset = tabOffsets[selectedTab] {
                    // Main liquid bubble
                    LiquidBubble(
                        width: bubbleWidth,
                        height: bubbleHeight,
                        morphProgress: liquidMorphProgress,
                        glowIntensity: glowIntensity
                    )
                    .scaleEffect(selectedTabScale)
                    .offset(x: offset + magneticPull, y: -24)
                    .animation(
                        .interactiveSpring(
                            response: 0.5,
                            dampingFraction: 0.7,
                            blendDuration: 0.3
                        ),
                        value: selectedTab
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6),
                        value: magneticPull
                    )
                    
                    // Ripple effect layers
                    if rippleEffect {
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.primary.opacity(0.3 - Double(index) * 0.1),
                                            DesignSystem.Colors.secondary.opacity(0.2 - Double(index) * 0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2 - CGFloat(index) * 0.5
                                )
                                .frame(width: 80 + CGFloat(index) * 30, height: 80 + CGFloat(index) * 30)
                                .offset(x: offset, y: -24)
                                .scaleEffect(rippleEffect ? 1 + CGFloat(index) * 0.3 : 0)
                                .opacity(rippleEffect ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.8)
                                    .delay(Double(index) * 0.1),
                                    value: rippleEffect
                                )
                        }
                    }
                }
                
                // Tab items
                HStack(spacing: 0) {
                    ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                        TabItem(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            animatingTab: animatingTab,
                            showLabel: showTabLabels,
                            namespace: animation
                        )
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { itemGeometry in
                                Color.clear
                                    .onAppear {
                                        let frame = itemGeometry.frame(in: .named("tabBar"))
                                        tabOffsets[tab] = frame.midX - geometry.size.width / 2
                                        tabWidths[tab] = frame.width
                                    }
                                    .onChange(of: geometry.size) { _, _ in
                                        let frame = itemGeometry.frame(in: .named("tabBar"))
                                        tabOffsets[tab] = frame.midX - geometry.size.width / 2
                                        tabWidths[tab] = frame.width
                                    }
                            }
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedTab != tab {
                                    impactMedium.impactOccurred()
                                    animatingTab = tab
                                    selectedTab = tab
                                    
                                    // Trigger advanced animations
                                    triggerSelectionAnimation(for: tab)
                                    
                                    // Generate particles
                                    generateParticles(at: tabOffsets[tab] ?? 0)
                                    
                                    // Clear animation state
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        animatingTab = nil
                                    }
                                } else {
                                    // Double tap effect
                                    impactLight.impactOccurred()
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                        animatingTab = tab
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        animatingTab = nil
                                    }
                                }
                            }
                        }
                        .onLongPressGesture {
                            impactMedium.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                showTabLabels.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 34)
                .coordinateSpace(name: "tabBar")
                
                // Particle effects layer
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    particle.color.opacity(0.8),
                                    particle.color.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .blur(radius: particle.blur)
                        .allowsHitTesting(false)
                        .animation(
                            .easeOut(duration: particle.lifetime),
                            value: particle.y
                        )
                }
                
                // Floating orb with pulsing glow
                if let offset = tabOffsets[selectedTab] {
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.4),
                                        DesignSystem.Colors.secondary.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 15)
                            .scaleEffect(1 + glowIntensity * 0.2)
                        
                        // Inner core
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        DesignSystem.Colors.primary.opacity(0.6),
                                        DesignSystem.Colors.primary.opacity(0)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 40, height: 40)
                            .blur(radius: 5)
                    }
                    .offset(x: offset, y: -24)
                    .allowsHitTesting(false)
                    .opacity(glowIntensity)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowIntensity)
                }
            }
            .frame(height: 88)
        }
        .frame(height: 88)
        .onAppear {
            impactMedium.prepare()
            impactLight.prepare()
            updateBubbleWidth(for: selectedTab)
            
            // Start ambient animations
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                liquidMorphProgress = 1
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowIntensity = 1
            }
        }
    }
    
    private func updateBubbleWidth(for tab: ContentView.Tab) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            switch tab {
            case .home, .profile:
                bubbleWidth = 65
                bubbleHeight = 52
            case .feed, .library:
                bubbleWidth = 70
                bubbleHeight = 54
            case .discover:
                bubbleWidth = 75
                bubbleHeight = 56
            }
        }
    }
    
    private func triggerSelectionAnimation(for tab: ContentView.Tab) {
        // Update bubble dimensions
        updateBubbleWidth(for: tab)
        
        // Trigger ripple effect
        rippleEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            rippleEffect = false
        }
        
        // Animate selection scale
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            selectedTabScale = 1.15
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
            selectedTabScale = 1.0
        }
    }
    
    private func generateParticles(at xOffset: CGFloat) {
        let newParticles = (0..<8).map { _ in
            TabParticle(
                x: xOffset + CGFloat.random(in: -30...30),
                y: -24 + CGFloat.random(in: -10...10),
                targetY: -80 - CGFloat.random(in: 0...40),
                size: CGFloat.random(in: 4...12),
                color: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary].randomElement()!,
                lifetime: Double.random(in: 0.8...1.5)
            )
        }
        
        particles.append(contentsOf: newParticles)
        
        // Animate particles
        for i in particles.indices {
            withAnimation(.easeOut(duration: particles[i].lifetime)) {
                particles[i].y = particles[i].targetY
                particles[i].opacity = 0
            }
        }
        
        // Clean up old particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particles.removeAll { $0.opacity == 0 }
        }
    }
}

struct TabItem: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let animatingTab: ContentView.Tab?
    let showLabel: Bool
    let namespace: Namespace.ID
    
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: showLabel ? 6 : 0) {
            ZStack {
                // Background icon (for smooth transitions)
                Image(systemName: tab.icon)
                    .font(.system(size: 24, weight: .medium))
                    .opacity(isSelected ? 0 : 1)
                    .foregroundColor(.ds.textSecondary)
                
                // Filled icon with animations
                Image(systemName: tab.filledIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .opacity(isSelected ? 1 : 0)
                    .foregroundColor(.ds.primary)
                    .rotationEffect(.degrees(iconRotation))
                    .scaleEffect(iconScale)
            }
            .frame(width: 28, height: 28)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            if showLabel {
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .ds.primary : .ds.textSecondary)
                    .transition(.asymmetric(
                        insertion: .push(from: .bottom).combined(with: .opacity),
                        removal: .push(from: .top).combined(with: .opacity)
                    ))
            }
        }
        .scaleEffect(animatingTab == tab ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animatingTab)
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                // Animate icon when selected
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    iconScale = 1.2
                    iconRotation = 10
                }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    iconScale = 1.0
                    iconRotation = 0
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct LiquidBubble: View {
    let width: CGFloat
    let height: CGFloat
    let morphProgress: CGFloat
    let glowIntensity: Double
    
    var body: some View {
        ZStack {
            // Main bubble shape with liquid morph
            LiquidShape(morphProgress: morphProgress)
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
                .overlay(
                    // Glass effect overlay
                    LiquidShape(morphProgress: morphProgress)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .blur(radius: 0.5)
                )
                .overlay(
                    // Border with gradient
                    LiquidShape(morphProgress: morphProgress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.5),
                                    DesignSystem.Colors.secondary.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            // Inner glow
            LiquidShape(morphProgress: morphProgress)
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.15 * glowIntensity),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .blur(radius: 5)
        }
        .frame(width: width, height: height)
    }
}

struct LiquidShape: Shape {
    var morphProgress: CGFloat
    
    var animatableData: CGFloat {
        get { morphProgress }
        set { morphProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 20
        
        // Create liquid morph effect
        let morphOffset = sin(morphProgress * .pi * 2) * 3
        let squishFactor = 1 + cos(morphProgress * .pi * 2) * 0.05
        
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge with subtle wave
        path.addQuadCurve(
            to: CGPoint(x: width - cornerRadius, y: 0),
            control: CGPoint(x: width / 2, y: morphOffset)
        )
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius * squishFactor,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        
        // Bottom right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius * squishFactor,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge with wave
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: height),
            control: CGPoint(x: width / 2, y: height - morphOffset)
        )
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius * squishFactor,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius * squishFactor,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

struct TabParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let targetY: CGFloat
    let size: CGFloat
    let color: Color
    let lifetime: Double
    var opacity: Double = 1
    let blur: CGFloat = CGFloat.random(in: 0...3)
}


#Preview {
    ZStack {
        // Background content
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        // Tab bar at bottom
        VStack {
            Spacer()
            EnhancedTabBar(selectedTab: .constant(.home))
        }
    }
}