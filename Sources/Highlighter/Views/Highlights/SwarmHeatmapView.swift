import SwiftUI
import NDKSwift

struct SwarmHeatmapView: View {
    let articleId: String
    let content: String
    @StateObject private var heatmapData = SwarmHeatmapData()
    @State private var hoveredRange: NSRange?
    @State private var selectedRange: NSRange?
    @State private var showTooltip = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var particlePositions: [ParticlePosition] = []
    @State private var isShowingHighlightCreation = false
    @State private var showingZapAllConfirmation = false
    @State private var selectedTextForHighlight = ""
    @EnvironmentObject var appState: AppState
    @Namespace private var animation
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Base text with heatmap overlay
                HeatmapTextView(
                    content: content,
                    heatmapData: heatmapData,
                    hoveredRange: $hoveredRange,
                    selectedRange: $selectedRange,
                    geometry: geometry
                )
                
                // Particle effects layer
                ParticleLayer(particles: $particlePositions)
                    .allowsHitTesting(false)
                
                // Interactive tooltip
                if showTooltip, let range = selectedRange {
                    SwarmTooltipView(
                        range: range,
                        heatmapData: heatmapData,
                        position: tooltipPosition,
                        onZap: { userId in
                            HapticManager.shared.impact(.light)
                            zapHighlighter(userId: userId)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
                    .zIndex(100)
                }
            }
            .onAppear {
                startHeatmapUpdates()
                startParticleAnimation()
            }
        }
        .background(Color.ds.background)
        .sheet(isPresented: $isShowingHighlightCreation) {
            CreateHighlightView()
                .environmentObject(appState)
        }
        .alert("Zap All Highlighters", isPresented: $showingZapAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Zap All") {
                Task {
                    await zapAllHighlighters()
                }
            }
        } message: {
            Text("Send \(heatmapData.getHighlighters(for: selectedRange ?? NSRange()).count * 21) sats total (21 sats to each highlighter)?")
        }
    }
    
    private func startHeatmapUpdates() {
        Task {
            await heatmapData.startStreaming(articleId: articleId)
        }
    }
    
    private func startParticleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updateParticles() {
        // Add new particles for active highlights
        for highlight in heatmapData.activeHighlights {
            if Double.random(in: 0...1) < 0.3 { // 30% chance
                let position = calculateParticlePosition(for: highlight.range)
                particlePositions.append(ParticlePosition(
                    id: UUID(),
                    start: position,
                    end: position.applying(.init(translationX: .random(in: -50...50), y: -100)),
                    startTime: Date()
                ))
            }
        }
        
        // Remove old particles
        particlePositions.removeAll { particle in
            Date().timeIntervalSince(particle.startTime) > 2.0
        }
    }
    
    private func calculateParticlePosition(for range: NSRange) -> CGPoint {
        // Calculate position based on text range
        CGPoint(x: 100, y: 100) // Simplified - would calculate actual text position
    }
    
    private func zapHighlighter(userId: String) {
        Task {
            // Default small zap amount is 21 sats
            // Would integrate with LightningService to send zap
            HapticManager.shared.notification(.success)
        }
    }
    
    private func zapAllHighlighters() async {
        let highlighters = heatmapData.getHighlighters(for: selectedRange ?? NSRange())
        for _ in highlighters {
            // Would integrate with LightningService to send zaps
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay between zaps
        }
        HapticManager.shared.notification(.success)
    }
}

// MARK: - Heatmap Text View
struct HeatmapTextView: UIViewRepresentable {
    let content: String
    let heatmapData: SwarmHeatmapData
    @Binding var hoveredRange: NSRange?
    @Binding var selectedRange: NSRange?
    let geometry: GeometryProxy
    
    func makeUIView(context: Context) -> HeatmapTextUIView {
        let view = HeatmapTextUIView()
        view.isEditable = false
        view.isSelectable = false
        view.backgroundColor = .clear
        view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return view
    }
    
    func updateUIView(_ uiView: HeatmapTextUIView, context: Context) {
        let attributedString = createHeatmapAttributedString()
        uiView.attributedText = attributedString
        uiView.heatmapData = heatmapData
        uiView.setNeedsDisplay()
    }
    
    private func createHeatmapAttributedString() -> NSAttributedString {
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        
        let attributedString = NSMutableAttributedString(string: content, attributes: baseAttributes)
        
        // Apply heatmap styling
        for highlight in heatmapData.highlights {
            let intensity = min(highlight.intensity, 1.0)
            let backgroundColor = UIColor.systemOrange.withAlphaComponent(intensity * 0.3)
            
            attributedString.addAttributes([
                .backgroundColor: backgroundColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.systemOrange.withAlphaComponent(intensity)
            ], range: highlight.range)
        }
        
        return attributedString
    }
}

// MARK: - Custom Text View with Heatmap Drawing
class HeatmapTextUIView: UITextView {
    var heatmapData: SwarmHeatmapData?
    private var heatmapLayer: CAGradientLayer?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawHeatmapOverlay()
    }
    
    private func drawHeatmapOverlay() {
        guard let heatmapData = heatmapData,
              let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // Draw heat zones with gradient effects
        for highlight in heatmapData.highlights {
            let rects = getRects(for: highlight.range)
            
            for rect in rects {
                let expandedRect = rect.insetBy(dx: -4, dy: -2)
                let intensity = min(highlight.intensity, 1.0)
                
                // Create gradient
                let colors = [
                    UIColor.systemOrange.withAlphaComponent(0).cgColor,
                    UIColor.systemOrange.withAlphaComponent(intensity * 0.4).cgColor,
                    UIColor.systemOrange.withAlphaComponent(0).cgColor
                ]
                
                let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: [0, 0.5, 1])!
                
                let path = UIBezierPath(roundedRect: expandedRect, cornerRadius: 4)
                context.addPath(path.cgPath)
                context.clip()
                
                context.drawLinearGradient(gradient,
                                         start: CGPoint(x: expandedRect.minX, y: expandedRect.midY),
                                         end: CGPoint(x: expandedRect.maxX, y: expandedRect.midY),
                                         options: [])
                
                context.resetClip()
            }
        }
        
        context.restoreGState()
    }
    
    private func getRects(for range: NSRange) -> [CGRect] {
        let layoutManager = layoutManager
        let textContainer = textContainer
        
        var rects: [CGRect] = []
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        
        layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange,
                                            withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                                            in: textContainer) { rect, _ in
            rects.append(rect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top))
        }
        
        return rects
    }
}

// MARK: - Particle Effects
struct ParticleLayer: View {
    @Binding var particles: [ParticlePosition]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                HeatmapParticleView(particle: particle)
            }
        }
    }
}

struct HeatmapParticleView: View {
    let particle: ParticlePosition
    @State private var opacity: Double = 1.0
    @State private var scale: Double = 0.5
    @State private var position: CGPoint
    
    init(particle: ParticlePosition) {
        self.particle = particle
        self._position = State(initialValue: particle.start)
    }
    
    var body: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color.ds.primary, Color.ds.primary.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(width: 6, height: 6)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 2)) {
                    position = particle.end
                    opacity = 0
                    scale = 1.5
                }
            }
    }
}

// MARK: - Tooltip View
struct SwarmTooltipView: View {
    let range: NSRange
    let heatmapData: SwarmHeatmapData
    let position: CGPoint
    let onZap: (String) -> Void
    @State private var isShowingHighlightCreation = false
    @State private var showingZapAllConfirmation = false
    
    var highlighters: [HighlighterInfo] {
        heatmapData.getHighlighters(for: range)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.ds.primary)
                
                Text("\(highlighters.count) highlights")
                    .font(.ds.caption)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(totalZaps) zaps")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
            
            // User avatars
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -8) {
                    ForEach(highlighters.prefix(10)) { highlighter in
                        HighlighterAvatarView(
                            highlighter: highlighter,
                            onTap: {
                                onZap(highlighter.id)
                            }
                        )
                    }
                    
                    if highlighters.count > 10 {
                        Text("+\(highlighters.count - 10)")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.ds.surfaceSecondary)
                            .clipShape(Capsule())
                            .padding(.leading, 8)
                    }
                }
            }
            
            // Quick actions
            HStack(spacing: 12) {
                Button(action: { addHighlight() }) {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.ds.caption)
                }
                .buttonStyle(MicroButtonStyle())
                
                Button(action: { zapAll() }) {
                    Label("Zap All", systemImage: "bolt.fill")
                        .font(.ds.caption)
                }
                .buttonStyle(MicroButtonStyle(isPrimary: true))
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.ds.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .position(position)
    }
    
    private var totalZaps: Int {
        highlighters.reduce(0) { $0 + $1.zapCount }
    }
    
    private func addHighlight() {
        HapticManager.shared.impact(.medium)
        isShowingHighlightCreation = true
    }
    
    private func zapAll() {
        HapticManager.shared.impact(.heavy)
        showingZapAllConfirmation = true
    }
}

// MARK: - Highlighter Avatar
struct HighlighterAvatarView: View {
    let highlighter: HighlighterInfo
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Avatar
                Circle()
                    .fill(Color.ds.surfaceSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(highlighter.name.prefix(2).uppercased())
                            .font(.ds.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.ds.primary)
                    )
                
                // Zap indicator
                if highlighter.zapCount > 0 {
                    Text("⚡️")
                        .font(.system(size: 10))
                        .offset(x: 14, y: -14)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity,
                           pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Supporting Types
struct ParticlePosition: Identifiable {
    let id: UUID
    let start: CGPoint
    let end: CGPoint
    let startTime: Date
}

struct HighlighterInfo: Identifiable, Equatable {
    let id: String
    let name: String
    let zapCount: Int
    let timestamp: Date
}

// MARK: - Heatmap Data Manager
@MainActor
class SwarmHeatmapData: ObservableObject {
    @Published var highlights: [HeatmapHighlight] = []
    @Published var activeHighlights: [HeatmapHighlight] = []
    private var dataSource: NDKDataSource<NDKEvent>?
    
    struct HeatmapHighlight {
        let id: String
        let range: NSRange
        let intensity: Double
        let users: [String]
        let timestamp: Date
    }
    
    func startStreaming(articleId: String) async {
        // Create filter for kind 9802 (highlights) with article reference
        // let filter = NDKFilter(
        //     kinds: [9802],
        //     tags: ["r": [articleId]]
        // )
        
        // Need to get NDK instance from AppState
        // dataSource = ndk.observe(filter: filter)
        
        // Stream highlights
        guard let events = dataSource?.events else { return }
        
        for await event in events {
            processHighlightEvent(event)
        }
    }
    
    private func processHighlightEvent(_ event: NDKEvent) {
        // Process incoming highlight events and update heatmap
        // let content = event.content
        guard let range = extractRange(from: event) else { return }
        
        withAnimation(.spring(response: 0.5)) {
            // Update or add highlight
            if let index = highlights.firstIndex(where: { $0.range == range }) {
                let highlight = highlights[index]
                let newUsers = highlight.users + [event.pubkey]
                let newIntensity = min(Double(newUsers.count) / 10.0, 1.0)
                
                highlights[index] = HeatmapHighlight(
                    id: highlight.id,
                    range: range,
                    intensity: newIntensity,
                    users: Array(Set(newUsers)),
                    timestamp: Date()
                )
            } else {
                let newHighlight = HeatmapHighlight(
                    id: event.id,
                    range: range,
                    intensity: 0.1,
                    users: [event.pubkey],
                    timestamp: Date()
                )
                highlights.append(newHighlight)
                
                // Mark as active for particle effects
                activeHighlights.append(newHighlight)
                
                // Remove from active after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.activeHighlights.removeAll { $0.id == newHighlight.id }
                }
            }
        }
    }
    
    private func extractRange(from event: NDKEvent) -> NSRange? {
        // Extract range from event tags
        // Simplified implementation
        return NSRange(location: 100, length: 50)
    }
    
    func getHighlighters(for range: NSRange) -> [HighlighterInfo] {
        // Get all users who highlighted this range
        highlights
            .filter { $0.range.intersection(range) != nil }
            .flatMap { highlight in
                highlight.users.map { userId in
                    HighlighterInfo(
                        id: userId,
                        name: "User", // Would fetch actual name
                        zapCount: Int.random(in: 0...10),
                        timestamp: highlight.timestamp
                    )
                }
            }
            .removingDuplicates()
    }
}

// MARK: - Micro Button Style
struct MicroButtonStyle: ButtonStyle {
    var isPrimary = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPrimary ? Color.ds.primary : Color.ds.surfaceSecondary)
            )
            .foregroundColor(isPrimary ? .white : .ds.text)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Extensions
extension NSRange {
    func intersection(_ other: NSRange) -> NSRange? {
        let intersection = NSIntersectionRange(self, other)
        return intersection.length > 0 ? intersection : nil
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
}