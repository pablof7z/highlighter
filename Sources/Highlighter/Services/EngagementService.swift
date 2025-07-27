import Foundation
import NDKSwift

/// Service for tracking real engagement metrics from Nostr events
@MainActor
class EngagementService: ObservableObject {
    private weak var ndk: NDK?
    private var signer: NDKSigner?
    
    // MARK: - Engagement Models
    
    struct EngagementMetrics {
        var likes: Int = 0
        var reposts: Int = 0
        var zaps: Int = 0
        var zapAmount: Int = 0
        var comments: Int = 0
        
        var totalEngagement: Int {
            likes + reposts + comments + (zaps > 0 ? 1 : 0)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
    }
    
    // MARK: - Fetch Engagement
    
    /// Fetch engagement metrics for a specific event
    func fetchEngagement(for eventId: String) async -> EngagementMetrics {
        guard let ndk = ndk else { return EngagementMetrics() }
        
        var metrics = EngagementMetrics()
        
        // Fetch reactions (kind 7)
        let reactionFilter = NDKFilter(
            kinds: [7],
            tags: ["e": Set([eventId])]
        )
        
        // Fetch reposts (kind 6)
        let repostFilter = NDKFilter(
            kinds: [6],
            tags: ["e": Set([eventId])]
        )
        
        // Fetch zaps (kind 9735)
        let zapFilter = NDKFilter(
            kinds: [9735],
            tags: ["e": Set([eventId])]
        )
        
        // Fetch replies (kind 1 with 'e' tag referencing this event)
        let replyFilter = NDKFilter(
            kinds: [1],
            tags: ["e": Set([eventId])]
        )
        
        // Fetch all engagement data in parallel
        await withTaskGroup(of: Void.self) { group in
            // Fetch reactions
            group.addTask {
                let reactionSource = await ndk.outbox.observe(
                    filter: reactionFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in reactionSource.events {
                    await MainActor.run {
                        // Only count positive reactions ('+' or likes)
                        if event.content == "+" || event.content == "❤️" || event.content == "👍" {
                            metrics.likes += 1
                        }
                    }
                }
            }
            
            // Fetch reposts
            group.addTask {
                let repostSource = await ndk.outbox.observe(
                    filter: repostFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await _ in repostSource.events {
                    await MainActor.run {
                        metrics.reposts += 1
                    }
                }
            }
            
            // Fetch zaps
            group.addTask {
                let zapSource = await ndk.outbox.observe(
                    filter: zapFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in zapSource.events {
                    await MainActor.run {
                        metrics.zaps += 1
                        
                        // Parse zap amount from bolt11 invoice
                        if let bolt11Tag = event.tags.first(where: { $0.count >= 2 && $0[0] == "bolt11" }),
                           let invoice = bolt11Tag[safe: 1] {
                            let amount = parseBolt11Amount(invoice) ?? 1000
                            metrics.zapAmount += amount
                        } else {
                            // Fallback to 1000 sats if no bolt11 tag
                            metrics.zapAmount += 1000
                        }
                    }
                }
            }
            
            // Fetch comments/replies
            group.addTask {
                let replySource = await ndk.outbox.observe(
                    filter: replyFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in replySource.events {
                    // Check if this is a root reply (not a reply to a reply)
                    let eTags = event.tags.filter { $0.first == "e" }
                    if eTags.count == 1 || (eTags.count > 1 && eTags.first?[safe: 1] == eventId) {
                        await MainActor.run {
                            metrics.comments += 1
                        }
                    }
                }
            }
        }
        
        return metrics
    }
    
    // MARK: - Batch Fetch
    
    /// Fetch engagement metrics for multiple events efficiently
    func fetchEngagementBatch(for eventIds: [String]) async -> [String: EngagementMetrics] {
        guard let ndk = ndk, !eventIds.isEmpty else { return [:] }
        
        var metricsMap: [String: EngagementMetrics] = [:]
        
        // Initialize metrics for all events
        for eventId in eventIds {
            metricsMap[eventId] = EngagementMetrics()
        }
        
        // Create filters for batch fetching
        let eventIdSet = Set(eventIds)
        
        let reactionFilter = NDKFilter(
            kinds: [7],
            tags: ["e": eventIdSet]
        )
        
        let repostFilter = NDKFilter(
            kinds: [6],
            tags: ["e": eventIdSet]
        )
        
        let zapFilter = NDKFilter(
            kinds: [9735],
            tags: ["e": eventIdSet]
        )
        
        let replyFilter = NDKFilter(
            kinds: [1],
            tags: ["e": eventIdSet]
        )
        
        // Fetch all engagement data
        await withTaskGroup(of: Void.self) { group in
            // Reactions
            group.addTask {
                let source = await ndk.outbox.observe(
                    filter: reactionFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in source.events {
                    if let eTag = event.tags.first(where: { $0.first == "e" })?[safe: 1],
                       eventIdSet.contains(eTag),
                       event.content == "+" || event.content == "❤️" || event.content == "👍" {
                        await MainActor.run {
                            metricsMap[eTag]?.likes += 1
                        }
                    }
                }
            }
            
            // Reposts
            group.addTask {
                let source = await ndk.outbox.observe(
                    filter: repostFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in source.events {
                    if let eTag = event.tags.first(where: { $0.first == "e" })?[safe: 1],
                       eventIdSet.contains(eTag) {
                        await MainActor.run {
                            metricsMap[eTag]?.reposts += 1
                        }
                    }
                }
            }
            
            // Zaps
            group.addTask {
                let source = await ndk.outbox.observe(
                    filter: zapFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in source.events {
                    if let eTag = event.tags.first(where: { $0.first == "e" })?[safe: 1],
                       eventIdSet.contains(eTag) {
                        await MainActor.run {
                            metricsMap[eTag]?.zaps += 1
                            
                            // Parse zap amount from bolt11 invoice
                            if let bolt11Tag = event.tags.first(where: { $0.count >= 2 && $0[0] == "bolt11" }),
                               let invoice = bolt11Tag[safe: 1] {
                                let amount = parseBolt11Amount(invoice) ?? 1000
                                metricsMap[eTag]?.zapAmount += amount
                            } else {
                                // Fallback to 1000 sats if no bolt11 tag
                                metricsMap[eTag]?.zapAmount += 1000
                            }
                        }
                    }
                }
            }
            
            // Comments
            group.addTask {
                let source = await ndk.outbox.observe(
                    filter: replyFilter,
                    maxAge: CachePolicies.shortTerm,
                    cachePolicy: .cacheOnly
                )
                
                for await event in source.events {
                    let eTags = event.tags.filter { $0.first == "e" }
                    if let firstETag = eTags.first?[safe: 1],
                       eventIdSet.contains(firstETag),
                       eTags.count == 1 || eTags.first?[safe: 1] == firstETag {
                        await MainActor.run {
                            metricsMap[firstETag]?.comments += 1
                        }
                    }
                }
            }
        }
        
        return metricsMap
    }
    
    // MARK: - User Actions
    
    /// React to an event (like)
    func react(to eventId: String, reaction: String = "+") async throws {
        guard let ndk = ndk, let signer = signer else {
            throw EngagementError.notConfigured
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(7)
            .content(reaction)
            .tags([["e", eventId]])
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
    }
    
    /// Repost an event
    func repost(eventId: String, pubkey: String) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw EngagementError.notConfigured
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(6)
            .content("")
            .tags([["e", eventId], ["p", pubkey]])
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
    }
    
    /// Comment on an event
    func comment(on eventId: String, content: String, author: String? = nil) async throws {
        guard let ndk = ndk, let signer = signer else {
            throw EngagementError.notConfigured
        }
        
        var tags = [["e", eventId, "", "root"]]
        
        if let author = author {
            tags.append(["p", author])
        }
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(1)
            .content(content)
            .tags(tags)
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
    }
}

// MARK: - Errors

enum EngagementError: LocalizedError {
    case notConfigured
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Engagement service not properly configured"
        }
    }
}

// MARK: - Bolt11 Parsing

private func parseBolt11Amount(_ invoice: String) -> Int? {
    // Enhanced bolt11 parsing with better error handling and edge case support
    // Bolt11 format: ln[tb]c<amount><multiplier>1<bech32data>
    // where multiplier can be m (milli), u (micro), n (nano), p (pico)
    
    let invoice = invoice.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Support various network prefixes
    let prefixes = ["lnbc", "lntb", "lnbcrt", "lnsb", "lntbs"]
    var matchedPrefix: String?
    
    for prefix in prefixes {
        if invoice.hasPrefix(prefix) {
            matchedPrefix = prefix
            break
        }
    }
    
    guard let prefix = matchedPrefix else {
        return nil
    }
    
    // Remove the prefix
    let withoutPrefix = String(invoice.dropFirst(prefix.count))
    
    // Handle edge case: invoice without amount (0-value invoices)
    if withoutPrefix.isEmpty || withoutPrefix.first == "1" {
        return 0
    }
    
    // Extract amount and multiplier
    var amountString = ""
    var multiplierChar: Character?
    var foundMultiplier = false
    
    for (index, char) in withoutPrefix.enumerated() {
        if char.isNumber && !foundMultiplier {
            amountString.append(char)
        } else if ["m", "u", "n", "p"].contains(char) && !foundMultiplier {
            multiplierChar = char
            foundMultiplier = true
            // Check if there are more digits after multiplier (invalid format)
            if index + 1 < withoutPrefix.count {
                let nextChar = withoutPrefix[withoutPrefix.index(withoutPrefix.startIndex, offsetBy: index + 1)]
                if nextChar.isNumber {
                    return nil // Invalid format
                }
            }
        } else if char == "1" || (!char.isNumber && !char.isLetter) {
            // Hit the bech32 separator or invalid character
            break
        } else if !foundMultiplier && char.isLetter {
            // Letter that's not a multiplier - invalid
            return nil
        }
    }
    
    // Handle case where amount is specified but no digits found
    if amountString.isEmpty && multiplierChar != nil {
        return nil
    }
    
    // Parse amount with better error handling
    let amount: Int64
    if amountString.isEmpty {
        // No amount specified means 0
        amount = 0
    } else {
        guard let parsedAmount = Int64(amountString), parsedAmount >= 0 else {
            return nil
        }
        amount = parsedAmount
    }
    
    // Convert to satoshis based on multiplier with overflow protection
    let satoshis: Int64
    switch multiplierChar {
    case "m": // milli-bitcoin (0.001 BTC)
        satoshis = amount.multipliedReportingOverflow(by: 100_000).partialValue
    case "u": // micro-bitcoin (0.000001 BTC)  
        satoshis = amount.multipliedReportingOverflow(by: 100).partialValue
    case "n": // nano-bitcoin (0.000000001 BTC)
        // Ensure we don't lose precision with integer division
        satoshis = amount % 10 == 0 ? amount / 10 : (amount * 10) / 100
    case "p": // pico-bitcoin (0.000000000001 BTC)
        // Most pico amounts will be 0 satoshis due to rounding
        satoshis = amount / 10_000
    default: // No multiplier means BTC
        if amountString.isEmpty {
            return 0 // Empty amount with no multiplier
        }
        satoshis = amount.multipliedReportingOverflow(by: 100_000_000).partialValue
    }
    
    // Ensure result fits in Int and is reasonable
    guard satoshis >= 0 && satoshis <= Int64(Int.max) else {
        return nil
    }
    
    return Int(satoshis)
}

