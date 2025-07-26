import SwiftUI

// MARK: - Skeleton Loading System

struct SkeletonModifier: ViewModifier {
    @State private var isAnimating = false
    let isActive: Bool
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .redacted(reason: .placeholder)
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.5)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                    }
                    .mask(content)
                )
                .onAppear {
                    isAnimating = true
                }
        } else {
            content
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98)),
                    removal: .identity
                ))
        }
    }
}

extension View {
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isActive: isLoading))
    }
}

// MARK: - Advanced Progress Indicators

struct PulsingDot: View {
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.2
                    opacity = 0.6
                }
            }
    }
}


// MARK: - Morphing Progress Indicator

struct MorphingProgressView: View {
    @State private var phase: CGFloat = 0
    @State private var rotation: Double = 0
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 40, color: Color = .ds.primary) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 4
            
            // Create morphing shape
            var path = Path()
            let points = 6
            
            for i in 0..<points {
                let angle = (Double(i) / Double(points)) * 2 * .pi
                let morphFactor = sin(phase + Double(i) * 0.5) * 0.2 + 1
                let x = center.x + cos(angle) * radius * morphFactor
                let y = center.y + sin(angle) * radius * morphFactor
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    let prevAngle = (Double(i - 1) / Double(points)) * 2 * .pi
                    let prevMorphFactor = sin(phase + Double(i - 1) * 0.5) * 0.2 + 1
                    let prevX = center.x + cos(prevAngle) * radius * prevMorphFactor
                    let prevY = center.y + sin(prevAngle) * radius * prevMorphFactor
                    
                    let controlPoint1 = CGPoint(
                        x: prevX + (x - prevX) * 0.3,
                        y: prevY + (y - prevY) * 0.3
                    )
                    let controlPoint2 = CGPoint(
                        x: x - (x - prevX) * 0.3,
                        y: y - (y - prevY) * 0.3
                    )
                    
                    path.addCurve(to: CGPoint(x: x, y: y), control1: controlPoint1, control2: controlPoint2)
                }
            }
            path.closeSubpath()
            
            // Apply gradient fill
            let gradient = LinearGradient(
                colors: [color, color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            context.fill(path, with: .linearGradient(
                Gradient(colors: [color, color.opacity(0.3)]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)
            ))
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Liquid Loading View

struct LiquidLoadingView: View {
    @State private var waveOffset: CGFloat = 0
    @State private var waveHeight: CGFloat = 0.05
    let progress: Double
    let color: Color
    
    init(progress: Double = 0.5, color: Color = .ds.primary) {
        self.progress = progress
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                
                // Liquid fill
                Circle()
                    .fill(color.opacity(0.1))
                    .mask(
                        WaveShape(
                            offset: waveOffset,
                            waveHeight: waveHeight,
                            progress: progress
                        )
                    )
                
                // Wave
                WaveShape(
                    offset: waveOffset,
                    waveHeight: waveHeight,
                    progress: progress
                )
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Percentage text
                Text("\(Int(progress * 100))%")
                    .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.2, weight: .bold, design: .rounded))
                    .foregroundColor(progress > 0.5 ? .white : color)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 2
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                waveHeight = 0.1
            }
        }
    }
}

struct WaveShape: Shape {
    var offset: CGFloat
    var waveHeight: CGFloat
    var progress: Double
    
    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(offset, progress) }
        set {
            offset = newValue.first
            progress = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * (1 - progress)
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let y = midHeight + sin(relativeX * .pi * 2 + offset) * height * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Content Loading States

struct ContentLoadingView<Content: View, Empty: View, Error: View>: View {
    enum LoadingState: Equatable {
        case loading
        case empty
        case error(String)
        case loaded
    }
    
    let state: LoadingState
    let content: () -> Content
    let empty: () -> Empty
    let error: (String) -> Error
    let onRetry: (() -> Void)?
    
    init(
        state: LoadingState,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder empty: @escaping () -> Empty,
        @ViewBuilder error: @escaping (String) -> Error,
        onRetry: (() -> Void)? = nil
    ) {
        self.state = state
        self.content = content
        self.empty = empty
        self.error = error
        self.onRetry = onRetry
    }
    
    var body: some View {
        ZStack {
            switch state {
            case .loading:
                VStack(spacing: 24) {
                    MorphingProgressView(size: 60)
                    Text("Loading...")
                        .font(.ds.headline)
                        .foregroundColor(.ds.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                
            case .empty:
                empty()
                    .transition(.asymmetric(
                        insertion: .push(from: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                
            case .error(let message):
                VStack(spacing: 20) {
                    error(message)
                    
                    if let onRetry = onRetry {
                        Button(action: onRetry) {
                            Label("Try Again", systemImage: "arrow.clockwise")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.ds.primary)
                                )
                        }
                        .magneticHover()
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
                
            case .loaded:
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)),
                        removal: .identity
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
    }
}

// MARK: - Fancy Loading Button

struct LoadingButton<Label: View>: View {
    let action: () async -> Void
    let label: () -> Label
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        Button(action: {
            Task {
                await performAction()
            }
        }) {
            ZStack {
                label()
                    .opacity(isLoading || showSuccess || showError ? 0 : 1)
                    .scaleEffect(isLoading || showSuccess || showError ? 0.8 : 1)
                
                if isLoading {
                    LoadingDotsView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showError {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .disabled(isLoading)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSuccess)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showError)
    }
    
    private func performAction() async {
        isLoading = true
        
        do {
            await action()
            isLoading = false
            showSuccess = true
            HapticManager.shared.notification(.success)
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showSuccess = false
        } catch {
            isLoading = false
            showError = true
            HapticManager.shared.notification(.error)
            
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showError = false
        }
    }
}

// MARK: - Particle Loading Effect

struct ParticleLoadingView: View {
    @State private var particles: [Particle] = []
    let particleCount = 50
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
        var color: Color
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                _ = CGPoint(x: size.width / 2, y: size.height / 2)
                
                for particle in particles {
                    let rect = CGRect(
                        x: particle.position.x - particle.size / 2,
                        y: particle.position.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(particle.color.opacity(particle.opacity))
                    )
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
        }
        .onAppear {
            setupParticles()
        }
    }
    
    private func setupParticles() {
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let radius = Double.random(in: 50...100)
            
            return Particle(
                position: CGPoint(
                    x: cos(angle) * radius + 150,
                    y: sin(angle) * radius + 150
                ),
                velocity: CGPoint(
                    x: Double.random(in: -1...1),
                    y: Double.random(in: -1...1)
                ),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...1),
                color: [.ds.primary, .ds.secondary, .ds.primaryLight].randomElement()!
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].position.x += particles[i].velocity.x
            particles[i].position.y += particles[i].velocity.y
            
            // Gravity towards center
            let center = CGPoint(x: 150, y: 150)
            let dx = center.x - particles[i].position.x
            let dy = center.y - particles[i].position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > 10 {
                particles[i].velocity.x += dx / distance * 0.1
                particles[i].velocity.y += dy / distance * 0.1
            }
            
            // Damping
            particles[i].velocity.x *= 0.98
            particles[i].velocity.y *= 0.98
            
            // Respawn if too far
            if distance > 150 {
                let angle = Double.random(in: 0...(2 * .pi))
                let radius = Double.random(in: 50...100)
                particles[i].position = CGPoint(
                    x: cos(angle) * radius + 150,
                    y: sin(angle) * radius + 150
                )
                particles[i].velocity = CGPoint(
                    x: Double.random(in: -1...1),
                    y: Double.random(in: -1...1)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        Text("Loading Effects Demo")
            .font(.largeTitle)
            .skeleton(isLoading: true)
        
        HStack(spacing: 20) {
            LoadingDotsView()
            MorphingProgressView(size: 40)
            PulsingDot(color: .ds.primary, size: 20)
        }
        
        LiquidLoadingView(progress: 0.65)
            .frame(width: 100, height: 100)
        
        LoadingButton {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        } label: {
            Text("Submit")
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.ds.primary))
        }
        
        ParticleLoadingView()
            .frame(width: 300, height: 300)
    }
    .padding()
}