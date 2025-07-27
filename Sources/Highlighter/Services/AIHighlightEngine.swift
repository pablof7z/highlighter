import Foundation
import NaturalLanguage
import CoreML
import NDKSwift

/// AI-powered engine for analyzing text and suggesting highlights
/// Uses NLP techniques to identify key passages, important concepts, and quotable content
actor AIHighlightEngine {
    
    // MARK: - Types
    
    enum AnalysisMode {
        case quick      // Basic keyword and sentence importance
        case balanced   // Standard NLP analysis
        case thorough   // Deep analysis with multiple passes
    }
    
    struct TextSegment {
        let text: String
        let range: NSRange
        let sentence: String
        let paragraph: String
        let importance: Double
        let features: TextFeatures
    }
    
    struct TextFeatures {
        let sentencePosition: Double      // Position in paragraph (0-1)
        let paragraphPosition: Double     // Position in document (0-1)
        let wordCount: Int
        let uniqueWordRatio: Double
        let namedEntityCount: Int
        let quotationPresent: Bool
        let statisticPresent: Bool
        let keywordDensity: Double
        let sentimentScore: Double
        let readabilityScore: Double
        let technicalTermCount: Int
        let transitionWordScore: Double
        let emphasisScore: Double         // Based on formatting, punctuation
    }
    
    struct AnalysisResult {
        let suggestions: [HighlightSuggestion]
        let documentMetrics: DocumentMetrics
        let keyTopics: [String]
        let readingTime: Int
        let complexityScore: Double
    }
    
    struct HighlightSuggestion {
        let id = UUID()
        let text: String
        let range: NSRange
        let confidence: Double
        let category: SuggestionCategory
        let reason: String
        let context: String?
        let relatedTopics: [String]
        let importance: ImportanceLevel
    }
    
    enum SuggestionCategory {
        case thesisStatement
        case keyInsight
        case statistic
        case quote
        case definition
        case conclusion
        case example
        case novelConcept
        case controversy
        case summary
        
        var displayName: String {
            switch self {
            case .thesisStatement: return "Core Argument"
            case .keyInsight: return "Key Insight"
            case .statistic: return "Important Data"
            case .quote: return "Notable Quote"
            case .definition: return "Key Definition"
            case .conclusion: return "Conclusion"
            case .example: return "Illustrative Example"
            case .novelConcept: return "New Concept"
            case .controversy: return "Point of Debate"
            case .summary: return "Summary"
            }
        }
    }
    
    enum ImportanceLevel: Int {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }
    
    struct DocumentMetrics {
        let totalWords: Int
        let totalSentences: Int
        let averageSentenceLength: Double
        let lexicalDiversity: Double
        let readabilityScore: Double
        let technicalDensity: Double
        let topKeywords: [(String, Int)]
    }
    
    // MARK: - Properties
    
    private let nlpProcessor = NLPProcessor()
    private let sentimentAnalyzer = NLSentimentAnalyzer()
    private let keywordExtractor = KeywordExtractor()
    private let importanceCalculator = ImportanceCalculator()
    
    // Domain-specific keywords for different fields
    private let domainKeywords: [String: Set<String>] = [
        "technology": ["AI", "machine learning", "algorithm", "data", "software", "hardware", "innovation", "digital", "automation", "blockchain"],
        "science": ["hypothesis", "experiment", "research", "study", "evidence", "theory", "discovery", "analysis", "observation", "conclusion"],
        "philosophy": ["consciousness", "ethics", "morality", "existence", "knowledge", "truth", "reality", "meaning", "purpose", "free will"],
        "business": ["strategy", "market", "revenue", "growth", "innovation", "customer", "value", "competitive", "profit", "efficiency"],
        "literature": ["narrative", "metaphor", "symbolism", "theme", "character", "plot", "style", "genre", "motif", "allegory"]
    ]
    
    // Transition words that often precede important insights
    private let transitionIndicators = Set([
        "however", "therefore", "moreover", "furthermore", "consequently",
        "nevertheless", "thus", "hence", "accordingly", "importantly",
        "significantly", "notably", "remarkably", "interestingly",
        "in conclusion", "in summary", "to summarize", "ultimately",
        "the key is", "the point is", "essentially", "fundamentally"
    ])
    
    // MARK: - Public Methods
    
    func analyzeText(_ text: String, mode: AnalysisMode = .balanced) async throws -> AnalysisResult {
        // Pre-process text
        let cleanedText = preprocessText(text)
        
        // Extract document structure
        _ = extractParagraphs(from: cleanedText)
        let sentences = extractSentences(from: cleanedText)
        
        // Calculate document metrics
        let metrics = await calculateDocumentMetrics(text: cleanedText, sentences: sentences)
        
        // Identify key topics
        let topics = await identifyKeyTopics(from: cleanedText)
        
        // Analyze each sentence
        var segments: [TextSegment] = []
        for (index, sentence) in sentences.enumerated() {
            if let segment = await analyzeSegment(
                sentence: sentence,
                index: index,
                totalSentences: sentences.count,
                fullText: cleanedText,
                mode: mode
            ) {
                segments.append(segment)
            }
        }
        
        // Generate suggestions based on analysis
        let suggestions = await generateSuggestions(
            from: segments,
            topics: topics,
            mode: mode,
            metrics: metrics
        )
        
        // Calculate reading time (words per minute)
        let readingTime = max(1, metrics.totalWords / 200)
        
        // Calculate complexity score
        let complexityScore = calculateComplexityScore(metrics: metrics)
        
        return AnalysisResult(
            suggestions: suggestions,
            documentMetrics: metrics,
            keyTopics: topics,
            readingTime: readingTime,
            complexityScore: complexityScore
        )
    }
    
    // MARK: - Text Processing
    
    private func preprocessText(_ text: String) -> String {
        // Remove excessive whitespace while preserving paragraph structure
        let lines = text.components(separatedBy: .newlines)
        let processedLines = lines.map { line in
            line.trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }
        
        return processedLines.joined(separator: "\n\n")
    }
    
    private func extractParagraphs(from text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func extractSentences(from text: String) -> [(sentence: String, range: NSRange)] {
        var sentences: [(String, NSRange)] = []
        
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range])
            let nsRange = NSRange(range, in: text)
            sentences.append((sentence, nsRange))
            return true
        }
        
        return sentences
    }
    
    // MARK: - Segment Analysis
    
    private func analyzeSegment(
        sentence: (sentence: String, range: NSRange),
        index: Int,
        totalSentences: Int,
        fullText: String,
        mode: AnalysisMode
    ) async -> TextSegment? {
        let text = sentence.sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        
        // Extract features
        let features = await extractFeatures(
            from: text,
            sentenceIndex: index,
            totalSentences: totalSentences,
            fullText: fullText
        )
        
        // Calculate importance score
        let importance = importanceCalculator.calculate(
            features: features,
            mode: mode,
            sentenceIndex: index,
            totalSentences: totalSentences
        )
        
        // Find containing paragraph
        let paragraph = findContainingParagraph(
            for: sentence.range,
            in: fullText
        ) ?? text
        
        return TextSegment(
            text: text,
            range: sentence.range,
            sentence: text,
            paragraph: paragraph,
            importance: importance,
            features: features
        )
    }
    
    private func extractFeatures(
        from text: String,
        sentenceIndex: Int,
        totalSentences: Int,
        fullText: String
    ) async -> TextFeatures {
        // Basic metrics
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let wordCount = words.count
        let uniqueWords = Set(words.map { $0.lowercased() })
        let uniqueWordRatio = Double(uniqueWords.count) / Double(max(1, wordCount))
        
        // Position metrics
        let sentencePosition = Double(sentenceIndex) / Double(max(1, totalSentences - 1))
        let paragraphPosition = calculateParagraphPosition(for: text, in: fullText)
        
        // Named entities
        let namedEntityCount = await countNamedEntities(in: text)
        
        // Check for quotations
        let quotationPresent = text.contains("\"") || text.contains("\u{201C}") || text.contains("'")
        
        // Check for statistics
        let statisticPresent = containsStatistic(text)
        
        // Keyword density
        let keywordDensity = calculateKeywordDensity(text: text, words: words)
        
        // Sentiment analysis
        let sentimentScore = await analyzeSentiment(text)
        
        // Readability
        let readabilityScore = calculateReadability(text: text, wordCount: wordCount)
        
        // Technical terms
        let technicalTermCount = countTechnicalTerms(in: words)
        
        // Transition words
        let transitionWordScore = calculateTransitionScore(words: words)
        
        // Emphasis indicators
        let emphasisScore = calculateEmphasisScore(text: text)
        
        return TextFeatures(
            sentencePosition: sentencePosition,
            paragraphPosition: paragraphPosition,
            wordCount: wordCount,
            uniqueWordRatio: uniqueWordRatio,
            namedEntityCount: namedEntityCount,
            quotationPresent: quotationPresent,
            statisticPresent: statisticPresent,
            keywordDensity: keywordDensity,
            sentimentScore: sentimentScore,
            readabilityScore: readabilityScore,
            technicalTermCount: technicalTermCount,
            transitionWordScore: transitionWordScore,
            emphasisScore: emphasisScore
        )
    }
    
    // MARK: - Feature Extraction Helpers
    
    private func countNamedEntities(in text: String) async -> Int {
        return await nlpProcessor.extractNamedEntities(from: text).count
    }
    
    private func containsStatistic(_ text: String) -> Bool {
        // Check for percentages
        if text.range(of: #"\\d+\\.?\\d*\\s*%"#, options: .regularExpression) != nil {
            return true
        }
        
        // Check for numerical comparisons
        if text.range(of: #"\\d+\\.?\\d*\\s*(times|x|×)\\s+(more|less|greater|higher|lower)"#, options: [.regularExpression, .caseInsensitive]) != nil {
            return true
        }
        
        // Check for fractions and ratios
        if text.range(of: #"\\d+\\s*(out of|of|in)\\s*\\d+"#, options: .regularExpression) != nil {
            return true
        }
        
        // Check for statistical terms with numbers
        let statisticalTerms = ["average", "median", "mean", "increased", "decreased", "rose", "fell", "growth", "decline"]
        for term in statisticalTerms {
            if text.localizedCaseInsensitiveContains(term) && 
               text.range(of: #"\\d+\\.?\\d*"#, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
    
    private func calculateKeywordDensity(text: String, words: [String]) -> Double {
        let lowerWords = words.map { $0.lowercased() }
        var keywordCount = 0
        
        for domain in domainKeywords.values {
            for keyword in domain {
                keywordCount += lowerWords.filter { $0.contains(keyword.lowercased()) }.count
            }
        }
        
        return Double(keywordCount) / Double(max(1, words.count))
    }
    
    private func analyzeSentiment(_ text: String) async -> Double {
        return await sentimentAnalyzer.analyzeSentiment(for: text)
    }
    
    private func calculateReadability(text: String, wordCount: Int) -> Double {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.isEmpty }
        let sentenceCount = max(1, sentences.count)
        
        // Simple readability based on average sentence length
        let avgSentenceLength = Double(wordCount) / Double(sentenceCount)
        
        // Optimal sentence length is around 15-20 words
        if avgSentenceLength >= 15 && avgSentenceLength <= 20 {
            return 1.0
        } else if avgSentenceLength < 10 || avgSentenceLength > 30 {
            return 0.5
        } else {
            return 0.75
        }
    }
    
    private func countTechnicalTerms(in words: [String]) -> Int {
        let technicalPatterns = [
            #".*tion$"#,
            #".*ity$"#,
            #".*ism$"#,
            #".*ology$"#,
            #".*ization$"#
        ]
        
        return words.filter { word in
            let lower = word.lowercased()
            return lower.count > 8 || technicalPatterns.contains { pattern in
                lower.range(of: pattern, options: .regularExpression) != nil
            }
        }.count
    }
    
    private func calculateTransitionScore(words: [String]) -> Double {
        let lowerWords = Set(words.map { $0.lowercased() })
        let foundTransitions = transitionIndicators.intersection(lowerWords)
        return foundTransitions.isEmpty ? 0.0 : 1.0
    }
    
    private func calculateEmphasisScore(text: String) -> Double {
        var score = 0.0
        
        // Check for emphasis punctuation
        if text.contains("!") { score += 0.3 }
        if text.contains(":") { score += 0.2 }
        if text.contains("—") || text.contains("--") { score += 0.2 }
        
        // Check for quoted content
        if text.contains("\"") || text.contains("\u{201C}") { score += 0.3 }
        
        // Check for all caps words (but not single letters)
        let words = text.components(separatedBy: .whitespaces)
        let capsWords = words.filter { $0.count > 1 && $0 == $0.uppercased() && $0.rangeOfCharacter(from: .letters) != nil }
        if !capsWords.isEmpty { score += 0.4 }
        
        return min(1.0, score)
    }
    
    private func calculateParagraphPosition(for sentence: String, in fullText: String) -> Double {
        guard let sentenceRange = fullText.range(of: sentence) else { return 0.5 }
        let position = fullText.distance(from: fullText.startIndex, to: sentenceRange.lowerBound)
        return Double(position) / Double(fullText.count)
    }
    
    private func findContainingParagraph(for range: NSRange, in text: String) -> String? {
        let paragraphs = extractParagraphs(from: text)
        var currentLocation = 0
        
        for paragraph in paragraphs {
            let paragraphLength = paragraph.count + 2 // Account for newlines
            let paragraphRange = NSRange(location: currentLocation, length: paragraph.count)
            
            if NSLocationInRange(range.location, paragraphRange) {
                return paragraph
            }
            
            currentLocation += paragraphLength
        }
        
        return nil
    }
    
    // MARK: - Suggestion Generation
    
    private func generateSuggestions(
        from segments: [TextSegment],
        topics: [String],
        mode: AnalysisMode,
        metrics: DocumentMetrics
    ) async -> [HighlightSuggestion] {
        var suggestions: [HighlightSuggestion] = []
        
        // Sort segments by importance
        let sortedSegments = segments.sorted { $0.importance > $1.importance }
        
        // Determine how many suggestions based on mode
        let suggestionCount: Int
        switch mode {
        case .quick:
            suggestionCount = min(5, sortedSegments.count)
        case .balanced:
            suggestionCount = min(10, sortedSegments.count)
        case .thorough:
            suggestionCount = min(15, sortedSegments.count)
        }
        
        // Generate suggestions for top segments
        for segment in sortedSegments.prefix(suggestionCount) {
            if let suggestion = await createSuggestion(
                from: segment,
                topics: topics,
                metrics: metrics
            ) {
                suggestions.append(suggestion)
            }
        }
        
        // Sort by position in document for natural reading flow
        return suggestions.sorted { $0.range.location < $1.range.location }
    }
    
    private func createSuggestion(
        from segment: TextSegment,
        topics: [String],
        metrics: DocumentMetrics
    ) async -> HighlightSuggestion? {
        // Determine category
        let category = categorizeSegment(segment)
        
        // Generate reason
        let reason = generateReason(for: segment, category: category)
        
        // Find related topics
        let relatedTopics = findRelatedTopics(in: segment.text, from: topics)
        
        // Determine importance level
        let importance = determineImportance(segment: segment, category: category)
        
        // Calculate confidence
        let confidence = calculateConfidence(
            segment: segment,
            category: category,
            metrics: metrics
        )
        
        // Extract context if needed
        let context = segment.paragraph != segment.sentence ? segment.paragraph : nil
        
        return HighlightSuggestion(
            text: segment.text,
            range: segment.range,
            confidence: confidence,
            category: category,
            reason: reason,
            context: context,
            relatedTopics: relatedTopics,
            importance: importance
        )
    }
    
    private func categorizeSegment(_ segment: TextSegment) -> SuggestionCategory {
        let features = segment.features
        
        // Check for thesis statement characteristics
        if features.sentencePosition < 0.2 && features.transitionWordScore > 0 {
            return .thesisStatement
        }
        
        // Check for conclusion
        if features.sentencePosition > 0.8 && features.transitionWordScore > 0 {
            return .conclusion
        }
        
        // Check for statistics
        if features.statisticPresent {
            return .statistic
        }
        
        // Check for quotes
        if features.quotationPresent {
            return .quote
        }
        
        // Check for definitions (usually contain "is" or "means")
        let text = segment.text.lowercased()
        if text.contains(" is ") || text.contains(" means ") || text.contains(" defined as ") {
            return .definition
        }
        
        // Check for examples
        if text.contains("for example") || text.contains("for instance") || text.contains("such as") {
            return .example
        }
        
        // High technical term count might indicate novel concept
        if features.technicalTermCount > 2 {
            return .novelConcept
        }
        
        // Strong sentiment might indicate controversy
        if abs(features.sentimentScore) > 0.7 {
            return .controversy
        }
        
        // Default to key insight
        return .keyInsight
    }
    
    private func generateReason(for segment: TextSegment, category: SuggestionCategory) -> String {
        switch category {
        case .thesisStatement:
            return "Core argument that frames the entire discussion"
        case .keyInsight:
            return segment.features.transitionWordScore > 0 ? "Important conclusion or insight" : "Key point in the argument"
        case .statistic:
            return "Data point that supports the argument"
        case .quote:
            return "Notable quotation from an authority"
        case .definition:
            return "Essential definition for understanding"
        case .conclusion:
            return "Summary of main points"
        case .example:
            return "Concrete example that illustrates the concept"
        case .novelConcept:
            return "Introduction of a new or complex idea"
        case .controversy:
            return "Point of debate or strong opinion"
        case .summary:
            return "Concise summary of key ideas"
        }
    }
    
    private func findRelatedTopics(in text: String, from topics: [String]) -> [String] {
        let lowerText = text.lowercased()
        return topics.filter { topic in
            lowerText.contains(topic.lowercased())
        }.prefix(3).map { $0 }
    }
    
    private func determineImportance(segment: TextSegment, category: SuggestionCategory) -> ImportanceLevel {
        // Category-based importance
        let categoryImportance: ImportanceLevel
        switch category {
        case .thesisStatement, .conclusion:
            categoryImportance = .critical
        case .keyInsight, .statistic, .novelConcept:
            categoryImportance = .high
        case .definition, .quote, .controversy:
            categoryImportance = .medium
        case .example, .summary:
            categoryImportance = .low
        }
        
        // Adjust based on segment importance score
        if segment.importance > 0.9 {
            return .critical
        } else if segment.importance > 0.7 && categoryImportance.rawValue >= ImportanceLevel.medium.rawValue {
            return ImportanceLevel(rawValue: min(categoryImportance.rawValue + 1, ImportanceLevel.critical.rawValue)) ?? categoryImportance
        }
        
        return categoryImportance
    }
    
    private func calculateConfidence(
        segment: TextSegment,
        category: SuggestionCategory,
        metrics: DocumentMetrics
    ) -> Double {
        var confidence = segment.importance
        
        // Boost confidence for certain categories
        switch category {
        case .statistic:
            confidence *= 1.2
        case .thesisStatement, .conclusion:
            confidence *= 1.15
        case .quote:
            confidence *= 1.1
        default:
            break
        }
        
        // Adjust based on document quality
        if metrics.readabilityScore > 0.7 {
            confidence *= 1.1
        }
        
        // Ensure confidence is between 0 and 1
        return min(1.0, max(0.0, confidence))
    }
    
    // MARK: - Document Analysis
    
    private func calculateDocumentMetrics(text: String, sentences: [(String, NSRange)]) async -> DocumentMetrics {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let totalWords = words.count
        let totalSentences = sentences.count
        
        let averageSentenceLength = Double(totalWords) / Double(max(1, totalSentences))
        
        // Lexical diversity (unique words / total words)
        let uniqueWords = Set(words.map { $0.lowercased() })
        let lexicalDiversity = Double(uniqueWords.count) / Double(max(1, totalWords))
        
        // Readability score (simplified)
        let readabilityScore = calculateOverallReadability(
            avgSentenceLength: averageSentenceLength,
            lexicalDiversity: lexicalDiversity
        )
        
        // Technical density
        let technicalWords = words.filter { word in
            word.count > 8 || countTechnicalTerms(in: [word]) > 0
        }
        let technicalDensity = Double(technicalWords.count) / Double(max(1, totalWords))
        
        // Top keywords
        let topKeywords = await keywordExtractor.extractTopKeywords(from: text, count: 10)
        
        return DocumentMetrics(
            totalWords: totalWords,
            totalSentences: totalSentences,
            averageSentenceLength: averageSentenceLength,
            lexicalDiversity: lexicalDiversity,
            readabilityScore: readabilityScore,
            technicalDensity: technicalDensity,
            topKeywords: topKeywords
        )
    }
    
    private func calculateOverallReadability(avgSentenceLength: Double, lexicalDiversity: Double) -> Double {
        // Simple readability formula
        var score = 1.0
        
        // Penalize very long or very short sentences
        if avgSentenceLength < 10 {
            score *= 0.8
        } else if avgSentenceLength > 25 {
            score *= 0.7
        }
        
        // Reward good lexical diversity
        if lexicalDiversity > 0.6 {
            score *= 1.1
        } else if lexicalDiversity < 0.3 {
            score *= 0.8
        }
        
        return min(1.0, max(0.0, score))
    }
    
    private func identifyKeyTopics(from text: String) async -> [String] {
        // Extract named entities and keywords
        let entities = await nlpProcessor.extractNamedEntities(from: text)
        let keywords = await keywordExtractor.extractTopKeywords(from: text, count: 5)
        
        // Combine and deduplicate
        var topics = Set<String>()
        topics.formUnion(entities.map { $0.0 })
        topics.formUnion(keywords.map { $0.0 })
        
        return Array(topics).prefix(8).map { $0 }
    }
    
    private func calculateComplexityScore(metrics: DocumentMetrics) -> Double {
        var score = 0.0
        
        // Factor in sentence length
        if metrics.averageSentenceLength > 20 {
            score += 0.3
        } else if metrics.averageSentenceLength > 15 {
            score += 0.2
        }
        
        // Factor in technical density
        score += metrics.technicalDensity * 0.4
        
        // Factor in lexical diversity
        if metrics.lexicalDiversity > 0.6 {
            score += 0.2
        }
        
        // Inverse readability contributes to complexity
        score += (1.0 - metrics.readabilityScore) * 0.1
        
        return min(1.0, max(0.0, score))
    }
}

// MARK: - Supporting Components

actor NLPProcessor {
    private let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass, .lemma])
    
    func extractNamedEntities(from text: String) async -> [(String, NLTag)] {
        var entities: [(String, NLTag)] = []
        
        tagger.string = text
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let range = text.startIndex..<text.endIndex
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag,
               tag == .personalName || tag == .placeName || tag == .organizationName {
                let entity = String(text[tokenRange])
                entities.append((entity, tag))
            }
            return true
        }
        
        return entities
    }
}

actor NLSentimentAnalyzer {
    private let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    func analyzeSentiment(for text: String) async -> Double {
        tagger.string = text
        
        let (sentimentTag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        guard let tag = sentimentTag,
              let sentimentScore = Double(tag.rawValue) else {
            return 0.0 // Neutral sentiment
        }
        
        // NLTagger returns sentiment scores in range [-1, 1]
        // -1 = most negative, 0 = neutral, 1 = most positive
        return sentimentScore
    }
}

actor KeywordExtractor {
    func extractTopKeywords(from text: String, count: Int) async -> [(String, Int)] {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
            .filter { $0.count > 3 } // Filter out short words
        
        // Count word frequencies
        var wordFrequencies: [String: Int] = [:]
        for word in words {
            wordFrequencies[word, default: 0] += 1
        }
        
        // Filter out common words (simplified stopword list)
        let stopwords = Set(["the", "and", "that", "this", "with", "from", "have", "been", "were", "they", "their", "what", "when", "where", "which", "while", "would", "could", "should", "about", "after", "before", "because", "between", "during", "through", "under", "over"])
        
        let filteredWords = wordFrequencies.filter { !stopwords.contains($0.key) }
        
        // Sort by frequency and return top N
        return Array(filteredWords.sorted { $0.value > $1.value }.prefix(count))
    }
}

struct ImportanceCalculator {
    func calculate(
        features: AIHighlightEngine.TextFeatures,
        mode: AIHighlightEngine.AnalysisMode,
        sentenceIndex: Int,
        totalSentences: Int
    ) -> Double {
        var score = 0.0
        
        // Position importance (beginning and end are more important)
        if features.sentencePosition < 0.2 {
            score += 0.3
        } else if features.sentencePosition > 0.8 {
            score += 0.25
        }
        
        // First and last sentences of paragraphs
        if sentenceIndex == 0 || sentenceIndex == totalSentences - 1 {
            score += 0.2
        }
        
        // Feature-based scoring
        if features.quotationPresent {
            score += 0.15
        }
        
        if features.statisticPresent {
            score += 0.25
        }
        
        if features.namedEntityCount > 0 {
            score += min(0.2, Double(features.namedEntityCount) * 0.05)
        }
        
        if features.transitionWordScore > 0 {
            score += 0.2
        }
        
        // Keyword density contribution
        score += features.keywordDensity * 0.3
        
        // Emphasis contribution
        score += features.emphasisScore * 0.15
        
        // Technical term contribution
        if features.technicalTermCount > 0 {
            score += min(0.15, Double(features.technicalTermCount) * 0.05)
        }
        
        // Readability bonus
        score += features.readabilityScore * 0.1
        
        // Uniqueness bonus
        if features.uniqueWordRatio > 0.7 {
            score += 0.1
        }
        
        // Normalize score
        return min(1.0, max(0.0, score))
    }
}