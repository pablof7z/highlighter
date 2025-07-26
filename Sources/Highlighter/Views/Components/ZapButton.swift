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
            case .zapping: return DesignSystem.Colors.primaryDark
            case .zapped: return DesignSystem.Colors.primary
            case .failed: return .red
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
                HStack(spacing: 6) {
                    Image(systemName: zapState.iconName)
                        .font(.system(size: size.iconSize, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(zapState == .zapping ? 1.3 : 1.0)
                        .rotationEffect(zapState == .zapping ? .degrees(15) : .degrees(0))
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6),
                            value: zapState
                        )
                    
                    if zapState == .zapped {
                        Text("\(zapAmount)")
                            .font(.system(size: size.iconSize * 0.8, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, size.padding)
                .padding(.vertical, size.padding * 0.75)
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
        guard let ndk = appState.ndk else { return }
        
        zapState = .zapping
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                // Add realistic delay for better UX feedback
                try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                
                // Note: Actual zapping requires wallet integration (NIP-57/NIP-60)
                // This would create a zap event (kind 9735) and send payment
                // This demo app simulates the zap UI without actual payment
                
                await MainActor.run {
                    zapAmount = amount
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        zapState = .zapped
                    }
                    
                    createParticleEffect()
                    HapticManager.shared.notification(.success)
                    
                    // Add a subtle second feedback after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        HapticManager.shared.impact(.light)
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        zapState = .failed
                    }
                    HapticManager.shared.notification(.error)
                    print("Zap failed: \(error)")
                    
                    // Auto-reset failed state after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            zapState = .idle
                        }
                    }
                }
            }
        }
    }
    
    // Smart zap functionality will be enabled when Lightning service is integrated
    /*
    private func performSmartZap(amount: Int, comment: String?) {
        // Implementation pending Lightning service integration
    }
    */
    
    private func createParticleEffect() {
        particles.removeAll()
        
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0)
            let particle = ZapParticle(
                angle: angle,
                distance: CGFloat.random(in: 30...80),
                duration: Double.random(in: 0.6...1.2)
            )
            particles.append(particle)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particles.removeAll()
        }
    }
    
    // Advanced particle effects for smart splits
    /*
    private func createAdvancedParticleEffect(splitCount: Int) {
        // Implementation pending Lightning service integration
    }
    */
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
                // Enhanced lightning bolt animation
                ZStack {
                    // Background glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.secondary.opacity(0.3),
                                    DesignSystem.Colors.secondary.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .pulseGently()
                    
                    // Main lightning bolt
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.secondary,
                                    DesignSystem.Colors.secondaryDark
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: DesignSystem.Colors.secondary.opacity(0.4),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
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
                    .buttonStyle(ModernPrimaryButton())
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
