import SwiftUI

struct EmptyHighlightsView: View {
    @State private var animationPhase = false
    @State private var floatingBooks: [FloatingBook] = []
    @State private var glowIntensity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var isPressed = false
    let onCreateHighlight: (() -> Void)?
    
    init(onCreateHighlight: (() -> Void)? = nil) {
        self.onCreateHighlight = onCreateHighlight
    }
    
    var body: some View {
        ZStack {
            // Floating background elements
            ForEach(floatingBooks) { book in
                FloatingBookView(book: book)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated central icon
                ZStack {
                    // Ambient glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.2 * glowIntensity),
                                    DesignSystem.Colors.secondary.opacity(0.1 * glowIntensity),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    // Rotating rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.3),
                                        DesignSystem.Colors.secondary.opacity(0.2),
                                        DesignSystem.Colors.primary.opacity(0.1),
                                        DesignSystem.Colors.secondary.opacity(0.3)
                                    ],
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                lineWidth: 2 - CGFloat(index) * 0.5
                            )
                            .frame(
                                width: 140 + CGFloat(index) * 30,
                                height: 140 + CGFloat(index) * 30
                            )
                            .rotationEffect(.degrees(rotationAngle + Double(index) * 120))
                            .opacity(1 - Double(index) * 0.3)
                    }
                    
                    // Central icon composition
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .overlay(
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
                            )
                        
                        // Animated highlighter icon
                        ZStack {
                            Image(systemName: "highlighter")
                                .font(.system(size: 44, weight: .light))
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
                                .rotationEffect(.degrees(animationPhase ? -10 : 10))
                                .offset(y: animationPhase ? -3 : 3)
                            
                            // Sparkle effects
                            ForEach(0..<4) { index in
                                Image(systemName: "sparkle")
                                    .font(.system(size: 12))
                                    .foregroundColor(DesignSystem.Colors.secondary)
                                    .offset(
                                        x: cos(CGFloat(index) * .pi / 2) * 40,
                                        y: sin(CGFloat(index) * .pi / 2) * 40
                                    )
                                    .opacity(animationPhase ? 0.8 : 0.2)
                                    .scaleEffect(animationPhase ? 1 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 2)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: animationPhase
                                    )
                            }
                        }
                    }
                    .scaleEffect(animationPhase ? 1.05 : 0.95)
                }
                
                VStack(spacing: 20) {
                    Text("Your Highlights Await")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.text)
                        .opacity(animationPhase ? 1 : 0.8)
                    
                    Text("Capture the wisdom that resonates with you.\nStart highlighting the passages that matter.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                        .lineSpacing(4)
                }
                
                // Enhanced CTA Button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onCreateHighlight?()
                }) {
                    ZStack {
                        // Button glow
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.primary.opacity(0.6),
                                        DesignSystem.Colors.secondary.opacity(0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 200, height: 60)
                            .blur(radius: 20)
                            .opacity(glowIntensity)
                        
                        HStack(spacing: 10) {
                            Image(systemName: "highlighter")
                                .font(.system(size: 18, weight: .semibold))
                                .rotationEffect(.degrees(isPressed ? 360 : 0))
                            
                            Text("Create First Highlight")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
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
                                                    Color.white.opacity(0.4),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(
                            color: DesignSystem.Colors.primary.opacity(0.4),
                            radius: isPressed ? 4 : 12,
                            x: 0,
                            y: isPressed ? 2 : 6
                        )
                    }
                }
                .scaleEffect(isPressed ? 0.95 : (animationPhase ? 1.05 : 1.0))
                .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                }, perform: {})
                
                Spacer()
                
                // Bottom suggestions
                VStack(spacing: 16) {
                    Text("Quick Start")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    HStack(spacing: 12) {
                        SuggestionPill(icon: "doc.text", text: "Import Article")
                        SuggestionPill(icon: "magnifyingglass", text: "Discover")
                        SuggestionPill(icon: "person.2", text: "Follow")
                    }
                }
                .padding(.bottom, 40)
                .opacity(animationPhase ? 0.8 : 1)
            }
        }
        .onAppear {
            startAnimations()
            generateFloatingBooks()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            animationPhase = true
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 1
        }
    }
    
    private func generateFloatingBooks() {
        floatingBooks = (0..<6).map { _ in
            FloatingBook(
                emoji: ["📚", "📖", "📕", "📗", "📘", "📙"].randomElement()!,
                startX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                startY: CGFloat.random(in: -100...UIScreen.main.bounds.height + 100),
                duration: Double.random(in: 15...25)
            )
        }
    }
}

struct FloatingBook: Identifiable {
    let id = UUID()
    let emoji: String
    let startX: CGFloat
    let startY: CGFloat
    let duration: Double
    var endX: CGFloat = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    var endY: CGFloat = CGFloat.random(in: -100...UIScreen.main.bounds.height + 100)
}

struct FloatingBookView: View {
    let book: FloatingBook
    @State private var position = CGPoint.zero
    @State private var opacity: Double = 0
    
    var body: some View {
        Text(book.emoji)
            .font(.system(size: 30))
            .opacity(opacity)
            .position(position)
            .onAppear {
                position = CGPoint(x: book.startX, y: book.startY)
                
                withAnimation(.easeIn(duration: 1)) {
                    opacity = 0.3
                }
                
                withAnimation(
                    .linear(duration: book.duration)
                    .repeatForever(autoreverses: false)
                ) {
                    position = CGPoint(x: book.endX, y: book.endY)
                }
            }
    }
}

struct SuggestionPill: View {
    let icon: String
    let text: String
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(isHovered ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isHovered ? DesignSystem.Colors.primary.opacity(0.1) : Color.primary.opacity(0.05))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isHovered ? DesignSystem.Colors.primary.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}