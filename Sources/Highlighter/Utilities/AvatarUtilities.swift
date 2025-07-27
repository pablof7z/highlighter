import SwiftUI

// MARK: - Avatar Utilities
// Centralized utilities for avatar generation and display

struct AvatarUtilities {
    
    // MARK: - Initials Generation
    
    /// Generate initials from pubkey for avatar display
    static func generateInitials(from pubkey: String) -> String {
        PubkeyFormatter.formatForAvatar(pubkey)
    }
    
    // MARK: - Color Generation
    
    /// Generate consistent gradient colors based on pubkey
    static func gradientColors(for pubkey: String) -> [Color] {
        let hash = pubkey.hashValue
        let hue1 = Double(abs(hash % 360)) / 360.0
        let hue2 = (hue1 + 0.1).truncatingRemainder(dividingBy: 1.0)
        
        return [
            Color(hue: hue1, saturation: 0.7, brightness: 0.8),
            Color(hue: hue2, saturation: 0.6, brightness: 0.9)
        ]
    }
    
    /// Generate gradient for avatar background
    static func gradient(for pubkey: String) -> LinearGradient {
        LinearGradient(
            colors: gradientColors(for: pubkey),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Generate single color based on pubkey (for simpler use cases)
    static func color(for pubkey: String) -> Color {
        let hash = pubkey.hashValue
        let hue = Double(abs(hash % 360)) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
    
    // MARK: - Placeholder View
    
    /// Create a standard placeholder avatar view
    static func placeholderAvatar(
        pubkey: String,
        size: CGFloat,
        fontSize: CGFloat? = nil
    ) -> some View {
        ZStack {
            Circle()
                .fill(gradient(for: pubkey))
            
            Text(generateInitials(from: pubkey))
                .font(.system(
                    size: fontSize ?? (size * 0.4),
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .frame(width: size, height: size)
    }
}