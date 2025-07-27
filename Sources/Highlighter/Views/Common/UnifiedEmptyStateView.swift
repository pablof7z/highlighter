import SwiftUI

struct UnifiedEmptyStateView: View {
    enum EmptyStateType {
        case highlights
        case articles
        case curations
        case comments
        case search(String)
        case custom(icon: String, title: String, message: String)
    }
    
    let type: EmptyStateType
    let onAction: (() -> Void)?
    
    @State private var isPressed = false
    @State private var iconRotation: Double = 0
    @State private var glowAnimation = false
    
    init(type: EmptyStateType, onAction: (() -> Void)? = nil) {
        self.type = type
        self.onAction = onAction
    }
    
    private var configuration: (icon: String, title: String, message: String, actionText: String?) {
        switch type {
        case .highlights:
            return ("highlighter", "Your Wisdom Awaits", "Transform your reading into a curated collection of insights.", "Begin Highlighting")
        case .articles:
            return ("doc.text.magnifyingglass", "No articles yet", "Articles added to this collection will appear here.", nil)
        case .curations:
            return ("folder.badge.plus", "No curations yet", "Create your first curation to organize your highlights.", "Create Curation")
        case .comments:
            return ("bubble.left.and.bubble.right", "Start the conversation", "Be the first to share your thoughts.", "Add Comment")
        case .search(let query):
            return ("magnifyingglass", "No results found", "No items match '\(query)'.", nil)
        case .custom(let icon, let title, let message):
            return (icon, title, message, nil)
        }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()
            
            // Icon with glow effect
            ZStack {
                // Glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(glowAnimation ? 1.1 : 0.9)
                    .opacity(glowAnimation ? 1 : 0.7)
                
                // Icon background
                Circle()
                    .fill(DesignSystem.Colors.surface)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: configuration.icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.8))
                    .rotationEffect(.degrees(iconRotation))
            }
            
            // Text content
            VStack(spacing: DesignSystem.Spacing.small) {
                Text(configuration.title)
                    .font(.ds.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(configuration.message)
                    .font(.ds.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            
            // Action button if available
            if let actionText = configuration.actionText, let onAction = onAction {
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    onAction()
                }) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: configuration.icon)
                            .font(.ds.bodyMedium)
                        
                        Text(actionText)
                            .font(.ds.bodyMedium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.vertical, DesignSystem.Spacing.medium)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.primary)
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: 8,
                        y: 4
                    )
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0.05, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                }, perform: {})
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
            
            if type == .highlights {
                withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                    iconRotation = 10
                }
            }
        }
    }
}