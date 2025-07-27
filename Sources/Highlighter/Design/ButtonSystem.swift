import SwiftUI

// MARK: - Unified Button System following DRY principles

/// Configuration for button animations and behaviors
struct ButtonConfiguration {
    let pressedScale: CGFloat
    let hapticType: HapticManager.ImpactStyle
    let animationResponse: Double
    let animationDamping: Double
    
    static let primary = ButtonConfiguration(
        pressedScale: 0.98,
        hapticType: .medium,
        animationResponse: 0.3,
        animationDamping: 0.7
    )
    
    static let secondary = ButtonConfiguration(
        pressedScale: 0.98,
        hapticType: .light,
        animationResponse: 0.2,
        animationDamping: 0.8
    )
    
    static let floating = ButtonConfiguration(
        pressedScale: 0.95,
        hapticType: .medium,
        animationResponse: 0.35,
        animationDamping: 0.6
    )
}

/// Base protocol for all button styles to ensure consistency
protocol ModernButtonProtocol: ButtonStyle {
    var configuration: ButtonConfiguration { get }
    var isEnabled: Bool { get }
}

extension ModernButtonProtocol {
    /// Common button press behavior
    func applyPressAnimation<Content: View>(
        to content: Content,
        isPressed: Bool
    ) -> some View {
        content
            .scaleEffect(isPressed ? configuration.pressedScale : 1.0)
            .animation(
                .spring(
                    response: configuration.animationResponse,
                    dampingFraction: configuration.animationDamping
                ),
                value: isPressed
            )
            .onChange(of: isPressed) { _, newValue in
                if newValue && isEnabled {
                    Task { @MainActor in
                        HapticManager.shared.impact(configuration.hapticType)
                    }
                }
            }
    }
    
    /// Common solid color background generator
    func solidBackground(
        color: Color,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        color.opacity(0.1),
                        lineWidth: 0.5
                    )
            )
    }
    
    /// Common shadow for buttons
    func buttonShadow(
        color: Color,
        isPressed: Bool,
        radius: CGFloat = 8,
        pressedRadius: CGFloat = 4
    ) -> some View {
        EmptyView()
            .shadow(
                color: isEnabled ? color.opacity(0.3) : Color.clear,
                radius: isPressed ? pressedRadius : radius,
                x: 0,
                y: isPressed ? pressedRadius / 2 : radius / 2
            )
    }
}

// MARK: - Refactored Button Styles using unified system

/// Primary button variant styles
enum PrimaryVariant {
    case standard
    case large
    case compact
    
    var padding: EdgeInsets {
        switch self {
        case .standard:
            return EdgeInsets(
                top: DesignSystem.Spacing.base,
                leading: DesignSystem.Spacing.xl,
                bottom: DesignSystem.Spacing.base,
                trailing: DesignSystem.Spacing.xl
            )
        case .large:
            return EdgeInsets(
                top: DesignSystem.Spacing.medium,
                leading: DesignSystem.Spacing.xl,
                bottom: DesignSystem.Spacing.medium,
                trailing: DesignSystem.Spacing.xl
            )
        case .compact:
            return EdgeInsets(
                top: DesignSystem.Spacing.small,
                leading: DesignSystem.Spacing.medium,
                bottom: DesignSystem.Spacing.small,
                trailing: DesignSystem.Spacing.medium
            )
        }
    }
    
    var font: Font {
        switch self {
        case .standard: return DesignSystem.Typography.bodyMedium
        case .large: return DesignSystem.Typography.headline
        case .compact: return DesignSystem.Typography.footnoteMedium
        }
    }
}

/// Simplified Primary Button using unified system
struct UnifiedPrimaryButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.primary
    var isEnabled: Bool = true
    var variant: PrimaryVariant = .standard
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(variant.font)
            .foregroundColor(.white)
            .padding(variant.padding)
            .background(
                solidBackground(
                    color: isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary
                )
            )
            .modifier(
                ButtonPressModifier(
                    buttonConfig: self.configuration,
                    isEnabled: isEnabled,
                    isPressed: configuration.isPressed,
                    shadowColor: DesignSystem.Colors.primary
                )
            )
            .disabled(!isEnabled)
    }
}

/// Simplified Secondary Button using unified system
struct UnifiedSecondaryButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.secondary
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
            .padding(.vertical, DesignSystem.Spacing.base)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(
                        isEnabled 
                        ? DesignSystem.Colors.primary.opacity(0.05)
                        : DesignSystem.Colors.surfaceSecondary
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(
                                isEnabled 
                                ? DesignSystem.Colors.primary.opacity(0.3)
                                : DesignSystem.Colors.border,
                                lineWidth: 1.5
                            )
                    )
            )
            .modifier(
                ButtonPressModifier(
                    buttonConfig: self.configuration,
                    isEnabled: isEnabled,
                    isPressed: configuration.isPressed,
                    shadowColor: .clear,
                    opacity: 0.8
                )
            )
            .disabled(!isEnabled)
    }
}

/// Unified button press behavior modifier
struct ButtonPressModifier: ViewModifier {
    let buttonConfig: ButtonConfiguration
    let isEnabled: Bool
    let isPressed: Bool
    let shadowColor: Color
    var opacity: CGFloat = 0.9
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? buttonConfig.pressedScale : 1.0)
            .opacity(isPressed ? opacity : 1.0)
            .shadow(
                color: isEnabled ? shadowColor.opacity(0.3) : Color.clear,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .animation(
                .spring(
                    response: buttonConfig.animationResponse,
                    dampingFraction: buttonConfig.animationDamping
                ),
                value: isPressed
            )
            .onChange(of: isPressed) { _, newValue in
                if newValue && isEnabled {
                    Task { @MainActor in
                        HapticManager.shared.impact(buttonConfig.hapticType)
                    }
                }
            }
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Apply unified primary button style
    func unifiedPrimaryButton(
        enabled: Bool = true,
        variant: PrimaryVariant = .standard
    ) -> some View {
        self.buttonStyle(UnifiedPrimaryButton(isEnabled: enabled, variant: variant))
    }
    
    /// Apply unified secondary button style
    func unifiedSecondaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(UnifiedSecondaryButton(isEnabled: enabled))
    }
}