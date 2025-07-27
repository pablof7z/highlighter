import Foundation
import NDKSwift
import SwiftUI

/// Service for tracking and persisting reading progress across articles
@MainActor
class ReadingProgressService: ObservableObject {
    // MARK: - Models
    struct ArticleProgress: Codable {
        let articleId: String
        let progress: Double // 0.0 to 1.0
        let lastReadDate: Date
        let totalReadingTime: TimeInterval // in seconds
        let scrollPosition: CGFloat
    }
    
    struct ReadingSession {
        let articleId: String
        let startTime: Date
        var lastUpdateTime: Date
    }
    
    // MARK: - Published Properties
    @Published private(set) var progressByArticle: [String: ArticleProgress] = [:]
    @Published private(set) var activeSession: ReadingSession?
    
    // MARK: - Private Properties
    private let progressKey = "reading_progress_v1"
    private let progressUpdateThreshold: TimeInterval = 2.0 // Update every 2 seconds
    private var lastProgressUpdate: Date = Date()
    
    // MARK: - Initialization
    init() {
        loadProgress()
    }
    
    // MARK: - Public Methods
    
    /// Start a reading session for an article
    func startReadingSession(for articleId: String) {
        activeSession = ReadingSession(
            articleId: articleId,
            startTime: Date(),
            lastUpdateTime: Date()
        )
    }
    
    /// End the current reading session
    func endReadingSession() {
        guard let session = activeSession else { return }
        
        let readingTime = Date().timeIntervalSince(session.startTime)
        if let existing = progressByArticle[session.articleId] {
            progressByArticle[session.articleId] = ArticleProgress(
                articleId: session.articleId,
                progress: existing.progress,
                lastReadDate: Date(),
                totalReadingTime: existing.totalReadingTime + readingTime,
                scrollPosition: existing.scrollPosition
            )
        }
        
        activeSession = nil
        saveProgress()
    }
    
    /// Update reading progress for an article
    func updateProgress(for articleId: String, progress: Double, scrollPosition: CGFloat) {
        // Throttle updates to avoid excessive saves
        guard Date().timeIntervalSince(lastProgressUpdate) >= progressUpdateThreshold else { return }
        
        lastProgressUpdate = Date()
        
        // Update active session time if this is the current article
        if activeSession?.articleId == articleId {
            activeSession?.lastUpdateTime = Date()
        }
        
        let existingProgress = progressByArticle[articleId]
        let totalTime = existingProgress?.totalReadingTime ?? 0
        
        progressByArticle[articleId] = ArticleProgress(
            articleId: articleId,
            progress: progress,
            lastReadDate: Date(),
            totalReadingTime: totalTime,
            scrollPosition: scrollPosition
        )
        
        saveProgress()
    }
    
    /// Get progress for a specific article
    func getProgress(for articleId: String) -> ArticleProgress? {
        return progressByArticle[articleId]
    }
    
    /// Get all articles with reading progress
    func getArticlesInProgress() -> [ArticleProgress] {
        return progressByArticle.values
            .filter { $0.progress > 0 && $0.progress < 1 }
            .sorted { $0.lastReadDate > $1.lastReadDate }
    }
    
    /// Get recently read articles
    func getRecentlyReadArticles(limit: Int = 10) -> [ArticleProgress] {
        return progressByArticle.values
            .sorted { $0.lastReadDate > $1.lastReadDate }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Calculate estimated reading time based on word count
    static func estimateReadingTime(wordCount: Int) -> TimeInterval {
        // Average reading speed: 200-250 words per minute
        let wordsPerMinute = 225.0
        return (Double(wordCount) / wordsPerMinute) * 60.0
    }
    
    /// Mark an article as completed
    func markAsCompleted(articleId: String) {
        if let existing = progressByArticle[articleId] {
            progressByArticle[articleId] = ArticleProgress(
                articleId: articleId,
                progress: 1.0,
                lastReadDate: Date(),
                totalReadingTime: existing.totalReadingTime,
                scrollPosition: 0
            )
            saveProgress()
        }
    }
    
    /// Clear progress for an article
    func clearProgress(for articleId: String) {
        progressByArticle.removeValue(forKey: articleId)
        saveProgress()
    }
    
    /// Clear all reading progress
    func clearAllProgress() {
        progressByArticle.removeAll()
        saveProgress()
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(progressByArticle)
            UserDefaults.standard.set(data, forKey: progressKey)
        } catch {
            // Silently fail - reading progress is not critical
        }
    }
    
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            progressByArticle = try decoder.decode([String: ArticleProgress].self, from: data)
        } catch {
            // Silently fail - reading progress is not critical
        }
    }
}

// MARK: - Progress Indicator View
struct ReadingProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .frame(height: 4)
                
                // Progress
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Reading Stats View
struct ReadingStatsView: View {
    let progress: ReadingProgressService.ArticleProgress
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Progress percentage
            Label {
                Text("\(Int(progress.progress * 100))%")
                    .font(.ds.caption)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: "book.fill")
                    .font(.system(size: 12))
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Divider()
                .frame(height: 12)
            
            // Reading time
            Label {
                Text(formatReadingTime(progress.totalReadingTime))
                    .font(.ds.caption)
                    .fontWeight(.medium)
            } icon: {
                Image(systemName: "clock")
                    .font(.system(size: 12))
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
    
    private func formatReadingTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 1 {
            return "< 1 min"
        } else if minutes < 60 {
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