import Foundation
import NDKSwift

struct SwarmHighlight: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let range: NSRange
    let highlights: [HighlightInfo]
    
    static func == (lhs: SwarmHighlight, rhs: SwarmHighlight) -> Bool {
        lhs.id == rhs.id
    }
    
    var totalZaps: Int {
        highlights.reduce(0) { $0 + $1.zapCount }
    }
    
    var totalHighlighters: Int {
        highlights.count
    }
    
    var intensity: Double {
        // Constants for intensity calculation
        let highlighterDivisor = 10.0  // Each 10 highlighters = 1.0 base intensity
        let zapDivisor = 100.0         // Each 100 zaps = 1.0 zap boost
        let maxIntensity = 1.0         // Maximum intensity value
        
        let baseIntensity = Double(totalHighlighters) / highlighterDivisor
        let zapBoost = Double(totalZaps) / zapDivisor
        return min(baseIntensity + zapBoost, maxIntensity)
    }
    
    struct HighlightInfo: Identifiable {
        let id = UUID()
        let event: NDKEvent
        let author: NDKUser
        let profile: NDKUserProfile?
        let note: String?
        let createdAt: Date
        let zapCount: Int
    }
}

class SwarmHighlightManager: ObservableObject {
    @Published var swarmHighlights: [SwarmHighlight] = []
    @Published var isLoading = false
    
    var ndk: NDK
    private var dataSource: NDKDataSource<NDKEvent>?
    
    init(ndk: NDK) {
        self.ndk = ndk
    }
    
    func loadSwarmHighlights(for articleURL: String? = nil, articleEvent: String? = nil) {
        isLoading = true
        swarmHighlights = []
        
        Task {
            var tagsDict: [String: Set<String>] = [:]
            if let url = articleURL {
                tagsDict["r"] = [url]
            } else if let eventId = articleEvent {
                tagsDict["e"] = [eventId]
            }
            
            let filter = NDKFilter(
                kinds: [9802], // NIP-84 highlights
                limit: 100,
                tags: tagsDict.isEmpty ? nil : tagsDict
            )
            
            dataSource = await ndk.outbox.observe(filter: filter, maxAge: 3600, cachePolicy: .cacheWithNetwork)
            
            var highlightEvents: [NDKEvent] = []
            
            for await event in dataSource!.events {
                highlightEvents.append(event)
                await processHighlights(highlightEvents)
            }
        }
    }
    
    @MainActor
    private func processHighlights(_ events: [NDKEvent]) async {
        var highlightsByText: [String: [SwarmHighlight.HighlightInfo]] = [:]
        
        for event in events {
            let content = event.content
            guard !content.isEmpty else { continue }
            
            // Use streaming observe API to get the profile
            var profile: NDKUserProfile?
            for await p in await ndk.profileManager.observe(for: event.pubkey, maxAge: TimeConstants.hour) {
                profile = p
                break // Just get the first result
            }
            let zapCount = await fetchZapCount(for: event.id)
            
            let info = SwarmHighlight.HighlightInfo(
                event: event,
                author: NDKUser(pubkey: event.pubkey),
                profile: profile,
                note: event.tags.first(where: { $0.count > 1 && $0[0] == "comment" })?.dropFirst().joined(separator: " "),
                createdAt: Date(timeIntervalSince1970: TimeInterval(event.createdAt)),
                zapCount: zapCount
            )
            
            if highlightsByText[content] != nil {
                highlightsByText[content]?.append(info)
            } else {
                highlightsByText[content] = [info]
            }
        }
        
        swarmHighlights = highlightsByText.map { text, infos in
            SwarmHighlight(
                text: text,
                range: NSRange(location: 0, length: text.count),
                highlights: infos.sorted { $0.createdAt < $1.createdAt }
            )
        }.sorted { $0.totalHighlighters > $1.totalHighlighters }
        
        isLoading = false
    }
    
    private func fetchZapCount(for eventId: String) async -> Int {
        let filter = NDKFilter(
            kinds: [9735],
            events: [eventId],
            limit: 1000
        )
        
        let dataSource = await ndk.outbox.observe(filter: filter, maxAge: 3600, cachePolicy: .cacheWithNetwork)
        var count = 0
        // Limit zap count to prevent excessive API calls
        let maxZapCount = 100
        
        for await _ in dataSource.events {
            count += 1
            if count > maxZapCount { break }
        }
        return count
    }
    
    func findOverlappingHighlights(in text: String) -> [(range: NSRange, highlight: SwarmHighlight)] {
        var results: [(NSRange, SwarmHighlight)] = []
        
        for highlight in swarmHighlights {
            if let range = text.range(of: highlight.text) {
                let nsRange = NSRange(range, in: text)
                results.append((nsRange, highlight))
            }
        }
        
        return results
    }
}