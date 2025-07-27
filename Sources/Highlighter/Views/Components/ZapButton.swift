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
                        .font(.system(size: size.iconSize, weight: zapState == .zapped ? .semibold : .regular))
                        .foregroundColor(zapState.color)
                        .animation(.easeInOut(duration: 0.2), value: zapState)
                    
                    if zapState == .zapped {
                        Text("\(zapAmount)")
                            .font(.system(size: size.iconSize * 0.7, weight: .medium, design: .rounded))
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
            // Note: Actual zapping requires wallet integration (NIP-57/NIP-60)
            // This would create a zap event (kind 9735) and send payment
            // This demo app simulates the zap UI without actual payment
            
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
                    try await appState.lightningService.sendSmartZap(
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
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.bottom, 8)
                .padding(.top)
                
                VStack(spacing: 8) {
                    Text("Choose Amount")
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text("Send sats to show appreciation")
                        .font(.system(size: 16))
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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

// MARK: - Smart Zap Sheet
/* Temporarily disabled until Lightning Service is integrated
struct SmartZapSheet: View {
    let highlight: HighlightEvent
    let article: Article?
    // @ObservedObject var lightning: LightningService
    @Binding var zapAmount: Int
    let onZap: (Int, String?) -> Void
    
    @State private var comment = ""
    @State private var showSplitPreview = false
    @State private var splitAnimations = [false, false, false]
    @Environment(\.dismiss) var dismiss
    
    var splits: [(role: String, percentage: Double, color: Color)] {
        [
            ("Author", lightning.splitConfig.authorPercentage, .blue),
            ("Highlighter", lightning.splitConfig.highlighterPercentage, .orange),
            ("Curator", lightning.splitConfig.curatorPercentage, .purple)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    // Lightning animation with splits visualization
                    ZStack {
                        // Background gradient
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.orange.opacity(0.2),
                                        Color.orange.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        // Split indicators
                        ForEach(0..<splits.count, id: \.self) { index in
                            if showSplitPreview && splitAnimations[index] {
                                SplitIndicatorAnimation(
                                    angle: Double(index) * 120,
                                    color: splits[index].color,
                                    percentage: splits[index].percentage
                                )
                            }
                        }
                        
                        // Central lightning bolt
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(showSplitPreview ? 0.8 : 1.0)
                    }
                    .frame(height: 160)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplitPreview = true
                        }
                        
                        // Stagger split animations
                        for i in 0..<splits.count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    splitAnimations[i] = true
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: .ds.small) {
                        Text("Smart Zap")
                            .font(.ds.title2)
                            .foregroundColor(.ds.text)
                        
                        Text("Your payment will be automatically split")
                            .font(.ds.body)
                            .foregroundColor(.ds.textSecondary)
                    }
                    
                    // Amount selection
                    VStack(alignment: .leading, spacing: .ds.medium) {
                        Text("Amount")
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.ds.textSecondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: .ds.base) {
                            ForEach([21, 100, 500, 1000, 5000, 10000], id: \.self) { amount in
                                Button(action: {
                                    zapAmount = amount
                                    HapticManager.shared.impact(.light)
                                }) {
                                    Text("\(amount)")
                                        .font(.ds.bodyMedium)
                                        .frame(width: 80, height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                                                .fill(zapAmount == amount ? Color.orange : Color.ds.surfaceSecondary)
                                        )
                                        .foregroundColor(zapAmount == amount ? .white : .ds.text)
                                }
                            }
                        }
                    }
                    
                    // Split preview
                    VStack(alignment: .leading, spacing: .ds.medium) {
                        HStack {
                            Text("Payment Distribution")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.textSecondary)
                            
                            Spacer()
                            
                            Text("\(zapAmount) sats")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.text)
                        }
                        
                        VStack(spacing: .ds.small) {
                            ForEach(0..<splits.count, id: \.self) { index in
                                let split = splits[index]
                                let amount = Int(Double(zapAmount) * split.percentage)
                                
                                HStack {
                                    Circle()
                                        .fill(split.color)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(split.role)
                                        .font(.ds.callout)
                                        .foregroundColor(.ds.text)
                                    
                                    Spacer()
                                    
                                    Text("\(amount) sats")
                                        .font(.ds.calloutMedium)
                                        .foregroundColor(.ds.text)
                                        .contentTransition(.numericText())
                                    
                                    Text("(\(Int(split.percentage * 100))%)")
                                        .font(.ds.caption)
                                        .foregroundColor(.ds.textSecondary)
                                }
                                .padding(.ds.small)
                                .background(Color.ds.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: .ds.small, style: .continuous))
                            }
                        }
                    }
                    
                    // Comment field
                    VStack(alignment: .leading, spacing: .ds.small) {
                        Text("Add a comment (optional)")
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.ds.textSecondary)
                        
                        TextField("Your message...", text: $comment, axis: .vertical)
                            .lineLimit(2...4)
                            .padding(.ds.base)
                            .background(Color.ds.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                    }
                    
                    // Zap button
                    Button(action: {
                        onZap(zapAmount, comment.isEmpty ? nil : comment)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Send Smart Zap")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .unifiedPrimaryButton()
                }
                .padding(.horizontal, .ds.screenPadding)
                .padding(.bottom, .ds.large)
            }
            .navigationTitle("⚡ Smart Zap")
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
*/

/* Temporarily disabled until Lightning Service is integrated
struct SplitIndicatorAnimation: View {
    let angle: Double
    let color: Color
    let percentage: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 20, height: 20)
            .overlay(
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
            )
            .offset(x: offset * cos(angle * .pi / 180), y: offset * sin(angle * .pi / 180))
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    offset = 60
                    opacity = 1
                }
            }
    }
}
*/

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
