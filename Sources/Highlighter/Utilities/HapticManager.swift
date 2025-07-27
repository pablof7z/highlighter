import UIKit

/// Centralized haptic feedback manager for consistent tactile interactions
/// Follows the Highlighter app's focus on "pixel-perfect" user experience with refined haptics
@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    /// Disable all haptics (for accessibility or user preference)
    var isEnabled: Bool = true
    
    private init() {
        // Prepare generators on initialization for faster response
        prepare()
    }
    
    enum ImpactStyle {
        case light, medium, heavy
    }
    
    enum NotificationStyle {
        case success, warning, error
    }
    
    func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    func impact(_ style: ImpactStyle) {
        guard isEnabled else { return }
        switch style {
        case .light:
            impactLight.impactOccurred()
            impactLight.prepare() // Prepare for next use
        case .medium:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        case .heavy:
            impactHeavy.impactOccurred()
            impactHeavy.prepare()
        }
    }
    
    
    func triggerSelection() {
        guard isEnabled else { return }
        selection.selectionChanged()
        selection.prepare()
    }
    
    func notification(_ style: NotificationStyle) {
        guard isEnabled else { return }
        switch style {
        case .success:
            notification.notificationOccurred(.success)
        case .warning:
            notification.notificationOccurred(.warning)
        case .error:
            notification.notificationOccurred(.error)
        }
        notification.prepare()
    }
    
    // MARK: - Haptic Timing Constants
    
    private enum HapticDelays {
        static let shortDelay: TimeInterval = 0.1
        static let mediumDelay: TimeInterval = 0.2
        static let longDelay: TimeInterval = 0.3
    }
    
    // MARK: - Contextual Haptic Methods for Highlighter App
    
    /// Haptic for highlighting text (medium impact)
    func highlight() { impact(.medium) }
    
    /// Haptic for zap actions (heavy impact + success notification)
    func zap() {
        impact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + HapticDelays.shortDelay) {
            self.notification(.success)
        }
    }
    
    /// Haptic for bookmark/save actions (light impact)
    func bookmark() { impact(.light) }
    
    /// Haptic for successful actions (e.g., publish highlight)
    func success() { notification(.success) }
    
    /// Haptic for error states
    func error() { notification(.error) }
    
    /// Haptic for warning states
    func warning() { notification(.warning) }
    
    /// Haptic for tab bar selection
    func tabSelection() { triggerSelection() }
    
    /// Haptic for button press with contextual feedback
    func buttonPress(style: ImpactStyle = .light) { impact(style) }
    
    /// Haptic for card interactions (light impact)
    func cardTap() { impact(.light) }
    
    /// Haptic for swipe actions
    func swipe() { impact(.light) }
    
    /// Haptic for long press gestures
    func longPress() { impact(.heavy) }
    
    /// Subtle haptic for hover/selection preview
    func preview() { impact(.light) }
    
    // MARK: - Complex Haptic Patterns
    
    /// Haptic pattern for publishing content (sequence of impacts)
    func publish() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + HapticDelays.mediumDelay) {
            self.notification(.success)
        }
    }
    
    /// Haptic pattern for loading completion
    func loadComplete() { impact(.light) }
    
    /// Haptic pattern for pull-to-refresh
    func refresh() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + HapticDelays.longDelay) {
            self.impact(.light)
        }
    }
}
