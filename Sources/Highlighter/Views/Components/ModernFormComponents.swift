import SwiftUI

// MARK: - Modern Form Components

/// Modern text field style with consistent design
struct ModernTextFieldStyle: ViewModifier {
    var isValid: Bool = true
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, DesignSystem.Spacing.base)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .shadow(
                color: shadowColor,
                radius: 2,
                x: 0,
                y: 1
            )
            .animation(DesignSystem.Animation.quick, value: isFocused)
            .animation(DesignSystem.Animation.quick, value: isValid)
    }
    
    private var borderColor: Color {
        if !isValid {
            return DesignSystem.Colors.error
        } else if isFocused {
            return DesignSystem.Colors.primary
        } else {
            return DesignSystem.Colors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if !isValid || isFocused {
            return 2.0
        } else {
            return 1.0
        }
    }
    
    private var shadowColor: Color {
        if !isValid {
            return DesignSystem.Colors.error.opacity(0.2)
        } else if isFocused {
            return DesignSystem.Colors.primary.opacity(0.1)
        } else {
            return DesignSystem.Shadow.subtle.color
        }
    }
}

/// Modern form section with consistent styling
struct ModernFormSection<Content: View>: View {
    let title: String?
    let subtitle: String?
    let content: Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            if let title = title {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.micro) {
                    Text(title)
                        .font(DesignSystem.Typography.footnoteMedium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            
            content
        }
    }
}

/// Modern checkbox with custom styling
struct ModernCheckbox: View {
    @Binding var isChecked: Bool
    let title: String
    let subtitle: String?
    
    init(_ title: String, isChecked: Binding<Bool>, subtitle: String? = nil) {
        self.title = title
        self._isChecked = isChecked
        self.subtitle = subtitle
    }
    
    var body: some View {
        Button {
            withAnimation(DesignSystem.Animation.quick) {
                isChecked.toggle()
            }
            HapticManager.shared.triggerSelection()
        } label: {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.base) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.micro, style: .continuous)
                        .stroke(
                            isChecked ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                            lineWidth: isChecked ? 2 : 1
                        )
                        .frame(width: 20, height: 20)
                    
                    if isChecked {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.micro, style: .continuous)
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.ds.captionMedium)
                                    .foregroundColor(.white)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.micro) {
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Modern toggle switch with custom styling
struct ModernToggle: View {
    @Binding var isOn: Bool
    let title: String
    let subtitle: String?
    
    init(_ title: String, isOn: Binding<Bool>, subtitle: String? = nil) {
        self.title = title
        self._isOn = isOn
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.micro) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(ModernToggleStyle())
        }
    }
}

/// Custom toggle style matching the design system
struct ModernToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(DesignSystem.Animation.springSnappy) {
                configuration.isOn.toggle()
            }
            HapticManager.shared.triggerSelection()
        } label: {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    configuration.isOn
                    ? DesignSystem.Colors.primary
                    : DesignSystem.Colors.surfaceSecondary
                )
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(DesignSystem.Animation.springSnappy, value: configuration.isOn)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Modern picker with custom styling
struct ModernPicker<SelectionValue: Hashable, Content: View>: View {
    let title: String
    @Binding var selection: SelectionValue
    let content: Content
    
    init(
        _ title: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(title)
                .font(DesignSystem.Typography.footnoteMedium)
                .foregroundColor(DesignSystem.Colors.text)
            
            Picker(title, selection: $selection) {
                content
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

/// Modern stepper with custom styling
struct ModernStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let title: String
    let subtitle: String?
    
    init(
        _ title: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        subtitle: String? = nil
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.micro) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: DesignSystem.Spacing.small) {
                Button {
                    if value > range.lowerBound {
                        withAnimation(DesignSystem.Animation.quick) {
                            value -= 1
                        }
                        HapticManager.shared.impact(HapticManager.ImpactStyle.light)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.ds.calloutMedium)
                        .foregroundColor(
                            value > range.lowerBound
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.textTertiary
                        )
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surfaceSecondary)
                                .opacity(value > range.lowerBound ? 1 : 0.5)
                        )
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.text)
                    .frame(minWidth: 30)
                
                Button {
                    if value < range.upperBound {
                        withAnimation(DesignSystem.Animation.quick) {
                            value += 1
                        }
                        HapticManager.shared.impact(HapticManager.ImpactStyle.light)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.ds.calloutMedium)
                        .foregroundColor(
                            value < range.upperBound
                            ? DesignSystem.Colors.primary
                            : DesignSystem.Colors.textTertiary
                        )
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surfaceSecondary)
                                .opacity(value < range.upperBound ? 1 : 0.5)
                        )
                }
                .disabled(value >= range.upperBound)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply modern text field styling
    func modernTextField(isValid: Bool = true, isSecure: Bool = false) -> some View {
        self.modifier(ModernTextFieldStyle(isValid: isValid, isSecure: isSecure))
    }
    
    /// Wrap in a modern form section
    func modernFormSection(title: String? = nil, subtitle: String? = nil) -> some View {
        ModernFormSection(title: title, subtitle: subtitle) {
            self
        }
    }
}

// MARK: - Preview

#Preview("Form Components") {
    NavigationStack {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                ModernFormSection(title: "Text Fields", subtitle: "Various text input styles") {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        TextField("Standard text field", text: .constant(""))
                            .modernTextField()
                        
                        TextField("Invalid text field", text: .constant(""))
                            .modernTextField(isValid: false)
                        
                        SecureField("Secure field", text: .constant(""))
                            .modernTextField(isSecure: true)
                    }
                }
                
                ModernFormSection(title: "Checkboxes") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        ModernCheckbox(
                            "Enable notifications",
                            isChecked: .constant(true),
                            subtitle: "Get notified about new highlights"
                        )
                        
                        ModernCheckbox(
                            "Auto-save highlights",
                            isChecked: .constant(false)
                        )
                    }
                }
                
                ModernFormSection(title: "Toggles") {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        ModernToggle(
                            "Dark mode",
                            isOn: .constant(false),
                            subtitle: "Switch to dark appearance"
                        )
                        
                        ModernToggle(
                            "Haptic feedback",
                            isOn: .constant(true)
                        )
                    }
                }
                
                ModernFormSection(title: "Stepper") {
                    ModernStepper(
                        "Items per page",
                        value: .constant(10),
                        in: 5...50,
                        subtitle: "Number of items to show"
                    )
                }
            }
            .padding(DesignSystem.Spacing.large)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("Form Components")
    }
}