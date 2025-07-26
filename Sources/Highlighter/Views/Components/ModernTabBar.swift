import SwiftUI

struct ModernTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Subtle top border with gradient
            LinearGradient(
                colors: [
                    DesignSystem.Colors.divider.opacity(0.8),
                    DesignSystem.Colors.divider.opacity(0.2)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 0.5)
            
            HStack(spacing: 0) {
                ForEach(Array(ContentView.Tab.allCases.enumerated()), id: \.element) { index, tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: {
                            if selectedTab != tab {
                                HapticManager.shared.triggerSelection()
                                withAnimation(DesignSystem.Animation.springSnappy) {
                                    selectedTab = tab
                                    selectedIndex = index
                                }
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.base)
            .padding(.top, DesignSystem.Spacing.small)
            .padding(.bottom, DesignSystem.Spacing.medium)
            .background(
                // Floating selection indicator
                GeometryReader { geometry in
                    let tabWidth = geometry.size.width / CGFloat(ContentView.Tab.allCases.count)
                    
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                        .frame(width: tabWidth * 0.8, height: 6)
                        .offset(
                            x: tabWidth * CGFloat(selectedIndex) + tabWidth * 0.1,
                            y: geometry.size.height - 8
                        )
                        .animation(DesignSystem.Animation.springSnappy, value: selectedIndex)
                }
            )
        }
        .background(
            // Glass morphism effect
            .ultraThinMaterial,
            in: Rectangle()
        )
        .overlay(
            // Subtle inner glow on top edge
            LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
            .blendMode(.overlay),
            alignment: .top
        )
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // Set initial selected index
            selectedIndex = ContentView.Tab.allCases.firstIndex(of: selectedTab) ?? 0
        }
    }
}

struct TabBarButton: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.micro) {
                // Icon with smooth transitions
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [DesignSystem.Colors.textTertiary, DesignSystem.Colors.textTertiary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(isSelected ? 1.15 : (isPressed ? 0.95 : 1.0))
                    .animation(DesignSystem.Animation.springSnappy, value: isSelected)
                    .animation(DesignSystem.Animation.quick, value: isPressed)
                    .contentTransition(.symbolEffect(.replace))
                
                Text(title)
                    .font(isSelected ? DesignSystem.Typography.captionMedium : DesignSystem.Typography.caption)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    .opacity(isSelected ? 1.0 : 0.8)
                    .animation(DesignSystem.Animation.springSnappy, value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.small)
            .contentShape(Rectangle()) // Better touch targets
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(DesignSystem.Animation.quick) {
                    isPressed = pressing
                }
                if pressing {
                    HapticManager.shared.impact(.light)
                }
            },
            perform: {}
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    action()
                }
        )
    }
    
    private var iconName: String {
        isSelected ? tab.filledIcon : tab.icon
    }
    
    private var title: String {
        tab.title
    }
}
