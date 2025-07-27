import SwiftUI

struct EmptyHighlightsView: View {
    @State private var animationPhase = false
    @State private var isPressed = false
    let onCreateHighlight: (() -> Void)?
    
    init(onCreateHighlight: (() -> Void)? = nil) {
        self.onCreateHighlight = onCreateHighlight
    }
    
    var body: some View {
        VStack(spacing: 40) {
                Spacer()
                
                // Simplified central icon
                ZStack {
                    // Background circle with subtle material effect
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                    
                    // Highlighter icon with gentle animation
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
                }
                .scaleEffect(animationPhase ? 1.02 : 0.98)
                
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
                
                // Simplified CTA Button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onCreateHighlight?()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("Create First Highlight")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
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
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
                }
                .scaleEffect(isPressed ? 0.96 : 1.0)
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
                .opacity(0.8)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            animationPhase = true
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