import SwiftUI

// MARK: - Unified Style Guide
// This file defines the SINGLE source of truth for all UI styles in the app
// ALL components MUST use these styles to maintain consistency

struct UnifiedStyleGuide {
    
    // MARK: - Tab/Navigation Pills
    struct TabPill {
        static let selectedBackground = Color.ds.primary
        static let unselectedBackground = Color.clear
        static let selectedTextColor = Color.white
        static let unselectedTextColor = Color.ds.text
        static let borderColor = Color.ds.primary.opacity(0.2)
        static let cornerRadius: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let fontSize: CGFloat = 15
        static let fontWeight: Font.Weight = .medium
        static let borderWidth: CGFloat = 1.5
    }
    
    // MARK: - Cards
    struct Card {
        static let backgroundColor = Color.ds.surface
        static let borderColor = Color.ds.border
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let shadowColor = Color.black.opacity(0.04)
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
        static let borderWidth: CGFloat = 1
    }
    
    // MARK: - Stats Cards
    struct StatsCard {
        static let backgroundColor = Color.ds.surfaceSecondary
        static let iconBackgroundColor = { (color: Color) in color.opacity(0.15) }
        static let iconSize: CGFloat = 24
        static let iconContainerSize: CGFloat = 56
        static let valueFont = Font.system(size: 24, weight: .bold, design: .rounded)
        static let labelFont = Font.system(size: 12, weight: .medium)
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
    }
    
    // MARK: - Profile Header
    struct ProfileHeader {
        static let gradientColors = [Color.ds.primary.opacity(0.8), Color.ds.secondary.opacity(0.6)]
        static let overlayGradient = [Color.black.opacity(0), Color.black.opacity(0.4)]
        static let avatarSize: CGFloat = 100
        static let avatarBorderWidth: CGFloat = 4
        static let avatarBorderColor = Color.white
        static let cornerRadius: CGFloat = 32
    }
    
    // MARK: - Buttons
    struct Button {
        static let primaryBackground = Color.ds.primary
        static let primaryTextColor = Color.white
        static let secondaryBackground = Color.ds.primary.opacity(0.1)
        static let secondaryTextColor = Color.ds.primary
        static let cornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
        static let fontSize: CGFloat = 16
        static let fontWeight: Font.Weight = .medium
    }
    
    // MARK: - Section Headers
    struct SectionHeader {
        static let titleFont = Font.system(size: 24, weight: .bold, design: .rounded)
        static let subtitleFont = Font.system(size: 14)
        static let titleColor = Color.ds.text
        static let subtitleColor = Color.ds.textSecondary
        static let spacing: CGFloat = 4
    }
    
    // MARK: - Empty States
    struct EmptyState {
        static let iconSize: CGFloat = 60
        static let iconColor = Color.ds.textTertiary.opacity(0.5)
        static let titleFont = Font.ds.title3
        static let messageFont = Font.ds.body
        static let titleColor = Color.ds.text
        static let messageColor = Color.ds.textSecondary
        static let spacing: CGFloat = 16
    }
}

// MARK: - Unified View Modifiers

/* Commented out to avoid conflicts with DesignSystem.swift
extension View {
    // MARK: - Tab Pills
    func unifiedTabPill(isSelected: Bool) -> some View {
        self
            .font(.system(size: UnifiedStyleGuide.TabPill.fontSize, weight: UnifiedStyleGuide.TabPill.fontWeight)
            .foregroundColor(isSelected ? UnifiedStyleGuide.TabPill.selectedTextColor : UnifiedStyleGuide.TabPill.unselectedTextColor)
            .padding(.horizontal, UnifiedStyleGuide.TabPill.horizontalPadding)
            .padding(.vertical, UnifiedStyleGuide.TabPill.verticalPadding)
            .background(
                Capsule()
                    .fill(isSelected ? UnifiedStyleGuide.TabPill.selectedBackground : UnifiedStyleGuide.TabPill.unselectedBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : UnifiedStyleGuide.TabPill.borderColor, lineWidth: UnifiedStyleGuide.TabPill.borderWidth)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    // MARK: - Cards
    func unifiedCard() -> some View {
        self
            .padding(UnifiedStyleGuide.Card.padding)
            .background(UnifiedStyleGuide.Card.backgroundColor)
            .cornerRadius(UnifiedStyleGuide.Card.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: UnifiedStyleGuide.Card.cornerRadius)
                    .stroke(UnifiedStyleGuide.Card.borderColor, lineWidth: UnifiedStyleGuide.Card.borderWidth)
            )
            .shadow(
                color: UnifiedStyleGuide.Card.shadowColor,
                radius: UnifiedStyleGuide.Card.shadowRadius,
                x: 0,
                y: UnifiedStyleGuide.Card.shadowY
            )
    }
    
}
*/

// MARK: - Unified Components

/* Commented out to avoid conflicts with DesignSystem.swift
struct UnifiedSectionHeader: View {
    let title: String
    let subtitle: String? = nil
    let action: (() -> Void)? = nil
    let actionTitle: String? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: UnifiedStyleGuide.SectionHeader.spacing) {
                Text(title)
                    .font(UnifiedStyleGuide.SectionHeader.titleFont)
                    .foregroundColor(UnifiedStyleGuide.SectionHeader.titleColor)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(UnifiedStyleGuide.SectionHeader.subtitleFont)
                        .foregroundColor(UnifiedStyleGuide.SectionHeader.subtitleColor)
                }
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .unifiedSecondaryButton()
                }
            }
        }
    }
}

struct UnifiedEmptyState: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: UnifiedStyleGuide.EmptyState.spacing) {
            Image(systemName: icon)
                .font(.system(size: UnifiedStyleGuide.EmptyState.iconSize)
                .foregroundColor(UnifiedStyleGuide.EmptyState.iconColor)
            
            Text(title)
                .font(UnifiedStyleGuide.EmptyState.titleFont)
                .foregroundColor(UnifiedStyleGuide.EmptyState.titleColor)
            
            Text(message)
                .font(UnifiedStyleGuide.EmptyState.messageFont)
                .foregroundColor(UnifiedStyleGuide.EmptyState.messageColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}


struct UnifiedStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(UnifiedStyleGuide.StatsCard.iconBackgroundColor(color)
                    .frame(width: UnifiedStyleGuide.StatsCard.iconContainerSize, height: UnifiedStyleGuide.StatsCard.iconContainerSize)
                
                Image(systemName: icon)
                    .font(.system(size: UnifiedStyleGuide.StatsCard.iconSize, weight: .semibold)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(UnifiedStyleGuide.StatsCard.valueFont)
                    .foregroundColor(.ds.text)
                
                Text(label)
                    .font(UnifiedStyleGuide.StatsCard.labelFont)
                    .foregroundColor(.ds.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(UnifiedStyleGuide.StatsCard.padding)
        .background(UnifiedStyleGuide.StatsCard.backgroundColor)
        .cornerRadius(UnifiedStyleGuide.StatsCard.cornerRadius)
    }
}
*/
