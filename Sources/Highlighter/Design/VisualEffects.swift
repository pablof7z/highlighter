import SwiftUI

struct GlassBackground: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
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
                    .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 4)
            }
    }
}

struct CardBackground: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ?
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
                    .shadow(
                        color: isSelected ? Color.yellow.opacity(0.3) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// Note: ShimmerEffect and PulseEffect have been moved to AnimationSystem.swift
// to consolidate all animation-related functionality in one place.
// Please use .shimmer() and .pulse() extensions from AnimationSystem.swift

struct SimplifiedParallaxEffect: ViewModifier {
    let magnitude: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: getOffset(geometry))
        }
    }
    
    private func getOffset(_ geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        let progress = frame.minY / screenHeight
        return progress * magnitude
    }
}

extension View {
    // shimmer() method is available from AnimationSystem.swift
    // pulse() method is available from AnimationSystem.swift
    
    func simplifiedParallax(magnitude: CGFloat = 20) -> some View {
        modifier(SimplifiedParallaxEffect(magnitude: magnitude))
    }
}


struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(HapticManager.ImpactStyle.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 8)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PressButtonStyle())
    }
}

