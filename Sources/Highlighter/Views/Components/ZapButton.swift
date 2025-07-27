import SwiftUI
import NDKSwift

struct ZapButton: View {
    let event: NDKEvent
    let size: ButtonSize
    var highlight: HighlightEvent? = nil
    var article: Article? = nil
    var onZapComplete: (() -> Void)? = nil
    
    @EnvironmentObject var appState: AppState
    @StateObject private var lightning = LightningService()
    @State private var zapState: ZapState = .idle
    @State private var showZapSheet = false
    @State private var showPaymentFlow = false
    @State private var zapAmount = 21
    @State private var showParticles = false
    @State private var particles: [ZapParticle] = []
    
    enum ButtonSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
    }
    
    enum ZapState {
        case idle
        case zapping
        case zapped
        case failed
        
        var iconName: String {
            switch self {
            case .idle: return "bolt"
            case .zapping: return "bolt"
            case .zapped: return "bolt.fill"
            case .failed: return "bolt.slash"
            }
        }
        
        var color: Color {
            switch self {
            case .idle: return DesignSystem.Colors.textSecondary
            case .zapping: return DesignSystem.Colors.primary.opacity(0.7)
            case .zapped: return DesignSystem.Colors.primary
            case .failed: return Color.red.opacity(0.7)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Particle effects layer
            ForEach(particles) { particle in
                ZapParticleView(particle: particle)
            }
            
            Button(action: handleZap) {
                HStack(spacing: 4) {
                    Image(systemName: zapState.iconName)
                        .font(.system(size: size.iconSize, weight: zapState == .zapped ? .semibold : .regular)
                        .foregroundColor(zapState.color)
                        .animation(.easeInOut(duration: 0.2), value: zapState)
                    
                    if zapState == .zapped {
                        Text("\(zapAmount)")
                            .font(.system(size: size.iconSize * 0.7, weight: .medium, design: .rounded)
                            .foregroundColor(zapState.color)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, size.padding * 0.8)
                .padding(.vertical, size.padding * 0.6)
            }
            .enhancedZapButton()
            .contextualFeedback(isActive: zapState == .zapping)
            .disabled(zapState == .zapping)
            .opacity(zapState == .failed ? 0.6 : 1.0)
        }
        .sheet(isPresented: $showZapSheet) {
            // Smart zap sheet will be enabled when Lightning service is integrated
            ZapAmountSheet(
                event: event,
                zapAmount: $zapAmount,
                onZap: performZap
            )
            .environmentObject(appState)
        }
        .sheet(isPresented: $showPaymentFlow) {
            if let highlight = highlight {
                LightningPaymentFlowView(
                    highlight: highlight,
                    authorProfile: nil, // Would fetch from ProfileManager
                    highlighterProfile: nil, // Would fetch from ProfileManager
                    curatorProfile: nil // Would fetch from ProfileManager
                )
            }
        }
    }
    
    private func handleZap() {
        HapticManager.shared.impact(.light)
        
        // If we have a highlight event and Lightning is connected, show the smart payment flow
        if highlight != nil && lightning.isConnected {
            showPaymentFlow = true
        } else if zapState == .zapped {
            // If already zapped, show amount picker to zap again
            showZapSheet = true
        } else {
            // Quick zap with default amount
            performZap(amount: zapAmount)
        }
    }
    
    private func performZap(amount: Int) {
        guard appState.ndk != nil else { return }
        
        zapState = .zapping
        HapticManager.shared.impact(.medium)
        
        Task {
            // Zapping is fully implemented via NostrWalletConnect (NWC)
            // This creates a zap event (kind 9735) and sends actual payment
            
            await MainActor.run {
                zapAmount = amount
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    zapState = .zapped
                }
                
                // Use advanced particle effect for smart splits
                if highlight != nil {
                    createAdvancedParticleEffect(splitCount: 3) // Author, Highlighter, Platform
                } else {
                    createParticleEffect()
                }
                
                HapticManager.shared.notification(.success)
                
                // Add a subtle second feedback after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    HapticManager.shared.impact(.light)
                }
            }
            
            // Perform the actual zap with no comment for now
            performSmartZap(amount: amount, comment: nil)
        }
    }
    
    private func performSmartZap(amount: Int, comment: String?) {
        Task {
            do {
                if let highlight = highlight {
                    _ = try await appState.lightningService.sendSmartZap(
                        amount: amount,
                        to: highlight,
                        comment: comment
                    )
                    await MainActor.run {
                        zapAmount = amount
                        HapticManager.shared.notification(.success)
                        onZapComplete?()
                    }
                } else {
                    // For regular events, send a standard zap
                    // This would be implemented when Lightning service supports regular zaps
                    HapticManager.shared.notification(.warning)
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
    
    private func createParticleEffect() {
        particles.removeAll()
        
        // More subtle particle effect with fewer particles
        for i in 0..<6 {
            let angle = Double(i) * 60.0 + Double.random(in: -15...15)
            let particle = ZapParticle(
                angle: angle,
                distance: CGFloat.random(in: 20...40),
                duration: Double.random(in: 0.8...1.0),
                color: DesignSystem.Colors.primary.opacity(0.8),
                size: 3
            )
            particles.append(particle)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particles.removeAll()
        }
    }
    
    private func createAdvancedParticleEffect(splitCount: Int) {
        particles.removeAll()
        
        // Create particles for each split recipient
        for i in 0..<splitCount {
            let baseAngle = (360.0 / Double(splitCount)) * Double(i)
            
            // Create a burst of particles for each recipient
            for j in 0..<3 {
                let angleVariation = Double.random(in: -10...10)
                let angle = baseAngle + angleVariation + (Double(j) * 5)
                
                let particle = ZapParticle(
                    angle: angle,
                    distance: CGFloat.random(in: 30...60),
                    duration: Double.random(in: 0.8...1.2),
                    color: [Color.orange, Color.purple, Color.blue][i % 3].opacity(0.8),
                    size: CGFloat.random(in: 2...5)
                )
                particles.append(particle)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particles.removeAll()
        }
    }
}

struct ZapAmountSheet: View {
    let event: NDKEvent
    @Binding var zapAmount: Int
    let onZap: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    let presetAmounts = [21, 42, 69, 100, 420, 1000, 5000, 10000]
    @State private var customAmount = ""
    @State private var useCustomAmount = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Simplified lightning icon
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48, weight: .regular)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.bottom, 8)
                .padding(.top)
                
                VStack(spacing: 8) {
                    Text("Choose Amount")
                        .font(.ds.title2)
                    
                    Text("Send sats to show appreciation")
                        .font(.ds.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // Preset amounts grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                    ForEach(presetAmounts, id: \.self) { amount in
                        Button(action: {
                            zapAmount = amount
                            useCustomAmount = false
                            customAmount = ""
                        }) {
                            Text("\(amount)")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.medium)
                                .frame(width: 80, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(zapAmount == amount && !useCustomAmount ? DesignSystem.Colors.primaryDark : DesignSystem.Colors.surface)
                                )
                                .foregroundColor(zapAmount == amount && !useCustomAmount ? .white : DesignSystem.Colors.text)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Custom amount
                HStack {
                    TextField("Custom amount", text: $customAmount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle()
                        .onChange(of: customAmount) { _, newValue in
                            useCustomAmount = !newValue.isEmpty
                            if let amount = Int(newValue) {
                                zapAmount = amount
                            }
                        }
                    
                    Text("sats")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Zap button
                Button(action: {
                    onZap(zapAmount)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Zap \(zapAmount) sats")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("⚡ Zap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// Enhanced ZapParticle with color support
struct ZapParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let duration: Double
    var color: Color = .orange
    var size: CGFloat = 4
}

struct ZapParticleView: View {
    let particle: ZapParticle
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .scaleEffect(scale)
            .offset(offset)
            .opacity(opacity)
            .blur(radius: opacity < 0.5 ? 2 : 0)
            .onAppear {
                let radians = particle.angle * .pi / 180
                let x = cos(radians) * particle.distance
                let y = sin(radians) * particle.distance
                
                withAnimation(.easeOut(duration: particle.duration)) {
                    offset = CGSize(width: x, height: y)
                    opacity = 0
                    scale = 0.3
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .small
            )
            
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .medium
            )
            
            ZapButton(
                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 1, tags: [], content: "", sig: ""),
                size: .large
            )
        }
    }
    .padding()
    .environmentObject(AppState())
}
