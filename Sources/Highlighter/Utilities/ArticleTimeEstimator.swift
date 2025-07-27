import Foundation

/// Estimates reading time for articles based on content length
struct ArticleTimeEstimator {
    /// Average words per minute for reading
    /// Standard reading speed is 200-250 wpm, we use 225 as average
    private static let wordsPerMinute: Double = 225
    
    /// Estimate reading time in minutes for given content
    /// - Parameter content: The article content text
    /// - Returns: Estimated reading time in minutes, or nil if content is empty
    static func estimateReadingTime(for content: String) -> Int? {
        let cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedContent.isEmpty else { return nil }
        
        // Count words by splitting on whitespace and punctuation
        let words = cleanedContent.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        
        // Calculate reading time
        let minutes = Double(words) / wordsPerMinute
        
        // Round up to nearest minute, minimum 1 minute
        return max(1, Int(ceil(minutes))
    }
    
    /// Format reading time for display
    /// - Parameter minutes: Reading time in minutes
    /// - Returns: Formatted string like "5 min" or "1 hr 15 min"
    static func formatReadingTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
}