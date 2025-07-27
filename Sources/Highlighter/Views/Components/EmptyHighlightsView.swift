import SwiftUI

struct EmptyHighlightsView: View {
    @State private var isPressed = false
    let onCreateHighlight: (() -> Void)?
    
    init(onCreateHighlight: (() -> Void)? = nil) {
        self.onCreateHighlight = onCreateHighlight
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 40) {
                Spacer()
                
                // Simple icon
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                    
                    Image(systemName: "highlighter")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                VStack(spacing: 20) {
                    Text("Your Wisdom Awaits")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Transform your reading into a curated collection of insights.\nHighlight the ideas that shape your thinking.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .lineSpacing(6)
                        .opacity(0.9)
                }
                
                // Simple CTA Button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onCreateHighlight?()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Begin Highlighting")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.primary)
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
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