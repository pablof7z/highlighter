import SwiftUI

// MARK: - Highlighter Design System
// Premium design system following app specification: purple (#6A1B9A) and orange (#FF9500)

struct DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        // Primary - Deep purple as specified in HL-SPEC.md
        static let primary = Color(hex: "6A1B9A")
        static let primaryLight = Color(hex: "8E4EC6") 
        static let primaryDark = Color(hex: "4A1270")
        
        // Secondary - Warm orange for value flows and highlights
        static let secondary = Color(hex: "FF9500")
        static let secondaryLight = Color(hex: "FFB143")
        static let secondaryDark = Color(hex: "CC7700")
        
        // Semantic Colors
        static let text = Color.primary
        static let textSecondary = Color.primary.opacity(0.6)
        static let textTertiary = Color.primary.opacity(0.4)
        
        // Backgrounds - Clean, minimal following spec
        static let background = Color(hex: "F5F5F5")
        static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
        static let surface = Color.white
        static let surfaceSecondary = Color(UIColor.secondarySystemBackground).opacity(0.5)
        
        // Dark mode colors
        static let darkBackground = Color(hex: "1C1C1E")
        static let darkSurface = Color(hex: "2C2C2E")
        static let darkText = Color.white
        
        // Functional
        static let success = Color(hex: "34C759")
        static let warning = secondary // Use orange for warnings to maintain consistency
        static let error = Color(hex: "FF3B30")
        
        // Borders & Dividers
        static let divider = Color.primary.opacity(0.08)
        static let border = Color.primary.opacity(0.12)
        
        // Interactive States - orange for highlights as specified
        static let highlight = secondary
        static let highlightSubtle = secondary.opacity(0.1)
    }
    
    // MARK: - Typography
    enum Typography {
        // Display
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        static let title = Font.system(size: 24, weight: .semibold, design: .default)
        static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
        static let title3 = Font.system(size: 18, weight: .medium, design: .default)
        
        // Body
        static let headline = Font.system(size: 16, weight: .semibold, design: .default)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 15, weight: .medium, design: .default)
        static let callout = Font.system(size: 14, weight: .regular, design: .default)
        
        // Support
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let footnoteMedium = Font.system(size: 13, weight: .medium, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let micro = Font.system(size: 11, weight: .regular, design: .default)
        static let calloutMedium = Font.system(size: 14, weight: .medium, design: .default)
        
        // Specialized fonts for Highlighter app
        static let highlighterQuote = Font.custom("Georgia", size: 18).italic()
        
        // Dynamic quote sizing based on content length
        static func dynamicQuote(for length: Int) -> Font {
            let size: CGFloat = length > 100 ? 16 : (length > 50 ? 17 : 18)
            return Font.custom("Georgia", size: size).italic()
        }
    }
    
    // MARK: - Spacing (Tighter, more modern)
    enum Spacing {
        static let nano: CGFloat = 2
        static let micro: CGFloat = 4
        static let mini: CGFloat = 6
        static let small: CGFloat = 8
        static let base: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 40
        
        // Specific use cases
        static let cardPadding: CGFloat = 16
        static let screenPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let micro: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 999
    }
    
    // MARK: - Shadows (Subtle and sophisticated)
    enum Shadow {
        static let subtle = (
            color: Color.black.opacity(0.04),
            radius: CGFloat(2),
            x: CGFloat(0),
            y: CGFloat(1)
        )
        
        static let small = (
            color: Color.black.opacity(0.06),
            radius: CGFloat(4),
            x: CGFloat(0),
            y: CGFloat(2)
        )
        
        static let medium = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        static let large = (
            color: Color.black.opacity(0.12),
            radius: CGFloat(16),
            x: CGFloat(0),
            y: CGFloat(8)
        )
        
        static let elevated = (
            color: Color.black.opacity(0.15),
            radius: CGFloat(24),
            x: CGFloat(0),
            y: CGFloat(12)
        )
    }
    
    // MARK: - Animation (Uses AnimationSystem.Curves)
    typealias Animation = AnimationSystem.Curves
    
    // MARK: - Layout
    enum Layout {
        static let maxContentWidth: CGFloat = 600
        static let compactBreakpoint: CGFloat = 400
        static let regularBreakpoint: CGFloat = 768
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Convenience extensions
extension Color {
    static let ds = DesignSystem.Colors.self
    
    // Legacy color names for backward compatibility
    static let highlighterPurple = DesignSystem.Colors.primary
    static let highlighterOrange = DesignSystem.Colors.secondary
    static let highlighterBackground = DesignSystem.Colors.background
    static let highlighterCardBackground = DesignSystem.Colors.surface
    static let highlighterText = DesignSystem.Colors.text
    static let highlighterSecondaryText = DesignSystem.Colors.textSecondary
    static let highlighterDivider = DesignSystem.Colors.divider
}

extension Font {
    static let ds = DesignSystem.Typography.self
    
    // Legacy font names for backward compatibility
    static let highlighterTitle = DesignSystem.Typography.title
    static let highlighterTitle2 = DesignSystem.Typography.title2
    static let highlighterTitle3 = DesignSystem.Typography.title3
    static let highlighterHeadline = DesignSystem.Typography.headline
    static let highlighterBody = DesignSystem.Typography.body
    static let highlighterCaption = DesignSystem.Typography.caption
    static let highlighterQuote = DesignSystem.Typography.highlighterQuote
    static let highlighterMicro = DesignSystem.Typography.micro
}

extension CGFloat {
    static let ds = DesignSystem.Spacing.self
}

// Color extensions moved above to avoid duplication

// MARK: - Haptic Feedback
// Haptic feedback is handled by HapticManager.shared
// Usage: HapticManager.shared.impact(.light)
//        HapticManager.shared.notification(.success)
//        HapticManager.shared.triggerSelection()

// MARK: - Time Constants for Convenience

struct TimeConstants {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 3600
    static let day: TimeInterval = 86400
    static let week: TimeInterval = 604800
    static let month: TimeInterval = 2_629_746 // Average month
    static let year: TimeInterval = 31_556_952 // Average year
}

// MARK: - View Extensions
extension View {
    func fadeSlide(isVisible: Bool, delay: Double = 0) -> some View {
        self
            .offset(y: isVisible ? 0 : 20)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(delay), value: isVisible)
    }
    
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    func shimmer() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.4), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: -200)
                .animation(
                    Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: UUID()
                )
        )
        .clipped()
    }
    
    func pulseGently() -> some View {
        self.modifier(GentlePulseModifier())
    }
    
    func contextualFeedback(isActive: Bool) -> some View {
        self.modifier(ContextualFeedbackModifier(isActive: isActive))
    }
    
    func highlightText(_ isHighlighted: Bool, color: Color = DesignSystem.Colors.secondary) -> some View {
        self.modifier(HighlightTextEffect(isHighlighted: isHighlighted, highlightColor: color))
    }
    
    func enhancedHighlightCard(isSelected: Bool = false, isHighlighted: Bool = false) -> some View {
        self.modifier(EnhancedHighlightCardModifier(isSelected: isSelected, isHighlighted: isHighlighted))
    }
    
    func rotateAndScale(isActive: Bool) -> some View {
        self
            .scaleEffect(isActive ? 1.2 : 1.0)
            .rotationEffect(isActive ? .degrees(15) : .degrees(0))
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
    }
    
    // pulse() function moved to AnimationSystem.swift
}

// MARK: - View Modifiers

struct GentlePulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.02
                    opacity = 0.9
                }
            }
    }
}

struct ContextualFeedbackModifier: ViewModifier {
    let isActive: Bool
    @State private var feedbackScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(feedbackScale)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                        feedbackScale = 1.02
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            feedbackScale = 1.0
                        }
                    }
                    
                    HapticManager.shared.triggerSelection()
                }
            }
    }
}

struct HighlightTextEffect: ViewModifier {
    let isHighlighted: Bool
    let highlightColor: Color
    
    init(isHighlighted: Bool, highlightColor: Color = DesignSystem.Colors.secondary) {
        self.isHighlighted = isHighlighted
        self.highlightColor = highlightColor
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        isHighlighted ? 
                        highlightColor.opacity(0.15) : 
                        Color.clear
                    )
                    .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(
                        isHighlighted ? 
                        highlightColor.opacity(0.3) : 
                        Color.clear,
                        lineWidth: 1
                    )
                    .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            )
    }
}

struct EnhancedHighlightCardModifier: ViewModifier {
    let isSelected: Bool
    let isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.ds.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                            .stroke(
                                strokeGradient,
                                lineWidth: strokeWidth
                            )
                    )
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .opacity(isSelected ? 1.0 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var strokeGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [DesignSystem.Colors.secondary, DesignSystem.Colors.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isHighlighted {
            return LinearGradient(
                colors: [DesignSystem.Colors.secondary.opacity(0.3), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [DesignSystem.Colors.border, DesignSystem.Colors.border],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 2 : (isHighlighted ? 1.5 : 1)
    }
    
    private var shadowColor: Color {
        if isSelected {
            return DesignSystem.Colors.secondary.opacity(0.3)
        } else {
            return Color.black.opacity(0.08)
        }
    }
    
    private var shadowRadius: CGFloat {
        isSelected ? 12 : 8
    }
    
    private var shadowY: CGFloat {
        isSelected ? 6 : 4
    }
}

// PulseModifier moved to AnimationSystem.swift

// MARK: - Button Styles

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Enhanced Zap Button Style for specialized zap actions
struct EnhancedZapButtonStyle: ButtonStyle {
    @State private var isAnimating = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.callout)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.secondary,
                                DesignSystem.Colors.secondaryDark
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isAnimating ? 1.05 : 1.0))
            .shadow(
                color: DesignSystem.Colors.secondary.opacity(0.4),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(.medium)
                }
            }
    }
}

// MARK: - Enhanced View Extensions for Highlighter

extension View {
    func enhancedZapButton() -> some View {
        self.buttonStyle(EnhancedZapButtonStyle())
    }
    
    func lazyRender(threshold: CGFloat = 100) -> some View {
        self.modifier(LazyRenderModifier(threshold: threshold))
    }
    
    // modernCard, modernListItem and modernPlaceholder are defined in ModernViewModifiers.swift
}

// MARK: - Additional View Modifiers for Highlighter

struct LazyRenderModifier: ViewModifier {
    let threshold: CGFloat
    @State private var isVisible = false
    
    init(threshold: CGFloat = 100) {
        self.threshold = threshold
        self.isVisible = false
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.2)) {
                    isVisible = true
                }
            }
    }
}

// ModernSectionHeader is already defined in ModernViewModifiers.swift


