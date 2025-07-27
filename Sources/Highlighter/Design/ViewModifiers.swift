import SwiftUI

// MARK: - View Modifiers
// Clean, sophisticated components without excessive effects

// MARK: - Card Styles
// Card styles have been consolidated in CardSystem.swift to follow DRY principles
// Use .modernCard(), .modernCardSelected(), .glassCard(), or .compactCard() modifiers

// MARK: - Button Styles
// Note: Primary button styles are now defined in ButtonStyles.swift to avoid duplication

// MARK: - List Item Style
struct ListItemModifier: ViewModifier {
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
// Note: TextField styles are now defined in FormComponents.swift to avoid duplication

// MARK: - Tab Bar Item
struct TabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.ds.title3)
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


// MARK: - Highlight Effect (Subtle)
struct HighlightModifier: ViewModifier {
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
struct PlaceholderModifier: ViewModifier {
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
    
    func listItem(showDivider: Bool = true) -> some View {
        self.modifier(ListItemModifier(showDivider: showDivider))
    }
    
    // textField() extensions are now in FormComponents.swift
    
    func highlight(_ isHighlighted: Bool) -> some View {
        self.modifier(HighlightModifier(isHighlighted: isHighlighted))
    }
    
    func placeholder() -> some View {
        self.modifier(PlaceholderModifier())
    }
}

