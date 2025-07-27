import SwiftUI

// MARK: - Modern View Modifiers
// Clean, sophisticated components without excessive effects

// MARK: - Card Styles
// Card styles have been consolidated in CardSystem.swift to follow DRY principles
// Use .modernCard(), .modernCardSelected(), .glassCard(), or .compactCard() modifiers

// MARK: - Button Styles
// Note: Primary button styles are now defined in ModernButtonStyles.swift to avoid duplication

// MARK: - List Item Style
struct ModernListItem: ViewModifier {
    var showDivider: Bool = true
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .padding(.vertical, .ds.base)
                .padding(.horizontal, .ds.screenPadding)
            
            if showDivider {
                Divider()
                    .background(DesignSystem.Colors.divider)
                    .padding(.leading, .ds.screenPadding)
            }
        }
    }
}

// MARK: - Input Styles
// Note: ModernTextField is now defined in ModernFormComponents.swift to avoid duplication

// MARK: - Modern Tab Bar Item
struct ModernTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(DesignSystem.Animation.springSnappy, value: isSelected)
            
            Text(title)
                .font(.ds.micro)
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Modern Section Header
struct ModernSectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.ds.title3)
                .foregroundColor(.ds.text)
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Font.ds.footnoteMedium)
                        .foregroundColor(Color.ds.primary)
                }
            }
        }
        .padding(.horizontal, .ds.screenPadding)
        .padding(.vertical, .ds.small)
    }
}

// MARK: - Highlight Effect (Subtle)
struct ModernHighlight: ViewModifier {
    let isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.micro, style: .continuous)
                    .fill(isHighlighted ? DesignSystem.Colors.highlightSubtle : Color.clear)
                    .animation(DesignSystem.Animation.quick, value: isHighlighted)
            )
    }
}

// MARK: - Loading Placeholder
struct ModernPlaceholder: ViewModifier {
    @State private var opacity: Double = 0.5
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.8
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    // Card modifiers are now defined in CardSystem.swift
    
    func modernListItem(showDivider: Bool = true) -> some View {
        self.modifier(ModernListItem(showDivider: showDivider))
    }
    
    // modernTextField() extension is now in ModernFormComponents.swift
    
    func modernHighlight(_ isHighlighted: Bool) -> some View {
        self.modifier(ModernHighlight(isHighlighted: isHighlighted))
    }
    
    func modernPlaceholder() -> some View {
        self.modifier(ModernPlaceholder())
    }
}

// MARK: - Modern Empty State
struct ModernEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: .ds.medium) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color.ds.textTertiary)
            
            VStack(spacing: .ds.small) {
                Text(title)
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                
                Text(message)
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                }
                .unifiedPrimaryButton()
                .padding(.top, .ds.small)
            }
        }
        .padding(.ds.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
