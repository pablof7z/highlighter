import SwiftUI
import AVFoundation
import NDKSwift

struct AudioPlayerView: View {
    let highlight: HighlightEvent
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var showSatStreaming = false
    @State private var satStreamAmount: Int = 21
    @State private var waveformAnimation: [CGFloat] = Array(repeating: 0.5, count: 40)
    @State private var glowAnimation = false
    @State private var pulseAnimation = false
    @State private var particleSystem: [AudioParticle] = []
    @State private var rotationAngle: Double = 0
    @State private var expandedView = false
    @State private var showSpeedControl = false
    @State private var selectedVoice: AVSpeechSynthesisVoice?
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            if expandedView {
                expandedPlayer
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
            } else {
                compactPlayer
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
            }
        }
        .background(playerBackground)
        .clipShape(RoundedRectangle(cornerRadius: expandedView ? 24 : 16))
        .overlay(
            RoundedRectangle(cornerRadius: expandedView ? 24 : 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(audioManager.isPlaying ? 0.6 : 0.3),
                            Color.purple.opacity(audioManager.isPlaying ? 0.4 : 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: audioManager.isPlaying ? 2 : 1
                )
                .blur(radius: audioManager.isPlaying ? 1 : 0)
        )
        .shadow(
            color: audioManager.isPlaying ? Color.orange.opacity(0.3) : Color.black.opacity(0.1),
            radius: audioManager.isPlaying ? 20 : 10,
            y: 5
        )
        .scaleEffect(pulseAnimation ? 1.02 : 1.0)
        .onAppear {
            audioManager.setupSpeech(for: highlight)
            startAnimations()
            generateParticles()
        }
        .onChange(of: audioManager.isPlaying) { _, playing in
            if playing {
                startPlayingAnimations()
            } else {
                stopPlayingAnimations()
            }
        }
    }
    
    @ViewBuilder
    private var compactPlayer: some View {
        HStack(spacing: 16) {
            // Play/Pause button with animated ring
            playPauseButton(size: 44)
            
            // Waveform visualization
            HStack(spacing: 2) {
                ForEach(0..<20) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.8),
                                    Color.purple.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3, height: waveformAnimation[index] * 30)
                        .animation(
                            audioManager.isPlaying ?
                                .easeInOut(duration: Double.random(in: 0.3...0.6))
                                .repeatForever(autoreverses: true) :
                                .easeOut(duration: 0.3),
                            value: waveformAnimation[index]
                        )
                }
            }
            .frame(height: 30)
            
            Spacer()
            
            // Speed control
            Button(action: {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showSpeedControl.toggle()
                }
            }) {
                Label("\(String(format: "%.1fx", audioManager.speechRate))", systemImage: "gauge")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.orange)
            }
            
            // Expand button
            Button(action: {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    expandedView = true
                }
            }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        if showSpeedControl {
            speedControlView
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
        }
    }
    
    @ViewBuilder
    private var expandedPlayer: some View {
        VStack(spacing: 24) {
            // Header with minimize button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Text-to-Speech")
                        .font(.headline)
                    Text("\(highlight.content.split(separator: " ").count) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.impact(.light)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        expandedView = false
                    }
                }) {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Main visualization area
            ZStack {
                // Particle system background
                ForEach(particleSystem) { particle in
                    AudioParticleView(particle: particle, isPlaying: audioManager.isPlaying)
                }
                
                // Central play button with rings
                centralPlayButton
            }
            .frame(height: 200)
            
            // Progress bar
            progressBar
                .padding(.horizontal, 20)
            
            // Waveform visualization
            waveformVisualization
                .frame(height: 60)
                .padding(.horizontal, 20)
            
            // Controls
            VStack(spacing: 16) {
                // Speed control
                speedControlView
                
                // Voice selection
                voiceSelectionView
                
                // Sat streaming toggle
                satStreamingView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    private var centralPlayButton: some View {
        ZStack {
            // Animated rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.orange.opacity(0.3 - Double(index) * 0.1),
                                Color.purple.opacity(0.2 - Double(index) * 0.05),
                                Color.orange.opacity(0.3 - Double(index) * 0.1)
                            ],
                            center: .center,
                            angle: .degrees(rotationAngle + Double(index) * 120)
                        ),
                        lineWidth: 2
                    )
                    .frame(
                        width: 100 + CGFloat(index) * 40,
                        height: 100 + CGFloat(index) * 40
                    )
                    .blur(radius: audioManager.isPlaying ? 1 : 0)
                    .scaleEffect(audioManager.isPlaying ? 1.1 : 1.0)
                    .opacity(audioManager.isPlaying ? 0.8 : 0.4)
            }
            
            // Main button
            playPauseButton(size: 80)
        }
    }
    
    @ViewBuilder
    private func playPauseButton(size: CGFloat) -> some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            audioManager.togglePlayPause()
        }) {
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(glowAnimation ? 0.4 : 0.2),
                                Color.orange.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size
                        )
                    )
                    .frame(width: size * 2, height: size * 2)
                    .blur(radius: 10)
                
                // Button background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                // Icon
                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: audioManager.isPlaying ? 0 : 2)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var progressBar: some View {
        VStack(spacing: 8) {
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatTime(audioManager.duration))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            
            // Progress slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * audioManager.progress, height: 4)
                    
                    // Glow effect
                    Capsule()
                        .fill(Color.orange.opacity(0.5))
                        .frame(width: geometry.size.width * audioManager.progress, height: 4)
                        .blur(radius: 4)
                    
                    // Draggable thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
                        .overlay(
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                        )
                        .position(x: geometry.size.width * audioManager.progress, y: 2)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let progress = min(max(0, value.location.x / geometry.size.width), 1)
                                    audioManager.seek(to: progress)
                                }
                        )
                }
            }
            .frame(height: 4)
        }
    }
    
    @ViewBuilder
    private var waveformVisualization: some View {
        HStack(spacing: 2) {
            ForEach(0..<40) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.8),
                                Color.purple.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: waveformAnimation[index] * 60)
                    .animation(
                        audioManager.isPlaying ?
                            .easeInOut(duration: Double.random(in: 0.3...0.6))
                            .repeatForever(autoreverses: true) :
                            .easeOut(duration: 0.3),
                        value: waveformAnimation[index]
                    )
            }
        }
    }
    
    @ViewBuilder
    private var speedControlView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Playback Speed")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1fx", audioManager.speechRate))")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 12) {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { speed in
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        audioManager.setSpeechRate(Float(speed))
                    }) {
                        Text("\(String(format: "%.1fx", speed))")
                            .font(.caption.weight(.medium))
                            .foregroundColor(audioManager.speechRate == Float(speed) ? .white : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(audioManager.speechRate == Float(speed) ? Color.orange : Color.orange.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private var voiceSelectionView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Voice")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(selectedVoice?.name ?? "Default")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.orange)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AVSpeechSynthesisVoice.speechVoices().prefix(6), id: \.identifier) { voice in
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            selectedVoice = voice
                            audioManager.setVoice(voice)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "person.wave.2")
                                    .font(.title3)
                                    .foregroundColor(selectedVoice?.identifier == voice.identifier ? .white : .orange)
                                
                                Text(voice.name.components(separatedBy: " ").first ?? "Voice")
                                    .font(.caption2)
                                    .foregroundColor(selectedVoice?.identifier == voice.identifier ? .white : .orange)
                            }
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedVoice?.identifier == voice.identifier ? Color.orange : Color.orange.opacity(0.1))
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private var satStreamingView: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Sat Streaming", systemImage: "bolt.fill")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.orange)
                
                Spacer()
                
                Toggle("", isOn: $showSatStreaming)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                    .scaleEffect(0.8)
            }
            
            if showSatStreaming {
                VStack(spacing: 8) {
                    HStack {
                        Text("Stream amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(satStreamAmount) sats/min")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach([1, 5, 10, 21, 50, 100], id: \.self) { amount in
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                satStreamAmount = amount
                            }) {
                                Text("\(amount)")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(satStreamAmount == amount ? .white : .orange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(satStreamAmount == amount ? Color.orange : Color.orange.opacity(0.1))
                                    )
                            }
                        }
                    }
                    
                    if audioManager.isPlaying {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .symbolEffect(.pulse)
                            
                            Text("Streaming \(satStreamAmount) sats/min to author")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    @ViewBuilder
    private var playerBackground: some View {
        ZStack {
            // Base background
            if colorScheme == .dark {
                Color.black.opacity(0.95)
            } else {
                Color.white.opacity(0.98)
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.05),
                    Color.purple.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh gradient (iOS 18+)
            if #available(iOS 18.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: [
                        .orange.opacity(0.1), .purple.opacity(0.05), .orange.opacity(0.1),
                        .purple.opacity(0.05), .clear, .purple.opacity(0.05),
                        .orange.opacity(0.1), .purple.opacity(0.05), .orange.opacity(0.1)
                    ]
                )
                .blur(radius: 20)
                .opacity(glowAnimation ? 0.8 : 0.3)
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowAnimation = true
        }
        
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func startPlayingAnimations() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
        
        // Animate waveform
        for i in 0..<40 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                waveformAnimation[i] = CGFloat.random(in: 0.3...1.0)
            }
        }
        
        // Start sat streaming if enabled
        if showSatStreaming {
            startSatStreaming()
        }
    }
    
    private func stopPlayingAnimations() {
        pulseAnimation = false
        
        // Reset waveform
        for i in 0..<40 {
            waveformAnimation[i] = 0.5
        }
        
        // Stop sat streaming
        stopSatStreaming()
    }
    
    private func generateParticles() {
        for _ in 0..<12 {
            let particle = AudioParticle(
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -100...100),
                size: CGFloat.random(in: 4...12),
                color: [Color.orange, Color.purple].randomElement()!,
                speed: CGFloat.random(in: 20...60)
            )
            particleSystem.append(particle)
        }
    }
    
    private func startSatStreaming() {
        // TODO: Implement actual sat streaming logic
        print("Starting sat stream: \(satStreamAmount) sats/min")
    }
    
    private func stopSatStreaming() {
        // TODO: Implement actual sat streaming stop logic
        print("Stopping sat stream")
    }
}

// Audio particle for visual effects
struct AudioParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    let speed: CGFloat
}

struct AudioParticleView: View {
    let particle: AudioParticle
    let isPlaying: Bool
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        particle.color.opacity(opacity),
                        particle.color.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .offset(x: particle.x + offset.width, y: particle.y + offset.height)
            .blur(radius: isPlaying ? 2 : 4)
            .onAppear {
                if isPlaying {
                    animateParticle()
                }
            }
            .onChange(of: isPlaying) { _, playing in
                if playing {
                    animateParticle()
                } else {
                    withAnimation(.easeOut(duration: 0.5)) {
                        offset = .zero
                        opacity = 0.8
                    }
                }
            }
    }
    
    private func animateParticle() {
        withAnimation(
            .easeInOut(duration: Double.random(in: 3...6))
            .repeatForever(autoreverses: true)
        ) {
            offset = CGSize(
                width: CGFloat.random(in: -particle.speed...particle.speed),
                height: CGFloat.random(in: -particle.speed...particle.speed)
            )
            opacity = Double.random(in: 0.3...0.8)
        }
    }
}

// Audio player manager
@MainActor
class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 100
    @Published var progress: CGFloat = 0
    @Published var speechRate: Float = 1.0
    
    private let synthesizer = AVSpeechSynthesizer()
    private var utterance: AVSpeechUtterance?
    private var timer: Timer?
    
    func setupSpeech(for highlight: HighlightEvent) {
        utterance = AVSpeechUtterance(string: highlight.content)
        utterance?.rate = speechRate
        utterance?.pitchMultiplier = 1.0
        utterance?.volume = 0.9
        
        // Estimate duration (rough approximation)
        let wordsPerMinute: Float = 150
        let wordCount = Float(highlight.content.split(separator: " ").count)
        duration = TimeInterval((wordCount / wordsPerMinute) * 60 / speechRate)
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        guard let utterance = utterance else { return }
        
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        } else {
            synthesizer.speak(utterance)
            startTimer()
        }
        
        isPlaying = true
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
        stopTimer()
        isPlaying = false
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        stopTimer()
        isPlaying = false
        currentTime = 0
        progress = 0
    }
    
    func seek(to progress: CGFloat) {
        self.progress = progress
        currentTime = duration * TimeInterval(progress)
        // Note: AVSpeechSynthesizer doesn't support seeking, this is for UI only
    }
    
    func setSpeechRate(_ rate: Float) {
        speechRate = rate
        utterance?.rate = rate
        
        // Update duration estimate
        if let text = utterance?.speechString {
            let wordsPerMinute: Float = 150
            let wordCount = Float(text.split(separator: " ").count)
            duration = TimeInterval((wordCount / wordsPerMinute) * 60 / rate)
        }
    }
    
    func setVoice(_ voice: AVSpeechSynthesisVoice) {
        utterance?.voice = voice
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateProgress()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @MainActor
    private func updateProgress() {
        currentTime += 0.1
        progress = CGFloat(currentTime / duration)
        
        if progress >= 1.0 {
            stop()
        }
    }
}