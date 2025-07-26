import SwiftUI
import NDKSwift

// MARK: - Centralized Formatting Utilities
// Following DRY principle: All formatting logic consolidated in one place

// MARK: - Pubkey Formatting

struct PubkeyFormatter {
    /// Format pubkey for display with customizable length
    /// - Parameters:
    ///   - pubkey: The public key to format
    ///   - prefixLength: Number of characters from the start (default: 8)
    ///   - suffixLength: Number of characters from the end (default: 4)
    /// - Returns: Formatted string like "npub1abc...xyz"
    static func format(_ pubkey: String, prefixLength: Int = 8, suffixLength: Int = 4) -> String {
        guard pubkey.count > prefixLength + suffixLength else {
            return pubkey
        }
        
        let prefix = String(pubkey.prefix(prefixLength))
        let suffix = String(pubkey.suffix(suffixLength))
        return "\(prefix)...\(suffix)"
    }
    
    /// Compact format for tight spaces (6 + 3 characters)
    static func formatCompact(_ pubkey: String) -> String {
        format(pubkey, prefixLength: 6, suffixLength: 3)
    }
    
    /// Short format for lists and cards (8 + 4 characters)
    static func formatShort(_ pubkey: String) -> String {
        format(pubkey, prefixLength: 8, suffixLength: 4)
    }
    
    /// Long format for profile pages (12 + 6 characters)
    static func formatLong(_ pubkey: String) -> String {
        format(pubkey, prefixLength: 12, suffixLength: 6)
    }
    
    /// Format for avatar initials (first 2 characters)
    static func formatForAvatar(_ pubkey: String) -> String {
        String(pubkey.prefix(2)).uppercased()
    }
    
    /// Format for display name with fallback options
    static func displayName(from profile: NDKUserProfile?, pubkey: String) -> String {
        if let displayName = profile?.displayName, !displayName.isEmpty {
            return displayName
        } else if let name = profile?.name, !name.isEmpty {
            return name
        } else {
            return formatShort(pubkey)
        }
    }
    
    /// Check if a string is a valid pubkey format
    static func isValidPubkey(_ pubkey: String) -> Bool {
        HexValidator.isValid32ByteHex(pubkey)
    }
    
    /// Convert hex pubkey to npub format (if needed in the future)
    static func toNpub(_ hexPubkey: String) -> String {
        // For now, just return the hex format as specified in the NDK guidance
        // "All public keys are hex encoded (not npub)"
        return hexPubkey
    }
}

// MARK: - Time Formatting

struct RelativeTimeFormatter {
    // Time interval constants in seconds
    private enum TimeIntervals {
        static let justNow: TimeInterval = 30
        static let minute: TimeInterval = 60
        static let hour: TimeInterval = 3600
        static let day: TimeInterval = 86400
        static let week: TimeInterval = 604800
        static let month: TimeInterval = 2592000  // 30 days approximation
        static let year: TimeInterval = 31536000  // 365 days
    }
    
    /// Format timestamp as relative time (e.g., "2 hours ago", "just now")
    /// - Parameter timestamp: NDK timestamp to format
    /// - Returns: Human-readable relative time string
    static func relativeTime(from timestamp: Timestamp) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return relativeTime(from: date)
    }
    
    /// Format Date as relative time
    /// - Parameter date: Date to format
    /// - Returns: Human-readable relative time string
    static func relativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        // Future dates
        if interval < 0 {
            return "in the future"
        }
        
        // Just now (under 30 seconds)
        if interval < TimeIntervals.justNow {
            return "just now"
        }
        
        // Minutes
        if interval < TimeIntervals.hour {
            let minutes = Int(interval / TimeIntervals.minute)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        
        // Hours (under 24 hours)
        if interval < TimeIntervals.day {
            let hours = Int(interval / TimeIntervals.hour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
        
        // Days (under 7 days)
        if interval < TimeIntervals.week {
            let days = Int(interval / TimeIntervals.day)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
        
        // Weeks (under 30 days)
        if interval < TimeIntervals.month {
            let weeks = Int(interval / TimeIntervals.week)
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        }
        
        // Months (under 365 days)
        if interval < TimeIntervals.year {
            let months = Int(interval / TimeIntervals.month)
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }
        
        // Years
        let years = Int(interval / TimeIntervals.year)
        return "\(years) year\(years == 1 ? "" : "s") ago"
    }
    
    /// Short relative time format for compact display (e.g., "2h", "3d", "1y")
    /// - Parameter timestamp: NDK timestamp to format
    /// - Returns: Short relative time string
    static func shortRelativeTime(from timestamp: Timestamp) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return shortRelativeTime(from: date)
    }
    
    /// Short relative time format for compact display
    /// - Parameter date: Date to format
    /// - Returns: Short relative time string
    static func shortRelativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        // Future dates
        if interval < 0 {
            return "future"
        }
        
        // Just now (under 30 seconds)
        if interval < TimeIntervals.justNow {
            return "now"
        }
        
        // Minutes
        if interval < TimeIntervals.hour {
            let minutes = Int(interval / TimeIntervals.minute)
            return "\(minutes)m"
        }
        
        // Hours (under 24 hours)
        if interval < TimeIntervals.day {
            let hours = Int(interval / TimeIntervals.hour)
            return "\(hours)h"
        }
        
        // Days (under 7 days)
        if interval < TimeIntervals.week {
            let days = Int(interval / TimeIntervals.day)
            return "\(days)d"
        }
        
        // Weeks (under 30 days)
        if interval < TimeIntervals.month {
            let weeks = Int(interval / TimeIntervals.week)
            return "\(weeks)w"
        }
        
        // Months (under 365 days)
        if interval < TimeIntervals.year {
            let months = Int(interval / TimeIntervals.month)
            return "\(months)mo"
        }
        
        // Years
        let years = Int(interval / TimeIntervals.year)
        return "\(years)y"
    }
    
    /// Format timestamp as exact time when needed (e.g., "Mar 15, 2024 at 3:45 PM")
    /// - Parameter timestamp: NDK timestamp to format
    /// - Returns: Formatted date and time string
    static func exactTime(from timestamp: Timestamp) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return exactTime(from: date)
    }
    
    /// Format Date as exact time
    /// - Parameter date: Date to format
    /// - Returns: Formatted date and time string
    static func exactTime(from date: Date) -> String {
        return DateFormatters.display.string(from: date)
    }
    
    /// Smart formatting that switches between relative and exact based on age
    /// Recent items show relative time, older items show exact date
    /// - Parameter timestamp: NDK timestamp to format
    /// - Returns: Contextually appropriate time string
    static func smartFormat(from timestamp: Timestamp) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        // Use relative time for recent items (under 7 days)
        if interval < TimeIntervals.week {
            return relativeTime(from: date)
        }
        
        // Use exact date for older items
        return exactTime(from: date)
    }
    
    /// Ultra-compact time formatting for cards (legacy compatibility)
    static func compactTime(from timestamp: Timestamp) -> String {
        return shortRelativeTime(from: timestamp)
    }
}

// MARK: - Content Formatting

struct ContentFormatter {
    /// Smart truncation of content based on context
    static func smartTruncate(_ content: String, maxLength: Int, context: TruncationContext = .general) -> String {
        guard content.count > maxLength else { return content }
        
        let actualLimit = max(maxLength - 3, 10) // Reserve space for ellipsis
        let truncated = String(content.prefix(actualLimit))
        
        // Try to break at word boundary for better readability
        if let lastSpace = truncated.lastIndex(of: " "), lastSpace > truncated.startIndex {
            let wordBoundaryTruncated = String(truncated[..<lastSpace])
            if wordBoundaryTruncated.count > actualLimit * 3 / 4 { // Only use word boundary if it's not too short
                return wordBoundaryTruncated + "..."
            }
        }
        
        return truncated + "..."
    }
    
    /// Format highlight content with proper quotes
    static func formatHighlight(_ content: String, addQuotes: Bool = true) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return addQuotes ? "\"\(trimmed)\"" : trimmed
    }
    
    /// Extract domain from URL for display
    static func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString) else { return "Source" }
        return url.host ?? "Source"
    }
    
    /// Format sats amount with appropriate units
    static func formatSatsAmount(_ sats: Int64) -> String {
        let thousand: Int64 = 1_000
        let million: Int64 = 1_000_000
        
        if sats < thousand {
            return "\(sats)"
        } else if sats < million {
            let k = Double(sats) / Double(thousand)
            return String(format: "%.1fk", k)
        } else {
            let m = Double(sats) / Double(million)
            return String(format: "%.1fM", m)
        }
    }
}

// MARK: - Supporting Types

enum TruncationContext {
    case general
    case quote
    case title
    case description
    
    var preferredLength: Int {
        switch self {
        case .general: return 100
        case .quote: return 150
        case .title: return 50
        case .description: return 200
        }
    }
}

// MARK: - Validation Utilities

struct ValidationUtilities {
    /// Validate if a string is a valid Nostr private key (nsec)
    static func isValidNsec(_ nsec: String) -> Bool {
        return nsec.hasPrefix("nsec") && nsec.count > 10
    }
    
    /// Validate if a string is a valid URL
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
    
    /// Clean and validate highlight content
    static func cleanHighlightContent(_ content: String) -> String? {
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty && cleaned.count >= 3 else { return nil }
        return cleaned
    }
}

// MARK: - SwiftUI Integration Helpers

extension View {
    /// Apply smart content truncation with consistent styling
    func smartContent(_ content: String, maxLength: Int = 100, context: TruncationContext = .general) -> some View {
        Text(ContentFormatter.smartTruncate(content, maxLength: maxLength, context: context))
    }
    
    /// Display relative time with consistent formatting
    func relativeTime(from timestamp: Timestamp, style: RelativeTimeStyle = .standard) -> some View {
        let timeString: String
        switch style {
        case .standard:
            timeString = RelativeTimeFormatter.relativeTime(from: timestamp)
        case .short:
            timeString = RelativeTimeFormatter.shortRelativeTime(from: timestamp)
        case .compact:
            timeString = RelativeTimeFormatter.compactTime(from: timestamp)
        }
        return Text(timeString)
    }
}

enum RelativeTimeStyle {
    case standard
    case short
    case compact
}

// MARK: - Greeting Utilities

struct GreetingFormatter {
    /// Generate time-based greeting text
    static func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    /// Format current date for display
    static func formattedDate() -> String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

// MARK: - Cache Policies

/// Common cache duration policies for consistent caching behavior across the app
struct CachePolicies {
    // Base time units
    private static let minute: TimeInterval = 60
    private static let hour: TimeInterval = 60 * minute
    private static let day: TimeInterval = 24 * hour
    
    /// Short-term cache for frequently changing content (5 minutes)
    /// Used for: Highlights (kind 9802) that update frequently  
    static let shortTerm: TimeInterval = 5 * minute
    
    /// Medium-term cache for moderately changing content (1 hour)
    /// Used for: Curations (kind 30004) and Follow Packs (kind 39089)
    static let mediumTerm: TimeInterval = hour
    
    /// Long-term cache for rarely changing content (24 hours)
    /// Used for: User profiles and metadata
    static let longTerm: TimeInterval = day
    
    /// Extended cache for very stable content (7 days)
    /// Used for: Relay lists and other configuration data
    static let extended: TimeInterval = 7 * day
}