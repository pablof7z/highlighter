import SwiftUI
import UIKit

// MARK: - Liquid Morphing Tab Bar with Advanced Animations
struct EnhancedTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var animatingTab: ContentView.Tab?
    @State private var tabWidths: [ContentView.Tab: CGFloat] = [:]
    @State private var tabOffsets: [ContentView.Tab: CGFloat] = [:]
    @State private var bubbleOffset: CGFloat = 0
    @State private var bubbleWidth: CGFloat = 60
    @State private var bubbleHeight: CGFloat = 52
    @State private var showTabLabels = true
    @State private var selectedTabScale: CGFloat = 1
    @Namespace private var animation
    
    // Haptic feedback
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Clean minimal background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(Color.ds.surface.opacity(0.85))
                    )
                    .overlay(
                        Divider()
                            .frame(height: 0.5)
                            .foregroundColor(Color.ds.border),
                        alignment: .top
                    )
                    .frame(height: 56)
                
                // Subtle selection indicator
                if let offset = tabOffsets[selectedTab] {
                    Rectangle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 28, height: 2)
                        .offset(x: offset, y: -24)
                        .animation(
                            .easeInOut(duration: 0.25),
                            value: selectedTab
                        )
                }
                
                // Tab items
                HStack(spacing: 0) {
                    ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                        TabItem(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            animatingTab: animatingTab,
                            showLabel: showTabLabels,
                            namespace: animation
                        )
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { itemGeometry in
                                Color.clear
                                    .onAppear {
                                        let frame = itemGeometry.frame(in: .named("tabBar"))
                                        tabOffsets[tab] = frame.midX - geometry.size.width / 2
                                        tabWidths[tab] = frame.width
                                    }
                                    .onChange(of: geometry.size) { _, _ in
                                        let frame = itemGeometry.frame(in: .named("tabBar"))
                                        tabOffsets[tab] = frame.midX - geometry.size.width / 2
                                        tabWidths[tab] = frame.width
                                    }
                            }
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedTab != tab {
                                    impactMedium.impactOccurred()
                                    animatingTab = tab
                                    selectedTab = tab
                                    
                                    // Trigger selection animation
                                    triggerSelectionAnimation(for: tab)
                                    
                                    // Clear animation state
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        animatingTab = nil
                                    }
                                } else {
                                    // Double tap effect
                                    impactLight.impactOccurred()
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                        animatingTab = tab
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        animatingTab = nil
                                    }
                                }
                            }
                        }
                        .onLongPressGesture {
                            impactMedium.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                showTabLabels.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)
                .padding(.bottom, 20)
                .coordinateSpace(name: "tabBar")
                
            }
            .frame(height: 72)
        }
        .frame(height: 72)
        .onAppear {
            impactMedium.prepare()
            impactLight.prepare()
            updateBubbleWidth(for: selectedTab)
        }
    }
    
    private func updateBubbleWidth(for tab: ContentView.Tab) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            switch tab {
            case .home, .profile:
                bubbleWidth = 65
                bubbleHeight = 52
            case .feed, .library:
                bubbleWidth = 70
                bubbleHeight = 54
            case .discover:
                bubbleWidth = 75
                bubbleHeight = 56
            }
        }
    }
    
    private func triggerSelectionAnimation(for tab: ContentView.Tab) {
        // Simple selection feedback
    }
}

struct TabItem: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let animatingTab: ContentView.Tab?
    let showLabel: Bool
    let namespace: Namespace.ID
    
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: showLabel ? 4 : 0) {
            ZStack {
                // Background icon (for smooth transitions)
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .opacity(isSelected ? 0 : 1)
                    .foregroundColor(.ds.textSecondary)
                
                // Filled icon with animations
                Image(systemName: tab.filledIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .opacity(isSelected ? 1 : 0)
                    .foregroundColor(.ds.primary)
                    .rotationEffect(.degrees(iconRotation))
                    .scaleEffect(iconScale)
            }
            .frame(width: 24, height: 24)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            if showLabel {
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .ds.primary : .ds.textSecondary)
                    .transition(.asymmetric(
                        insertion: .push(from: .bottom).combined(with: .opacity),
                        removal: .push(from: .top).combined(with: .opacity)
                    ))
            }
        }
        .scaleEffect(animatingTab == tab ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animatingTab)
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                // Animate icon when selected
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    iconScale = 1.2
                    iconRotation = 10
                }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    iconScale = 1.0
                    iconRotation = 0
                }
            }
        }
    }
}

// MARK: - Supporting Views


#Preview {
    ZStack {
        // Background content
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        // Tab bar at bottom
        VStack {
            Spacer()
            EnhancedTabBar(selectedTab: .constant(.home))
        }
    }
}