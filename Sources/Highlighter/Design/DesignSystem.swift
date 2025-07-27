import SwiftUI

// MARK: - Highlighter Design System
// Premium design system following app specification: purple (#6A1B9A) and orange (#FF9500)
// This is the SINGLE source of truth for all UI styles in the app

struct DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        // Primary - Deep purple (Nostr-inspired)
        static let primary = Color(hex: "6A1B9A")
        static let primaryLight = Color(hex: "8E44AD") 
        static let primaryDark = Color(hex: "4A148C")
        
        // Secondary - Warm orange (Bitcoin/Lightning-inspired)
        static let secondary = Color(hex: "FF9500")
        static let secondaryLight = Color(hex: "FFA726")
        static let secondaryDark = Color(hex: "F57C00")
        
        // Semantic Colors
        static let text = Color.primary
        static let textSecondary = Color.primary.opacity(0.6)
        static let textTertiary = Color.primary.opacity(0.4)
        
        // Backgrounds - Premium neutral tones
        static let background = Color(hex: "FAFAFA")
        static let backgroundSecondary = Color(hex: "F5F5F7")
        static let surface = Color.white
        static let surfaceSecondary = Color(hex: "F8F8FA")
        
        // Dark mode colors
        static let darkBackground = Color(hex: "1C1C1E")
        static let darkSurface = Color(hex: "2C2C2E")
        static let darkText = Color.white
        
        // Functional
        static let success = Color(hex: "4CAF50")
        static let warning = Color(hex: "FFA726")
        static let error = Color(hex: "E57373")
        
        // Borders & Dividers
        static let divider = Color.primary.opacity(0.08)
        static let border = Color.primary.opacity(0.12)
        
        // Interactive States - orange highlights to match spec
        static let highlight = secondary.opacity(0.8)
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
            color: Color.black.opacity(0.02),
            radius: CGFloat(1),
            x: CGFloat(0),
            y: CGFloat(0.5)
        )
        
        static let small = (
            color: Color.black.opacity(0.03),
            radius: CGFloat(2),
            x: CGFloat(0),
            y: CGFloat(1)
        )
        
        static let medium = (
            color: Color.black.opacity(0.04),
            radius: CGFloat(4),
            x: CGFloat(0),
            y: CGFloat(2)
        )
        
        static let large = (
            color: Color.black.opacity(0.06),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        
        static let elevated = (
            color: Color.black.opacity(0.08),
            radius: CGFloat(12),
            x: CGFloat(0),
            y: CGFloat(6)
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
    
    // MARK: - Tab/Navigation Pills
    struct TabPill {
        static let selectedBackground = Colors.primary
        static let unselectedBackground = Color.clear
        static let selectedTextColor = Color.white
        static let unselectedTextColor = Colors.text
        static let borderColor = Colors.primary.opacity(0.2)
        static let cornerRadius: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let fontSize: CGFloat = 15
        static let fontWeight: Font.Weight = .medium
        static let borderWidth: CGFloat = 1.5
    }
    
    // MARK: - Cards
    struct Card {
        static let backgroundColor = Colors.surface
        static let borderColor = Colors.border
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let shadowColor = Color.black.opacity(0.04)
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
        static let borderWidth: CGFloat = 1
    }
    
    // MARK: - Stats Cards
    struct StatsCard {
        static let backgroundColor = Colors.surfaceSecondary
        static let iconBackgroundColor = { (color: Color) in color.opacity(0.15) }
        static let iconSize: CGFloat = 24
        static let iconContainerSize: CGFloat = 56
        static let valueFont = Font.system(size: 24, weight: .bold, design: .rounded)
        static let labelFont = Font.system(size: 12, weight: .medium)
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
    }
    
    // MARK: - Profile Header
    struct ProfileHeader {
        static let gradientColors = [Colors.primary.opacity(0.8), Colors.secondary.opacity(0.6)]
        static let overlayGradient = [Color.black.opacity(0), Color.black.opacity(0.4)]
        static let avatarSize: CGFloat = 100
        static let avatarBorderWidth: CGFloat = 4
        static let avatarBorderColor = Color.white
        static let cornerRadius: CGFloat = 32
    }
    
    // MARK: - Buttons
    struct Button {
        static let primaryBackground = Colors.primary
        static let primaryTextColor = Color.white
        static let secondaryBackground = Colors.primary.opacity(0.1)
        static let secondaryTextColor = Colors.primary
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
        static let fontSize: CGFloat = 16
        static let fontWeight: Font.Weight = .medium
    }
    
    // MARK: - Section Headers
    struct SectionHeader {
        static let titleFont = Font.system(size: 24, weight: .bold, design: .rounded)
        static let subtitleFont = Font.system(size: 14)
        static let titleColor = Colors.text
        static let subtitleColor = Colors.textSecondary
        static let spacing: CGFloat = 4
    }
    
    // MARK: - Empty States
    struct EmptyState {
        static let iconSize: CGFloat = 60
        static let iconColor = Colors.textTertiary.opacity(0.5)
        static let titleFont = Typography.title3
        static let messageFont = Typography.body
        static let titleColor = Colors.text
        static let messageColor = Colors.textSecondary
        static let spacing: CGFloat = 16
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
}

extension Font {
    static let ds = DesignSystem.Typography.self
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

// MARK: - Unified View Modifiers

extension View {
    // MARK: - Tab Pills
    func unifiedTabPill(isSelected: Bool) -> some View {
        self
            .font(.system(size: DesignSystem.TabPill.fontSize, weight: DesignSystem.TabPill.fontWeight))
            .foregroundColor(isSelected ? DesignSystem.TabPill.selectedTextColor : DesignSystem.TabPill.unselectedTextColor)
            .padding(.horizontal, DesignSystem.TabPill.horizontalPadding)
            .padding(.vertical, DesignSystem.TabPill.verticalPadding)
            .background(
                Capsule()
                    .fill(isSelected ? DesignSystem.TabPill.selectedBackground : DesignSystem.TabPill.unselectedBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : DesignSystem.TabPill.borderColor, lineWidth: DesignSystem.TabPill.borderWidth)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    // MARK: - Cards
    func unifiedCard() -> some View {
        self
            .padding(DesignSystem.Card.padding)
            .background(DesignSystem.Card.backgroundColor)
            .cornerRadius(DesignSystem.Card.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Card.cornerRadius)
                    .stroke(DesignSystem.Card.borderColor, lineWidth: DesignSystem.Card.borderWidth)
            )
            .shadow(
                color: DesignSystem.Card.shadowColor,
                radius: DesignSystem.Card.shadowRadius,
                x: 0,
                y: DesignSystem.Card.shadowY
            )
    }
    
    // MARK: - Primary Button Style
    func unifiedPrimaryButton() -> some View {
        self
            .font(.system(size: DesignSystem.Button.fontSize, weight: DesignSystem.Button.fontWeight))
            .foregroundColor(DesignSystem.Button.primaryTextColor)
            .padding(.horizontal, DesignSystem.Button.horizontalPadding)
            .padding(.vertical, DesignSystem.Button.verticalPadding)
            .background(DesignSystem.Button.primaryBackground)
            .cornerRadius(DesignSystem.Button.cornerRadius)
    }
    
    // MARK: - Secondary Button Style
    func unifiedSecondaryButton() -> some View {
        self
            .font(.system(size: DesignSystem.Button.fontSize, weight: DesignSystem.Button.fontWeight))
            .foregroundColor(DesignSystem.Button.secondaryTextColor)
            .padding(.horizontal, DesignSystem.Button.horizontalPadding)
            .padding(.vertical, DesignSystem.Button.verticalPadding)
            .background(DesignSystem.Button.secondaryBackground)
            .cornerRadius(DesignSystem.Button.cornerRadius)
    }
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
    
    
    func pulseGently() -> some View {
        self.modifier(GentlePulseModifier())
    }
    
    func contextualFeedback(isActive: Bool) -> some View {
        self.modifier(ContextualFeedbackModifier(isActive: isActive))
    }
    
    func highlightText(_ isHighlighted: Bool, color: Color = DesignSystem.Colors.secondary) -> some View {
        self.modifier(HighlightTextEffect(isHighlighted: isHighlighted, highlightColor: color))
    }
    
    func highlightCard(isSelected: Bool = false, isHighlighted: Bool = false) -> some View {
        self.modifier(HighlightCardModifier(isSelected: isSelected, isHighlighted: isHighlighted))
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
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.01
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

struct HighlightCardModifier: ViewModifier {
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


// MARK: - Enhanced View Extensions for Highlighter

extension View {
    func enhancedZapButton() -> some View {
        self.unifiedZapButton()
    }
    
    func lazyRender(threshold: CGFloat = 100) -> some View {
        self.modifier(LazyRenderModifier(threshold: threshold))
    }
    
    // Card modifiers, listItem and placeholder are defined in ViewModifiers.swift
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

// SectionHeader is defined in ViewModifiers.swift

