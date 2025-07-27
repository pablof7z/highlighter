import SwiftUI

struct LoadingHighlightView: View {
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var particleScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var loadingPhase = 0
    
    let loadingMessages = [
        "Curating your highlights",
        "Finding wisdom in words",
        "Preparing your collection"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                floatingParticles
                mainContent
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        UnifiedGradientBackground(style: .mesh)
            .opacity(0.3)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var floatingParticles: some View {
        ForEach(0..<8) { index in
            floatingParticle(index: index)
        }
    }
    
    @ViewBuilder
    private func floatingParticle(index: Int) -> some View {
        let angle = rotationAngle * .pi / 180 + Double(index) * .pi / 4
        
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        DesignSystem.Colors.primary.opacity(0.4),
                        DesignSystem.Colors.primary.opacity(0)
                    ],
                    center: .center,
                    startRadius: 5,
                    endRadius: 20
                )
            )
            .frame(width: 30)
            .offset(
                x: cos(angle) * 80,
                y: sin(angle) * 80
            )
            .scaleEffect(particleScale)
            .blur(radius: 2)
            .opacity(0.6)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 32) {
            Spacer()
            animatedIcon
            loadingContent
            Spacer()
            hintText
        }
    }
    
    @ViewBuilder
    private var animatedIcon: some View {
        ZStack {
            outerRings
            centralOrb
            quoteIcon
        }
    }
    
    @ViewBuilder
    private var outerRings: some View {
        ForEach(0..<3) { index in
            animatedRing(index: index)
        }
    }
    
    @ViewBuilder
    private func animatedRing(index: Int) -> some View {
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
                lineWidth: 2
            )
            .frame(
                width: 140 + CGFloat(index * 30),
                height: 140 + CGFloat(index * 30)
            )
            .scaleEffect(pulseScale + CGFloat(index) * 0.05)
            .opacity(1 - Double(index) * 0.3)
            .rotationEffect(.degrees(rotationAngle * (index % 2 == 0 ? 1 : -1)))
    }
    
    @ViewBuilder
    private var centralOrb: some View {
        Circle()
            .fill(.thinMaterial)
            .frame(width: 100, height: 100)
            .overlay(centralOrbGradient)
            .overlay(centralOrbStroke)
            .shadow(
                color: DesignSystem.Colors.primary.opacity(0.3),
                radius: 20,
                x: 0,
                y: 0
            )
    }
    
    @ViewBuilder
    private var centralOrbGradient: some View {
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
    }
    
    @ViewBuilder
    private var centralOrbStroke: some View {
        Circle()
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
    }
    
    @ViewBuilder
    private var quoteIcon: some View {
        Image(systemName: "quote.opening")
            .font(.system(size: 42, weight: .thin))
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
            .rotationEffect(.degrees(sin(rotationAngle * .pi / 180) * 5))
    }
    
    @ViewBuilder
    private var loadingContent: some View {
        VStack(spacing: 20) {
            loadingText
            loadingIndicator
            progressDots
        }
    }
    
    @ViewBuilder
    private var loadingText: some View {
        Text(loadingMessages[loadingPhase % loadingMessages.count])
            .font(.ds.title2)
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
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 0.5), value: loadingPhase)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        ZStack {
            Capsule()
                .fill(DesignSystem.Colors.surfaceSecondary)
                .frame(width: 240, height: 6)
            
            shimmerProgress
        }
    }
    
    @ViewBuilder
    private var shimmerProgress: some View {
        GeometryReader { geo in
            Capsule()
                .fill(shimmerGradient)
                .frame(width: 240, height: 6)
                .mask(shimmerMask)
        }
        .frame(width: 240, height: 6)
    }
    
    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                DesignSystem.Colors.primary,
                DesignSystem.Colors.secondary,
                DesignSystem.Colors.primary
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    @ViewBuilder
    private var shimmerMask: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white, location: 0.5),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 100)
            .offset(x: shimmerOffset)
    }
    
    @ViewBuilder
    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                progressDot(index: index)
            }
        }
    }
    
    @ViewBuilder
    private func progressDot(index: Int) -> some View {
        Circle()
            .fill(
                index == loadingPhase % 3
                    ? DesignSystem.Colors.primary
                    : DesignSystem.Colors.textTertiary.opacity(0.3)
            )
            .frame(width: 6, height: 6)
            .scaleEffect(index == loadingPhase % 3 ? 1.2 : 1)
            .animation(.spring(response: 0.3), value: loadingPhase)
    }
    
    @ViewBuilder
    private var hintText: some View {
        Text("Preparing your personalized feed")
            .font(.ds.callout)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .opacity(0.7 * textOpacity)
            .padding(.bottom, 50)
    }
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Particle scale animation
        withAnimation(.easeOut(duration: 0.8)) {
            particleScale = 1
        }
        
        // Shimmer animation
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            shimmerOffset = 340
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.5)) {
            textOpacity = 1
        }
        
        // Phase animation
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingPhase += 1
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