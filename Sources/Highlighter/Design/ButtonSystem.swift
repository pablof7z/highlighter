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

// MARK: - Specialized Button Styles

/// Micro button for small actions (e.g., in swarm heatmap)
struct UnifiedMicroButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.secondary
    var isEnabled: Bool = true
    var isPrimary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isPrimary ? Color.ds.primary : Color.ds.surfaceSecondary)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
            .foregroundColor(isPrimary ? .white : .ds.text)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

/// Scale button for interactive elements (timeline, profile)
struct UnifiedScaleButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.secondary
    var isEnabled: Bool = true
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

/// Bounce button for action menus (article selection)
struct UnifiedBounceButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.secondary
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Enhanced zap button style
struct UnifiedZapButton: ModernButtonProtocol {
    let configuration = ButtonConfiguration.primary
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.callout)
            .fontWeight(.medium)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.base)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(configuration.isPressed ? 0.2 : 0.1),
                                DesignSystem.Colors.primary.opacity(configuration.isPressed ? 0.15 : 0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                DesignSystem.Colors.primary.opacity(configuration.isPressed ? 0.6 : 0.3),
                                lineWidth: 1.5
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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
    
    /// Apply unified micro button style
    func unifiedMicroButton(isPrimary: Bool = false, enabled: Bool = true) -> some View {
        self.buttonStyle(UnifiedMicroButton(isEnabled: enabled, isPrimary: isPrimary))
    }
    
    /// Apply unified scale button style
    func unifiedScaleButton(scale: CGFloat = 0.95, enabled: Bool = true) -> some View {
        self.buttonStyle(UnifiedScaleButton(isEnabled: enabled, scale: scale))
    }
    
    /// Apply unified bounce button style
    func unifiedBounceButton(enabled: Bool = true) -> some View {
        self.buttonStyle(UnifiedBounceButton(isEnabled: enabled))
    }
    
    /// Apply unified zap button style
    func unifiedZapButton(enabled: Bool = true) -> some View {
        self.buttonStyle(UnifiedZapButton(isEnabled: enabled))
    }
}