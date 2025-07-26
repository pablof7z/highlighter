import SwiftUI

// MARK: - Highlighter-Specific Extensions
// This file contains Highlighter-specific utilities that extend the base DesignSystem
// Following DRY principle: All general design system elements are in DesignSystem.swift

// MARK: - Content Rendering Extensions

extension View {
    /// Performance optimization for scroll views with many items
    func optimizeForScrolling(isVisible: Bool) -> some View {
        self.modifier(ContentOptimizationModifier(isVisible: isVisible))
    }
    
    /// Specialized animation for highlight text selection
    func highlightSelection(_ isSelected: Bool) -> some View {
        self.modifier(HighlightSelectionModifier(isSelected: isSelected))
    }
    
    /// Smart text truncation with context awareness
    func smartTruncation(maxLines: Int, expandable: Bool = false) -> some View {
        self.modifier(SmartTruncationModifier(maxLines: maxLines, expandable: expandable))
    }
}

// MARK: - Specialized Modifiers for Highlighter Content

/// Performance optimization for scroll views with many items
struct ContentOptimizationModifier: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0.3)
            .scaleEffect(isVisible ? 1 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

/// Highlight selection with subtle visual feedback
struct HighlightSelectionModifier: ViewModifier {
    let isSelected: Bool
    @State private var selectionScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? DesignSystem.Colors.secondary.opacity(0.1) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
            .scaleEffect(selectionScale)
            .onChange(of: isSelected) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.8)) {
                        selectionScale = 1.02
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            selectionScale = 1.0
                        }
                    }
                }
            }
    }
}

/// Smart text truncation that can expand when needed
struct SmartTruncationModifier: ViewModifier {
    let maxLines: Int
    let expandable: Bool
    @State private var isExpanded = false
    
    func body(content: Content) -> some View {
        content
            .lineLimit(isExpanded ? nil : maxLines)
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
            .overlay(alignment: .bottomTrailing) {
                if expandable && !isExpanded {
                    Button("more") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = true
                        }
                    }
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.leading, 20)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, DesignSystem.Colors.surface],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
    }
}