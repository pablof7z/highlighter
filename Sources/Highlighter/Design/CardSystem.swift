import SwiftUI

// MARK: - Unified Card System
// This file consolidates all card-related styles and components to follow DRY principles

// MARK: - Card Configuration
struct CardConfiguration {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    let shadow: ShadowConfiguration
    
    struct ShadowConfiguration {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // Predefined configurations
    static let standard = CardConfiguration(
        padding: DesignSystem.Spacing.cardPadding,
        cornerRadius: DesignSystem.CornerRadius.medium,
        backgroundColor: DesignSystem.Colors.surface,
        borderColor: nil,
        borderWidth: 0,
        shadow: ShadowConfiguration(
            color: DesignSystem.Shadow.small.color,
            radius: DesignSystem.Shadow.small.radius,
            x: DesignSystem.Shadow.small.x,
            y: DesignSystem.Shadow.small.y
        )
    )
    
    static let selected = CardConfiguration(
        padding: DesignSystem.Spacing.cardPadding,
        cornerRadius: DesignSystem.CornerRadius.medium,
        backgroundColor: DesignSystem.Colors.surface,
        borderColor: DesignSystem.Colors.primary,
        borderWidth: 2,
        shadow: ShadowConfiguration(
            color: DesignSystem.Colors.primary.opacity(0.3),
            radius: 12,
            x: 0,
            y: 6
        )
    )
    
    static let glass = CardConfiguration(
        padding: DesignSystem.Spacing.cardPadding,
        cornerRadius: DesignSystem.CornerRadius.medium,
        backgroundColor: Color.clear,
        borderColor: Color.white.opacity(0.2),
        borderWidth: 1,
        shadow: ShadowConfiguration(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    )
    
    static let compact = CardConfiguration(
        padding: DesignSystem.Spacing.base,
        cornerRadius: DesignSystem.CornerRadius.small,
        backgroundColor: DesignSystem.Colors.surface,
        borderColor: nil,
        borderWidth: 0,
        shadow: ShadowConfiguration(
            color: DesignSystem.Shadow.subtle.color,
            radius: DesignSystem.Shadow.subtle.radius,
            x: DesignSystem.Shadow.subtle.x,
            y: DesignSystem.Shadow.subtle.y
        )
    )
}

// MARK: - Modern Card View Modifier (Consolidated)
struct ModernCardModifier: ViewModifier {
    let configuration: CardConfiguration
    let isInteractive: Bool
    @State private var isPressed = false
    
    init(configuration: CardConfiguration = .standard, isInteractive: Bool = false) {
        self.configuration = configuration
        self.isInteractive = isInteractive
    }
    
    func body(content: Content) -> some View {
        content
            .padding(configuration.padding)
            .background(backgroundView)
            .overlay(borderView)
            .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
            .shadow(
                color: configuration.shadow.color,
                radius: configuration.shadow.radius,
                x: configuration.shadow.x,
                y: configuration.shadow.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
            } onPressingChanged: { pressing in
                if isInteractive {
                    isPressed = pressing
                }
            }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if configuration.backgroundColor == Color.clear {
            RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
        } else {
            RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                .fill(configuration.backgroundColor)
        }
    }
    
    @ViewBuilder
    private var borderView: some View {
        if let borderColor = configuration.borderColor, configuration.borderWidth > 0 {
            RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: configuration.borderWidth)
        }
    }
}

// MARK: - View Extensions (Unified)
extension View {
    /// Apply modern card styling with default configuration
    func modernCard(noPadding: Bool = false, isInteractive: Bool = false) -> some View {
        var config = CardConfiguration.standard
        if noPadding {
            config = CardConfiguration(
                padding: 0,
                cornerRadius: config.cornerRadius,
                backgroundColor: config.backgroundColor,
                borderColor: config.borderColor,
                borderWidth: config.borderWidth,
                shadow: config.shadow
            )
        }
        return self.modifier(ModernCardModifier(configuration: config, isInteractive: isInteractive))
    }
    
    /// Apply modern card styling with selection state
    func modernCardSelected(_ isSelected: Bool) -> some View {
        self.modifier(ModernCardModifier(
            configuration: isSelected ? .selected : .standard,
            isInteractive: true
        ))
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(DesignSystem.Animation.springSnappy, value: isSelected)
    }
    
    /// Apply glass card styling
    func glassCard() -> some View {
        self.modifier(ModernCardModifier(configuration: .glass))
    }
    
    /// Apply compact card styling
    func compactCard() -> some View {
        self.modifier(ModernCardModifier(configuration: .compact))
    }
}

// MARK: - Backward Compatibility
// Bridge the UnifiedCard component approach with the modifier approach
extension UnifiedCard {
    /// Create a UnifiedCard using a simple modifier-style API
    static func card(
        variant: CardVariant = .standard,
        isSelected: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> UnifiedCard<Content> {
        return UnifiedCard(
            variant: variant,
            isSelected: isSelected,
            action: action,
            content: content
        )
    }
}