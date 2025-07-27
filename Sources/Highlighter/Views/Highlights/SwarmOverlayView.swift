import SwiftUI
import NDKSwift

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}

struct SwarmOverlayView: View {
    let text: String
    @ObservedObject var swarmManager: SwarmHighlightManager
    @State private var selectedHighlight: SwarmHighlight?
    @State private var popoverPosition: CGPoint = .zero
    @State private var glowAnimation = false
    @State private var particlePositions: [SwarmParticlePosition] = []
    @State private var heatmapOpacity: Double = 0
    @State private var newHighlightAnimation: [String: Bool] = [:]
    @State private var liveActivityPulse = false
    @State private var swarmActivityLevel: Double = 0
    @State private var gestureOffset: CGSize = .zero
    @State private var dragVelocity: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var activeHighlightIndex = 0
    @State private var cosmicParticles: [CosmicParticle] = []
    @State private var rippleEffects: [SwarmRippleEffect] = []
    @State private var highlightPath = Path()
    @State private var pathAnimation: CGFloat = 0
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Cosmic background layer
                CosmicBackgroundView(
                    particles: cosmicParticles,
                    activityLevel: swarmActivityLevel
                )
                .allowsHitTesting(false)
                .blur(radius: 3)
                
                // Live activity indicator
                LiveSwarmActivityIndicator(
                    activityLevel: swarmActivityLevel,
                    isPulsing: liveActivityPulse
                )
                .position(x: geometry.size.width - 40, y: 40)
                .allowsHitTesting(false)
                
                // Ripple effects layer
                ForEach(rippleEffects) { ripple in
                    SwarmRippleEffectView(ripple: ripple)
                }
                .allowsHitTesting(false)
                
                // Heatmap overlay layer with enhanced effects
                SwarmHeatmapOverlay(
                    text: text,
                    swarmHighlights: swarmManager.findOverlappingHighlights(in: text),
                    opacity: heatmapOpacity
                )
                .allowsHitTesting(false)
                .blur(radius: 6 + (swarmActivityLevel * 4))
                .scaleEffect(1 + (swarmActivityLevel * 0.05))
                
                // Connection paths between highlights
                if highlightPath.isEmpty == false {
                    highlightPath
                        .trim(from: 0, to: pathAnimation)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .orange.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 3])
                        )
                        .blur(radius: 1)
                        .allowsHitTesting(false)
                }
                
                // Main text view with highlights
                SwarmTextView(
                    text: text,
                    swarmHighlights: swarmManager.findOverlappingHighlights(in: text),
                    selectedHighlight: $selectedHighlight,
                    popoverPosition: $popoverPosition,
                    geometry: geometry,
                    newHighlightAnimation: $newHighlightAnimation
                )
                .offset(gestureOffset)
                .scaleEffect(1 - abs(gestureOffset.width) / 1000)
                .rotation3DEffect(
                    .degrees(Double(gestureOffset.width / 10)),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                
                // Particle effects layer with physics
                ForEach(particlePositions) { particle in
                    ParticleView(particle: particle)
                        .offset(
                            x: dragVelocity.width * 0.3,
                            y: dragVelocity.height * 0.3
                        )
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        gestureOffset = value.translation
                        dragVelocity = CGSize(
                            width: value.velocity.width / 50,
                            height: value.velocity.height / 50
                        )
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            gestureOffset = .zero
                            dragVelocity = .zero
                        }
                    }
            )
        }
        .overlay(alignment: .topLeading) {
            if let highlight = selectedHighlight {
                SwarmPopover(
                    highlight: highlight,
                    position: popoverPosition,
                    onDismiss: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedHighlight = nil
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .zIndex(1000)
            }
        }
        .onAppear {
            startAnimations()
            generateParticles()
            generateCosmicParticles()
            calculateHighlightPaths()
        }
        .onChange(of: swarmManager.swarmHighlights) { oldValue, newValue in
            animateNewHighlights(oldValue: oldValue, newValue: newValue)
            updateSwarmActivity(oldCount: oldValue.count, newCount: newValue.count)
            calculateHighlightPaths()
        }
        .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
            simulateLiveActivity()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowAnimation = true
        }
        
        withAnimation(.easeIn(duration: 1)) {
            heatmapOpacity = 0.6
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            liveActivityPulse = true
        }
        
        withAnimation(.linear(duration: 3).delay(0.5)) {
            pathAnimation = 1.0
        }
    }
    
    private func generateParticles() {
        let highlights = swarmManager.findOverlappingHighlights(in: text)
        for (_, highlight) in highlights.prefix(5) {
            if highlight.intensity > 0.5 {
                for _ in 0..<Int(highlight.intensity * 5) {
                    let particle = SwarmParticlePosition(
                        x: .random(in: 0...UIScreen.main.bounds.width),
                        y: .random(in: 0...UIScreen.main.bounds.height),
                        scale: .random(in: 0.5...1.5),
                        opacity: .random(in: 0.3...0.8)
                    )
                    particlePositions.append(particle)
                }
            }
        }
    }
    
    private func generateCosmicParticles() {
        for _ in 0..<20 {
            let particle = CosmicParticle(
                x: .random(in: -50...UIScreen.main.bounds.width + 50),
                y: .random(in: -50...UIScreen.main.bounds.height + 50),
                size: .random(in: 2...6),
                speed: .random(in: 10...30),
                angle: .random(in: 0...360)
            )
            cosmicParticles.append(particle)
        }
    }
    
    private func calculateHighlightPaths() {
        let highlights = swarmManager.findOverlappingHighlights(in: text)
        guard highlights.count > 1 else { return }
        
        highlightPath = Path { path in
            for i in 0..<highlights.count - 1 {
                let start = CGPoint(x: CGFloat(highlights[i].range.location) * 10, y: 50)
                let end = CGPoint(x: CGFloat(highlights[i + 1].range.location) * 10, y: 50)
                let control = CGPoint(
                    x: (start.x + end.x) / 2,
                    y: 50 - CGFloat.random(in: 20...50)
                )
                
                path.move(to: start)
                path.addQuadCurve(to: end, control: control)
            }
        }
    }
    
    private func animateNewHighlights(oldValue: [SwarmHighlight], newValue: [SwarmHighlight]) {
        let newIds = Set(newValue.map { $0.id })
        let oldIds = Set(oldValue.map { $0.id })
        let addedIds = newIds.subtracting(oldIds)
        
        for id in addedIds {
            newHighlightAnimation[id.uuidString] = false
            
            // Create ripple effect at highlight location
            if let highlight = newValue.first(where: { $0.id.uuidString == id.uuidString }) {
                let ripple = SwarmRippleEffect(
                    x: CGFloat(highlight.range.location) * 10,
                    y: 50
                )
                rippleEffects.append(ripple)
                
                // Remove ripple after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    rippleEffects.removeAll { $0.id == ripple.id }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    newHighlightAnimation[id.uuidString] = true
                }
            }
        }
    }
    
    private func updateSwarmActivity(oldCount: Int, newCount: Int) {
        if newCount > oldCount {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                swarmActivityLevel = min(1.0, swarmActivityLevel + 0.2)
            }
            
            // Decay activity over time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 1)) {
                    swarmActivityLevel = max(0, swarmActivityLevel - 0.1)
                }
            }
            
            HapticManager.shared.impact(.light)
        }
    }
    
    private func simulateLiveActivity() {
        // Only show subtle activity hint when there's no real activity
        // This helps users understand the feature is working even with low activity
        let hasRealActivity = !swarmManager.swarmHighlights.isEmpty
        let shouldSimulate = !hasRealActivity && Bool.random(probability: 0.2) // 20% chance
        
        if shouldSimulate && swarmActivityLevel == 0 {
            withAnimation(.easeInOut(duration: 1.0)) {
                swarmActivityLevel = .random(in: 0.1...0.2) // Very subtle
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 1.5)) {
                    swarmActivityLevel = 0
                }
            }
            
            // Add subtle ripple effect
            let ripple = SwarmRippleEffect(
                x: .random(in: 100...300),
                y: .random(in: 100...400)
            )
            rippleEffects.append(ripple)
            
            // Remove ripple after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                rippleEffects.removeAll { $0.id == ripple.id }
            }
        }
    }
}

// New Heatmap Visualization Component
struct SwarmHeatmapOverlay: View {
    let text: String
    let swarmHighlights: [(range: NSRange, highlight: SwarmHighlight)]
    let opacity: Double
    
    var body: some View {
        Canvas { context, size in
            guard !text.isEmpty else { return }
            
            for (range, highlight) in swarmHighlights {
                let intensity = highlight.intensity
                
                // Create gradient colors based on intensity
                let startColor = Color.orange.opacity(0.1 * intensity)
                let midColor = Color.orange.opacity(0.3 * intensity)
                let endColor = Color.orange.opacity(0.05 * intensity)
                
                // Create radial gradient
                let gradient = Gradient(colors: [midColor, startColor, endColor])
                let radialGradient = GraphicsContext.Shading.radialGradient(
                    gradient,
                    center: .zero,
                    startRadius: 5,
                    endRadius: 50 * intensity
                )
                
                // Draw gradient overlay (simplified positioning)
                let rect = CGRect(
                    x: CGFloat(range.location) * 10,
                    y: 20,
                    width: CGFloat(range.length) * 10,
                    height: 30
                )
                
                context.fill(
                    RoundedRectangle(cornerRadius: 15).path(in: rect),
                    with: radialGradient
                )
            }
        }
        .opacity(opacity)
        .blur(radius: 8)
        .blendMode(.plusLighter)
    }
}

// Particle Effect Component
struct SwarmParticlePosition: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
}

struct ParticleView: View {
    let particle: SwarmParticlePosition
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.orange.opacity(particle.opacity),
                        Color.orange.opacity(0)
                    ],
                    center: UnitPoint.center,
                    startRadius: 0,
                    endRadius: 5
                )
            )
            .frame(width: 10 * particle.scale, height: 10 * particle.scale)
            .position(x: particle.x + offset.width, y: particle.y + offset.height)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: .random(in: 3...6))
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(
                        width: .random(in: -30...30),
                        height: .random(in: -50...50)
                    )
                    rotation = .random(in: -180...180)
                }
            }
    }
}

struct SwarmTextView: UIViewRepresentable {
    let text: String
    let swarmHighlights: [(range: NSRange, highlight: SwarmHighlight)]
    @Binding var selectedHighlight: SwarmHighlight?
    @Binding var popoverPosition: CGPoint
    let geometry: GeometryProxy
    @Binding var newHighlightAnimation: [String: Bool]
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        let attributedString = NSMutableAttributedString(string: text)
        
        // Base text styling with improved typography
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.paragraphSpacing = 20
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle,
            .kern: 0.2
        ], range: NSRange(location: 0, length: text.count))
        
        // Apply swarm highlights with advanced visual effects
        for (range, highlight) in swarmHighlights {
            let intensity = highlight.intensity
            let isNewHighlight = newHighlightAnimation[highlight.id.uuidString] ?? false
            
            // Dynamic color based on intensity and animation state
            let baseAlpha = isNewHighlight ? 0.8 : 0.3
            let underlineColor = UIColor.systemOrange.withAlphaComponent(baseAlpha + (intensity * 0.7))
            
            // Multi-layer background effect
            let backgroundAlpha = isNewHighlight ? 0.2 : 0.05
            let backgroundColor = UIColor.systemOrange.withAlphaComponent(backgroundAlpha + (intensity * 0.15))
            
            // Apply attributes with animation consideration
            var attributes: [NSAttributedString.Key: Any] = [
                .backgroundColor: backgroundColor,
                .underlineStyle: NSUnderlineStyle.thick.rawValue,
                .underlineColor: underlineColor
            ]
            
            // Add glow effect for high-intensity highlights
            if intensity > 0.7 {
                attributes[.strokeWidth] = -1.0
                attributes[.strokeColor] = UIColor.systemOrange.withAlphaComponent(intensity * 0.5)
            }
            
            // Add shadow for new highlights
            if isNewHighlight {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.systemOrange.withAlphaComponent(0.5)
                shadow.shadowBlurRadius = 8
                shadow.shadowOffset = CGSize(width: 0, height: 2)
                attributes[.shadow] = shadow
            }
            
            attributedString.addAttributes(attributes, range: range)
        }
        
        textView.attributedText = attributedString
        context.coordinator.parent = self
        context.coordinator.highlights = swarmHighlights
        
        // Animate text view content changes
        if !newHighlightAnimation.isEmpty {
            UIView.animate(withDuration: 0.3) {
                textView.alpha = 0.95
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    textView.alpha = 1.0
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SwarmTextView
        var highlights: [(range: NSRange, highlight: SwarmHighlight)] = []
        
        init(_ parent: SwarmTextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Check if tap is on a highlight
            if let tappedHighlight = highlights.first(where: { NSLocationInRange(characterRange.location, $0.range) }) {
                // Calculate popover position
                if let position = textView.position(from: textView.beginningOfDocument, offset: characterRange.location) {
                    let rect = textView.caretRect(for: position)
                    let globalRect = textView.convert(rect, to: nil)
                    
                    DispatchQueue.main.async {
                        self.parent.selectedHighlight = tappedHighlight.highlight
                        self.parent.popoverPosition = CGPoint(
                            x: globalRect.midX,
                            y: globalRect.minY - 10
                        )
                        HapticManager.shared.impact(.light)
                    }
                }
            }
            return false
        }
    }
}

struct SwarmPopover: View {
    let highlight: SwarmHighlight
    let position: CGPoint
    let onDismiss: () -> Void
    @State private var isExpanded = false
    @State private var glowIntensity: Double = 0.5
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var cardFlipRotation: Double = 0
    @State private var showBackSide = false
    @State private var floatingOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Front side of card
            if !showBackSide {
                VStack(spacing: 0) {
                    // Header with stats
                    popoverHeader
                    
                    // Expanded details with staggered animation
                    if isExpanded {
                        expandedContent
                    }
                }
                .frame(maxWidth: 360)
                .background(popoverBackground)
                .overlay(animatedBorderGlow)
                .rotation3DEffect(
                    .degrees(cardFlipRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 1
                )
            }
            
            // Back side of card (detailed analytics)
            if showBackSide {
                SwarmAnalyticsView(highlight: highlight)
                    .frame(maxWidth: 360)
                    .background(popoverBackground)
                    .overlay(animatedBorderGlow)
                    .rotation3DEffect(
                        .degrees(cardFlipRotation + 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 1
                    )
            }
        }
        .scaleEffect(pulseScale)
        .offset(y: floatingOffset)
        .position(x: position.x, y: position.y)
        .onAppear {
            startAnimations()
        }
        .onTapGesture(count: 2) {
            // Double tap to flip card
            flipCard()
        }
        .onTapGesture {
            // Single tap does nothing (prevent dismissal)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { _ in
                    HapticManager.shared.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        onDismiss()
                    }
                }
        )
    }
    
    private func flipCard() {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cardFlipRotation += 180
            showBackSide.toggle()
        }
    }
    
    @ViewBuilder
    private var popoverHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // Stats with animated counters
                statsView
                
                // Quoted text
                Text("\"\(highlight.text)\"")
                    .font(.footnote.italic())
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(0.9)
            }
            
            Spacer()
            
            // Animated expand button
            expandButton
        }
        .padding(16)
        .background(headerBackground)
    }
    
    @ViewBuilder
    private var statsView: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .symbolEffect(.pulse, value: pulseScale)
                AnimatedCounter(value: highlight.totalHighlighters, suffix: " highlighters")
                    .font(.caption.weight(.medium))
            }
            
            if highlight.totalZaps > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .symbolEffect(.bounce, value: pulseScale)
                    AnimatedCounter(value: highlight.totalZaps, suffix: " zaps")
                        .font(.caption.weight(.medium))
                }
            }
        }
    }
    
    @ViewBuilder
    private var expandButton: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
                rotationAngle += 180
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .scaleEffect(pulseScale)
    }
    
    @ViewBuilder
    private var headerBackground: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    colorScheme == .dark ? Color.black : Color.white,
                    colorScheme == .dark ? Color.ds.background.opacity(0.8) : Color.ds.surface.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Intensity-based glow
            RadialGradient(
                colors: [
                    Color.orange.opacity(highlight.intensity * 0.2),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 100
            )
            .opacity(glowIntensity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.5),
                            Color.orange.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(spacing: 8) {
            ForEach(Array(highlight.highlights.enumerated()), id: \.element.id) { index, info in
                SwarmHighlightRow(info: info)
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .trailing)
                                .combined(with: .opacity)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05)),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        )
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private var popoverBackground: some View {
        ZStack {
            // Main background
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.ds.background.opacity(0.95) : Color.ds.surface.opacity(0.98))
            
            // Animated shadow layers
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.clear)
                    .shadow(
                        color: Color.orange.opacity(0.2 - Double(i) * 0.05),
                        radius: 10 + CGFloat(i) * 10,
                        x: 0,
                        y: 5 + CGFloat(i) * 5
                    )
                    .opacity(glowIntensity)
            }
        }
    }
    
    @ViewBuilder
    private var animatedBorderGlow: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                AngularGradient(
                    colors: [
                        Color.orange.opacity(0.6),
                        Color.orange.opacity(0.2),
                        Color.orange.opacity(0.6)
                    ],
                    center: .center,
                    angle: .degrees(rotationAngle)
                ),
                lineWidth: 2
            )
            .blur(radius: 2)
    }
    
    private func startAnimations() {
        // Glow animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
        
        // Subtle pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.02
        }
        
        // Rotation for border gradient
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            floatingOffset = -10
        }
    }
}

// Animated counter component
struct AnimatedCounter: View {
    let value: Int
    let suffix: String
    @State private var displayValue: Int = 0
    
    var body: some View {
        Text("\(displayValue)\(suffix)")
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: 0.5)) {
                    displayValue = newValue
                }
            }
    }
}

struct SwarmHighlightRow: View {
    let info: SwarmHighlight.HighlightInfo
    @State private var showZapAnimation = false
    @State private var isHovered = false
    @State private var zapParticles: [SwarmZapParticle] = []
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Enhanced Avatar with glow effect
            ZStack {
                // Glow ring for high zappers
                if info.zapCount > 10 {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 36, height: 36)
                        .blur(radius: 2)
                        .opacity(isHovered ? 1 : 0.5)
                }
                
                Group {
                    if let picture = info.profile?.picture {
                        AsyncImage(url: URL(string: picture)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Text(String(info.profile?.name?.first ?? "?"))
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.orange)
                            )
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(isHovered ? 1.1 : 1.0)
            }
            
            // Enhanced Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(info.profile?.displayName ?? info.profile?.name ?? "Anonymous")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(isHovered ? .orange : .primary)
                    
                    Spacer()
                    
                    // Enhanced zap counter with live animation
                    if info.zapCount > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .symbolEffect(.bounce, value: info.zapCount)
                            Text("\(info.zapCount)")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    
                    Text(info.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if let note = info.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(isHovered ? 4 : 2)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                }
            }
            
            // Enhanced Zap button with particle effects
            ZStack {
                // Particle effects
                ForEach(zapParticles) { particle in
                    SwarmZapParticleView(particle: particle)
                }
                
                Button(action: {
                    performZap()
                }) {
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.orange.opacity(showZapAnimation ? 0.3 : 0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 40, height: 40)
                            .blur(radius: showZapAnimation ? 3 : 1)
                        
                        Image(systemName: showZapAnimation ? "bolt.circle.fill" : "bolt.circle")
                            .font(.title3)
                            .foregroundStyle(
                                showZapAnimation ?
                                    AnyShapeStyle(LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )) :
                                    AnyShapeStyle(Color.orange)
                            )
                            .scaleEffect(showZapAnimation ? 1.3 : 1.0)
                            .rotationEffect(.degrees(showZapAnimation ? 360 : 0))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        colorScheme == .dark ?
                            Color.ds.text.opacity(isHovered ? 0.08 : 0.04) :
                            Color.ds.text.opacity(isHovered ? 0.04 : 0.02)
                    )
                
                // Hover glow
                if isHovered {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                }
            }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private func performZap() {
        HapticManager.shared.impact(.medium)
        
        // Create particle burst
        for i in 0..<8 {
            let angle = Double(i) * (360.0 / 8.0)
            let particle = SwarmZapParticle(
                angle: angle,
                distance: CGFloat.random(in: 30...60),
                duration: Double.random(in: 0.6...1.0)
            )
            zapParticles.append(particle)
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showZapAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showZapAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            zapParticles.removeAll()
        }
        
        // Send actual zap
        Task {
            do {
                if appState.lightningService.isConnected {
                    try await appState.lightningService.sendSimpleZap(
                        amount: 21, // Default zap amount
                        to: info.author.pubkey,
                        comment: "⚡ Zapped via Highlighter"
                    )
                } else {
                    // Show wallet connection UI if not connected
                }
            } catch {
                HapticManager.shared.notification(.error)
            }
        }
    }
}

// Local particle type for swarm view to avoid conflict
struct SwarmZapParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let duration: Double
}

struct SwarmZapParticleView: View {
    let particle: SwarmZapParticle
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    
    var body: some View {
        Image(systemName: "bolt.fill")
            .font(.caption2)
            .foregroundColor(.orange)
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                let radians = particle.angle * .pi / 180
                let x = cos(radians) * particle.distance
                let y = sin(radians) * particle.distance
                
                withAnimation(.easeOut(duration: particle.duration)) {
                    offset = CGSize(width: x, height: y)
                    opacity = 0
                }
            }
    }
}

// MARK: - New Components for Enhanced Swarm Experience

// Cosmic background with floating particles
struct CosmicBackgroundView: View {
    let particles: [CosmicParticle]
    let activityLevel: Double
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let x = particle.x + cos(particle.angle * .pi / 180) * particle.speed * CGFloat(time.truncatingRemainder(dividingBy: 20))
                    let y = particle.y + sin(particle.angle * .pi / 180) * particle.speed * CGFloat(time.truncatingRemainder(dividingBy: 20))
                    
                    let wrappedX = x.truncatingRemainder(dividingBy: size.width + 100) - 50
                    let wrappedY = y.truncatingRemainder(dividingBy: size.height + 100) - 50
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: wrappedX - particle.size/2,
                            y: wrappedY - particle.size/2,
                            width: particle.size,
                            height: particle.size
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color.orange.opacity(0.3 + activityLevel * 0.4),
                                Color.orange.opacity(0)
                            ]),
                            center: .zero,
                            startRadius: 0,
                            endRadius: particle.size
                        )
                    )
                }
            }
        }
    }
}

// Live activity indicator showing real-time swarm engagement
struct LiveSwarmActivityIndicator: View {
    let activityLevel: Double
    let isPulsing: Bool
    @State private var rotationAngle: Double = 0
    @State private var ringExpansion: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            .orange.opacity(activityLevel),
                            .orange.opacity(activityLevel * 0.3),
                            .orange.opacity(activityLevel)
                        ],
                        center: .center,
                        angle: .degrees(rotationAngle)
                    ),
                    lineWidth: 3
                )
                .frame(width: 50 * ringExpansion, height: 50 * ringExpansion)
                .blur(radius: isPulsing ? 2 : 0)
            
            // Inner activity dots
            ForEach(0..<8) { index in
                Circle()
                    .fill(Color.orange)
                    .frame(width: 4, height: 4)
                    .offset(x: 15)
                    .rotationEffect(.degrees(Double(index) * 45 + rotationAngle))
                    .opacity(activityLevel > Double(index) / 8 ? 1 : 0.3)
                    .scaleEffect(isPulsing && activityLevel > Double(index) / 8 ? 1.2 : 1)
            }
            
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                ringExpansion = 1.2
            }
        }
    }
}

// Ripple effect for new highlights
struct SwarmRippleEffect: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
}

struct SwarmRippleEffectView: View {
    let ripple: SwarmRippleEffect
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .frame(width: 50 * scale, height: 50 * scale)
            .opacity(opacity)
            .position(x: ripple.x, y: ripple.y)
            .onAppear {
                withAnimation(.easeOut(duration: 2)) {
                    scale = 4
                    opacity = 0
                }
            }
    }
}

// Cosmic particle model
struct CosmicParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let angle: Double
}

// Enhanced swarm popover with 3D card flip
extension SwarmPopover {
    struct CardFlip3D: ViewModifier {
        let rotation: Double
        let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
        
        func body(content: Content) -> some View {
            content
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: axis,
                    anchor: .center,
                    anchorZ: 0,
                    perspective: 1
                )
        }
    }
}

// Analytics view for the back of the card
struct SwarmAnalyticsView: View {
    let highlight: SwarmHighlight
    @State private var chartAnimation: CGFloat = 0
    @State private var numberAnimation: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .symbolEffect(.pulse)
                
                Text("Swarm Analytics")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            
            // Engagement metrics
            VStack(spacing: 16) {
                // Intensity meter
                IntensityMeterView(
                    intensity: highlight.intensity,
                    animation: chartAnimation
                )
                
                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        icon: "person.2.fill",
                        value: Int(Double(highlight.totalHighlighters) * numberAnimation),
                        label: "Highlighters",
                        color: .orange
                    )
                    
                    StatCard(
                        icon: "bolt.fill",
                        value: Int(Double(highlight.totalZaps) * numberAnimation),
                        label: "Total Zaps",
                        color: .yellow
                    )
                    
                    StatCard(
                        icon: "clock.fill",
                        value: highlight.highlights.count,
                        label: "Time Periods",
                        color: .blue
                    )
                    
                    StatCard(
                        icon: "chart.bar.fill",
                        value: Int(highlight.intensity * 100),
                        label: "Intensity %",
                        color: .purple
                    )
                }
                
                // Activity timeline
                ActivityTimelineView(highlights: highlight.highlights)
                    .opacity(chartAnimation)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                chartAnimation = 1
                numberAnimation = 1
            }
        }
    }
}

// Intensity meter component
struct IntensityMeterView: View {
    let intensity: Double
    let animation: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Community Intensity")
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.ds.textTertiary.opacity(0.2))
                        .frame(height: 20)
                    
                    // Intensity bar
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * intensity * animation, height: 20)
                    
                    // Glow effect
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .clear],
                                startPoint: .center,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * intensity * animation, height: 20)
                        .blur(radius: 4)
                }
            }
            .frame(height: 20)
        }
    }
}

// Stat card component
struct StatCard: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    @State private var scaleEffect: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .scaleEffect(scaleEffect)
            
            Text("\(value)")
                .font(.title3.bold().monospacedDigit())
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scaleEffect = 1
            }
        }
    }
}

// Activity timeline view
struct ActivityTimelineView: View {
    let highlights: [SwarmHighlight.HighlightInfo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity Timeline")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(highlights.prefix(10), id: \.id) { info in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            
                            Text(info.createdAt.formatted(.dateTime.hour().minute()))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}