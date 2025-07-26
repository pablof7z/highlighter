import SwiftUI

// MARK: - Modern Button Styles

/// Primary button style with gradient background and modern styling
struct ModernPrimaryButton: ButtonStyle {
    var isEnabled: Bool = true
    var variant: PrimaryVariant = .standard
    
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
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(variant.font)
            .foregroundColor(.white)
            .padding(variant.padding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary,
                                isEnabled ? DesignSystem.Colors.primaryDark : DesignSystem.Colors.textTertiary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: isEnabled ? DesignSystem.Colors.primary.opacity(0.3) : Color.clear,
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
            .disabled(!isEnabled)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(HapticManager.ImpactStyle.medium)
                }
            }
    }
}

/// Secondary button style with border and subtle background
struct ModernSecondaryButton: ButtonStyle {
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
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
            .disabled(!isEnabled)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(HapticManager.ImpactStyle.light)
                }
            }
    }
}

/// Ghost button style with minimal styling
struct ModernGhostButton: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.body)
            .foregroundColor(isEnabled ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textTertiary)
            .padding(.vertical, DesignSystem.Spacing.base)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                    .fill(
                        configuration.isPressed 
                        ? DesignSystem.Colors.surfaceSecondary.opacity(0.5)
                        : Color.clear
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
            .disabled(!isEnabled)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(HapticManager.ImpactStyle.light)
                }
            }
    }
}

/// Destructive button style for dangerous actions
struct ModernDestructiveButton: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(.white)
            .padding(.vertical, DesignSystem.Spacing.base)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isEnabled ? DesignSystem.Colors.error : DesignSystem.Colors.textTertiary,
                                isEnabled ? DesignSystem.Colors.error.opacity(0.8) : DesignSystem.Colors.textTertiary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: isEnabled ? DesignSystem.Colors.error.opacity(0.3) : Color.clear,
                radius: configuration.isPressed ? 4 : 6,
                x: 0,
                y: configuration.isPressed ? 2 : 3
            )
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
            .disabled(!isEnabled)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(HapticManager.ImpactStyle.medium)
                }
            }
    }
}

/// Modern floating action button style
struct ModernFloatingButton: ButtonStyle {
    var color: Color = DesignSystem.Colors.secondary
    var size: FloatingSize = .standard
    
    enum FloatingSize {
        case small, standard, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 44
            case .standard: return 56
            case .large: return 64
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .standard: return 22
            case .large: return 26
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.iconSize, weight: .medium))
            .foregroundColor(.white)
            .frame(width: size.dimension, height: size.dimension)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(
                color: color.opacity(0.4),
                radius: configuration.isPressed ? 8 : 12,
                x: 0,
                y: configuration.isPressed ? 4 : 6
            )
            .animation(DesignSystem.Animation.springSnappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticManager.shared.impact(HapticManager.ImpactStyle.medium)
                }
            }
    }
}

// MARK: - Button Style Convenience Extensions

extension View {
    /// Apply modern primary button style
    func modernPrimaryButton(enabled: Bool = true, variant: ModernPrimaryButton.PrimaryVariant = .standard) -> some View {
        self.buttonStyle(ModernPrimaryButton(isEnabled: enabled, variant: variant))
    }
    
    /// Apply modern secondary button style
    func modernSecondaryButton(enabled: Bool = true) -> some View {
        self.buttonStyle(ModernSecondaryButton(isEnabled: enabled))
    }
    
    /// Apply modern ghost button style
    func modernGhostButton(enabled: Bool = true) -> some View {
        self.buttonStyle(ModernGhostButton(isEnabled: enabled))
    }
    
    /// Apply modern destructive button style
    func modernDestructiveButton(enabled: Bool = true) -> some View {
        self.buttonStyle(ModernDestructiveButton(isEnabled: enabled))
    }
    
    /// Apply modern floating button style
    func modernFloatingButton(
        color: Color = DesignSystem.Colors.secondary,
        size: ModernFloatingButton.FloatingSize = .standard
    ) -> some View {
        self.buttonStyle(ModernFloatingButton(color: color, size: size))
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.large) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("Primary Buttons")
                    .font(DesignSystem.Typography.headline)
                
                Button("Standard Primary") {}
                    .modernPrimaryButton()
                
                Button("Large Primary") {}
                    .modernPrimaryButton(variant: .large)
                
                Button("Compact Primary") {}
                    .modernPrimaryButton(variant: .compact)
                
                Button("Disabled Primary") {}
                    .modernPrimaryButton(enabled: false)
            }
            
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("Secondary Buttons")
                    .font(DesignSystem.Typography.headline)
                
                Button("Secondary Button") {}
                    .modernSecondaryButton()
                
                Button("Disabled Secondary") {}
                    .modernSecondaryButton(enabled: false)
            }
            
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("Other Styles")
                    .font(DesignSystem.Typography.headline)
                
                Button("Ghost Button") {}
                    .modernGhostButton()
                
                Button("Destructive Button") {}
                    .modernDestructiveButton()
            }
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                Button {
                    // Action
                } label: {
                    Image(systemName: "plus")
                }
                .modernFloatingButton(size: .small)
                
                Button {
                    // Action
                } label: {
                    Image(systemName: "heart")
                }
                .modernFloatingButton()
                
                Button {
                    // Action
                } label: {
                    Image(systemName: "star")
                }
                .modernFloatingButton(size: .large)
            }
        }
        .padding(DesignSystem.Spacing.large)
    }
    .background(DesignSystem.Colors.background)
}