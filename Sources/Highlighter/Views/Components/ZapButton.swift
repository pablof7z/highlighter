import SwiftUI
import NDKSwift

struct ZapButton: View {
    let event: NDKEvent
    let size: ButtonSize
    
    @EnvironmentObject var appState: AppState
    
    enum ButtonSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
    }
    
    // Zapping functionality removed - this is now just a placeholder button
    
    var body: some View {
        Button(action: {
            // Zapping functionality removed - this button does nothing now
            HapticManager.shared.impact(.light)
        }) {
            Image(systemName: "bolt")
                .font(.system(size: size.iconSize, weight: .regular))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .padding(.horizontal, size.padding * 0.8)
                .padding(.vertical, size.padding * 0.6)
        }
        .disabled(true) // Disabled since no wallet functionality
        .opacity(0.5) // Show as disabled
    }
    
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .small
            )
            
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .medium
            )
            
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .large
            )
        }
    }
    .padding()
    .environmentObject(AppState())
}
