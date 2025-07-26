import SwiftUI
import NDKSwift

struct LightningPaymentFlowView: View {
    @StateObject private var lightningService = LightningService()
    @State private var selectedAmount = 1000
    @State private var customAmount = ""
    @State private var showingPaymentFlow = false
    @State private var currentPaymentStep: PaymentStep = .selectAmount
    @State private var splitVisualizationScale: CGFloat = 0
    @State private var particles: [LightningParticle] = []
    @State private var glowIntensity: Double = 0
    @State private var successScale: CGFloat = 0
    @State private var paymentComplete = false
    @State private var rotationAngle: Double = 0
    @State private var flowAnimation: CGFloat = 0
    @State private var splitAnimations: [String: CGFloat] = [:]
    @State private var lightningBoltAnimation = false
    @State private var coinFlipRotation: Double = 0
    @State private var activePayment: LightningService.ActivePayment?
    @State private var selectedSplitConfiguration = 0
    @State private var customSplitConfig = LightningService.SplitConfiguration.highlight
    @State private var showCustomSplitEditor = false
    @Namespace private var animation
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Payment target info
    let highlight: HighlightEvent
    let authorProfile: NDKUserProfile?
    let highlighterProfile: NDKUserProfile?
    let curatorProfile: NDKUserProfile?
    
    private let predefinedAmounts = [100, 500, 1000, 5000, 10000, 50000]
    
    private let splitConfigurations = [
        ("Default", LightningService.SplitConfiguration.highlight),
        ("Author Focus", LightningService.SplitConfiguration(author: 0.7, highlighter: 0.2, curator: 0.05, platform: 0.05)),
        ("Equal Split", LightningService.SplitConfiguration(author: 0.32, highlighter: 0.32, curator: 0.31, platform: 0.05)),
        ("Custom", LightningService.SplitConfiguration.highlight)
    ]
    
    enum PaymentStep {
        case selectAmount
        case configureSplits
        case processingPayment
        case visualizingSplits
        case complete
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            // Particle effects layer
            ParticleEffectsLayer(particles: $particles)
                .allowsHitTesting(false)
            
            // Main content
            VStack(spacing: 0) {
                // Header
                paymentHeader
                
                // Content based on step
                Group {
                    switch currentPaymentStep {
                    case .selectAmount:
                        amountSelectionView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            ))
                    
                    case .configureSplits:
                        splitConfigurationView
                            .transition(.asymmetric(
                                insertion: .push(from: .trailing),
                                removal: .push(from: .leading)
                            ))
                    
                    case .processingPayment:
                        processingView
                            .transition(.scale.combined(with: .opacity))
                    
                    case .visualizingSplits:
                        splitVisualizationView
                            .transition(.scale.combined(with: .opacity))
                    
                    case .complete:
                        completionView
                            .transition(.asymmetric(
                                insertion: .scale(scale: 1.2).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPaymentStep)
                
                Spacer()
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: activePayment?.status) { _, newStatus in
            handlePaymentStatusChange(newStatus)
        }
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.ds.background,
                    Color.ds.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated gradient overlay
            RadialGradient(
                colors: [
                    Color.ds.primary.opacity(glowIntensity * 0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .scaleEffect(1 + glowIntensity)
            .blur(radius: 20)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    @ViewBuilder
    private var paymentHeader: some View {
        VStack(spacing: 16) {
            // Lightning bolt icon with animation
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.6),
                                Color.orange.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(lightningBoltAnimation ? 1.2 : 1)
                    .blur(radius: lightningBoltAnimation ? 15 : 10)
                
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(lightningBoltAnimation ? 5 : -5))
                    .scaleEffect(lightningBoltAnimation ? 1.1 : 1)
            }
            
            Text("Lightning Payment")
                .font(.ds.title2)
                .fontWeight(.bold)
            
            // Balance display
            if lightningService.isConnected {
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                    Text("\(lightningService.balance) sats")
                        .font(.ds.callout)
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.ds.backgroundSecondary)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.ds.border, lineWidth: 1)
                        )
                )
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Amount Selection
    @ViewBuilder
    private var amountSelectionView: some View {
        VStack(spacing: 24) {
            Text("Select Amount")
                .font(.ds.headline)
                .foregroundColor(.ds.textSecondary)
            
            // Predefined amounts grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(predefinedAmounts, id: \.self) { amount in
                    AmountButton(
                        amount: amount,
                        isSelected: selectedAmount == amount,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedAmount = amount
                                customAmount = ""
                                HapticManager.shared.impact(.light)
                            }
                        }
                    )
                }
            }
            
            // Custom amount input
            VStack(spacing: 12) {
                Text("Or enter custom amount")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
                
                HStack {
                    TextField("Amount in sats", text: $customAmount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: customAmount) { _, newValue in
                            if let amount = Int(newValue) {
                                selectedAmount = amount
                            }
                        }
                    
                    Text("sats")
                        .font(.ds.callout)
                        .foregroundColor(.ds.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ds.backgroundSecondary)
            )
        }
        .padding(.vertical)
    }
    
    // MARK: - Split Configuration
    @ViewBuilder
    private var splitConfigurationView: some View {
        VStack(spacing: 24) {
            Text("Configure Payment Splits")
                .font(.ds.headline)
                .foregroundColor(.ds.textSecondary)
            
            // Split configuration options
            VStack(spacing: 12) {
                ForEach(Array(splitConfigurations.enumerated()), id: \.offset) { index, config in
                    SplitConfigurationCard(
                        title: config.0,
                        configuration: index == 3 ? customSplitConfig : config.1,
                        isSelected: selectedSplitConfiguration == index,
                        isCustom: index == 3,
                        amount: selectedAmount,
                        authorName: authorProfile?.displayName ?? "Author",
                        highlighterName: highlighterProfile?.displayName ?? "Highlighter",
                        curatorName: curatorProfile?.displayName ?? "Curator",
                        onSelect: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSplitConfiguration = index
                                if index == 3 {
                                    showCustomSplitEditor = true
                                }
                                HapticManager.shared.impact(.light)
                            }
                        }
                    )
                }
            }
            
            // Visual preview of splits
            SplitPreviewVisualization(
                configuration: selectedSplitConfiguration == 3 ? customSplitConfig : splitConfigurations[selectedSplitConfiguration].1,
                totalAmount: selectedAmount,
                animationProgress: splitVisualizationScale
            )
        }
        .padding(.vertical)
        .sheet(isPresented: $showCustomSplitEditor) {
            CustomSplitEditorView(configuration: $customSplitConfig)
        }
    }
    
    // MARK: - Processing View
    @ViewBuilder
    private var processingView: some View {
        VStack(spacing: 32) {
            animatedLightningBolt
            
            Text("Processing Payment")
                .font(.ds.title3)
                .fontWeight(.semibold)
            
            if let payment = activePayment {
                PaymentStatusIndicator(payment: payment)
            }
        }
        .onAppear {
            processPayment()
        }
    }
    
    @ViewBuilder
    private var animatedLightningBolt: some View {
        ZStack {
            animatedCircles
            lightningBoltIcon
        }
    }
    
    @ViewBuilder
    private var animatedCircles: some View {
        ForEach(0..<3) { index in
            animatedCircle(for: index)
        }
    }
    
    @ViewBuilder
    private func animatedCircle(for index: Int) -> some View {
        Circle()
            .stroke(lightningGradient, lineWidth: 2)
            .frame(width: circleSize(for: index), height: circleSize(for: index))
            .scaleEffect(flowAnimation)
            .opacity(Double(1 - (flowAnimation * 0.3)))
            .animation(circleAnimation(for: index), value: flowAnimation)
    }
    
    private var lightningBoltIcon: some View {
        Image(systemName: "bolt.circle.fill")
            .font(.system(size: 80))
            .foregroundStyle(lightningGradient)
            .rotationEffect(.degrees(rotationAngle))
    }
    
    private var lightningGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func circleSize(for index: Int) -> CGFloat {
        100 + CGFloat(index) * 40
    }
    
    private func circleAnimation(for index: Int) -> Animation {
        .easeOut(duration: 1.5)
            .repeatForever(autoreverses: false)
            .delay(Double(index) * 0.3)
    }
    
    // MARK: - Split Visualization
    @ViewBuilder
    private var splitVisualizationView: some View {
        VStack(spacing: 32) {
            Text("Splitting Payment")
                .font(.ds.title3)
                .fontWeight(.semibold)
            
            // Animated split visualization
            SplitFlowVisualization(
                payment: activePayment,
                animationProgress: flowAnimation,
                particles: $particles
            )
            
            // Split progress indicators
            if let payment = activePayment {
                VStack(spacing: 16) {
                    ForEach(Array(payment.splits.enumerated()), id: \.element.recipientPubkey) { index, split in
                        SplitProgressRow(
                            split: split,
                            animationProgress: splitAnimations[split.id.uuidString] ?? 0
                        )
                        .onAppear {
                            withAnimation(.spring(response: 0.5).delay(Double(payment.splits.firstIndex(where: { $0.id == split.id }) ?? 0) * 0.2)) {
                                splitAnimations[split.id.uuidString] = 1
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.ds.backgroundSecondary)
                )
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Completion View
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 32) {
            // Success animation
            ZStack {
                // Confetti particles
                ForEach(0..<20) { _ in
                    ConfettiParticle()
                }
                
                // Success checkmark
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(successScale)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(successScale)
                    )
            }
            
            Text("Payment Complete!")
                .font(.ds.title2)
                .fontWeight(.bold)
            
            // Transaction summary
            if let payment = activePayment {
                TransactionSummaryCard(payment: payment)
            }
            
            // Share button
            Button(action: shareTransaction) {
                Label("Share Transaction", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(ModernSecondaryButton())
        }
        .padding(.vertical)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                successScale = 1
            }
            HapticManager.shared.notification(.success)
        }
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 16) {
            if currentPaymentStep != .complete {
                Button("Cancel") {
                    HapticManager.shared.impact(.light)
                    dismiss()
                }
                .buttonStyle(ModernSecondaryButton())
            }
            
            switch currentPaymentStep {
            case .selectAmount:
                Button("Continue") {
                    withAnimation(.spring(response: 0.5)) {
                        currentPaymentStep = .configureSplits
                        splitVisualizationScale = 1
                    }
                    HapticManager.shared.impact(.medium)
                }
                .buttonStyle(ModernPrimaryButton())
                .disabled(selectedAmount < 1)
            
            case .configureSplits:
                Button("Send Payment") {
                    withAnimation(.spring(response: 0.5)) {
                        currentPaymentStep = .processingPayment
                    }
                    HapticManager.shared.impact(.medium)
                }
                .buttonStyle(ModernPrimaryButton())
            
            case .processingPayment, .visualizingSplits:
                EmptyView()
            
            case .complete:
                Button("Done") {
                    HapticManager.shared.impact(.light)
                    dismiss()
                }
                .buttonStyle(ModernPrimaryButton())
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Methods
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
            lightningBoltAnimation = true
        }
        
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            generateLightningParticles()
        }
    }
    
    private func processPayment() {
        Task {
            // Create mock payment
            _ = selectedSplitConfiguration == 3 ? customSplitConfig : splitConfigurations[selectedSplitConfiguration].1
            let payment = await lightningService.generateMockPayment()
            
            await MainActor.run {
                activePayment = payment
                flowAnimation = 1
            }
        }
    }
    
    private func handlePaymentStatusChange(_ status: LightningService.ActivePayment.PaymentStatus?) {
        guard let status = status else { return }
        
        switch status {
        case .splitting:
            withAnimation(.spring(response: 0.5)) {
                currentPaymentStep = .visualizingSplits
            }
        
        case .completed:
            withAnimation(.spring(response: 0.6).delay(0.5)) {
                currentPaymentStep = .complete
                paymentComplete = true
            }
        
        default:
            break
        }
    }
    
    private func generateLightningParticles() {
        if paymentComplete { return }
        
        if Bool.random() {
            let particle = LightningParticle(
                x: .random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + 50,
                targetY: .random(in: 100...UIScreen.main.bounds.height - 100),
                color: [.orange, .yellow].randomElement()!,
                size: .random(in: 2...6),
                duration: .random(in: 1...3)
            )
            particles.append(particle)
            
            // Remove old particles
            particles = particles.filter { particle in
                particle.createdAt.timeIntervalSinceNow > -particle.duration
            }
        }
    }
    
    private func shareTransaction() {
        // Implement share functionality
        HapticManager.shared.impact(.medium)
    }
}

// MARK: - Supporting Views

struct AmountButton: View {
    let amount: Int
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .orange)
                
                Text("\(amount)")
                    .font(.ds.headline)
                    .monospacedDigit()
                    .foregroundColor(isSelected ? .white : .ds.text)
                
                Text("sats")
                    .font(.ds.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .ds.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.ds.primary : Color.ds.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.clear : Color.ds.border,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct SplitConfigurationCard: View {
    let title: String
    let configuration: LightningService.SplitConfiguration
    let isSelected: Bool
    let isCustom: Bool
    let amount: Int
    let authorName: String
    let highlighterName: String
    let curatorName: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.ds.headline)
                        .foregroundColor(isSelected ? .white : .ds.text)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                if !isCustom {
                    // Split breakdown
                    VStack(spacing: 8) {
                        SplitRow(
                            icon: "person.fill",
                            label: authorName,
                            percentage: configuration.author,
                            amount: Int(Double(amount) * configuration.author),
                            color: .purple,
                            isSelected: isSelected
                        )
                        
                        SplitRow(
                            icon: "highlighter",
                            label: highlighterName,
                            percentage: configuration.highlighter,
                            amount: Int(Double(amount) * configuration.highlighter),
                            color: .orange,
                            isSelected: isSelected
                        )
                        
                        SplitRow(
                            icon: "folder.fill",
                            label: curatorName,
                            percentage: configuration.curator,
                            amount: Int(Double(amount) * configuration.curator),
                            color: .blue,
                            isSelected: isSelected
                        )
                        
                        SplitRow(
                            icon: "building.2.fill",
                            label: "Platform",
                            percentage: configuration.platform,
                            amount: Int(Double(amount) * configuration.platform),
                            color: .gray,
                            isSelected: isSelected
                        )
                    }
                } else {
                    Text("Tap to customize split percentages")
                        .font(.ds.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .ds.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.ds.primary : Color.ds.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.clear : Color.ds.border,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SplitRow: View {
    let icon: String
    let label: String
    let percentage: Double
    let amount: Int
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isSelected ? .white : color)
                .frame(width: 20)
            
            Text(label)
                .font(.ds.caption)
                .foregroundColor(isSelected ? .white : .ds.text)
            
            Spacer()
            
            Text("\(Int(percentage * 100))%")
                .font(.ds.caption.monospacedDigit())
                .foregroundColor(isSelected ? .white.opacity(0.8) : .ds.textSecondary)
            
            Text("·")
                .foregroundColor(isSelected ? .white.opacity(0.5) : .ds.textTertiary)
            
            Text("\(amount) sats")
                .font(.ds.caption.monospacedDigit())
                .foregroundColor(isSelected ? .white : .ds.text)
        }
    }
}

struct SplitPreviewVisualization: View {
    let configuration: LightningService.SplitConfiguration
    let totalAmount: Int
    let animationProgress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.ds.backgroundSecondary)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.ds.border, lineWidth: 1)
                    )
                
                // Split segments
                SplitSegment(
                    startAngle: 0,
                    endAngle: configuration.author * 360,
                    color: .purple,
                    label: "Author",
                    amount: Int(Double(totalAmount) * configuration.author),
                    animationProgress: animationProgress
                )
                
                SplitSegment(
                    startAngle: configuration.author * 360,
                    endAngle: (configuration.author + configuration.highlighter) * 360,
                    color: .orange,
                    label: "Highlighter",
                    amount: Int(Double(totalAmount) * configuration.highlighter),
                    animationProgress: animationProgress
                )
                
                SplitSegment(
                    startAngle: (configuration.author + configuration.highlighter) * 360,
                    endAngle: (configuration.author + configuration.highlighter + configuration.curator) * 360,
                    color: .blue,
                    label: "Curator",
                    amount: Int(Double(totalAmount) * configuration.curator),
                    animationProgress: animationProgress
                )
                
                SplitSegment(
                    startAngle: (configuration.author + configuration.highlighter + configuration.curator) * 360,
                    endAngle: 360,
                    color: .gray,
                    label: "Platform",
                    amount: Int(Double(totalAmount) * configuration.platform),
                    animationProgress: animationProgress
                )
                
                // Center total
                VStack {
                    Text("\(totalAmount)")
                        .font(.ds.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text("sats")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                }
                .scaleEffect(animationProgress)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(height: 200)
    }
}

struct SplitSegment: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    let label: String
    let amount: Int
    let animationProgress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 10
            
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(startAngle - 90),
                    endAngle: .degrees(startAngle + (endAngle - startAngle) * Double(animationProgress) - 90),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color.opacity(0.8))
            .overlay(
                Path { path in
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle - 90),
                        endAngle: .degrees(startAngle + (endAngle - startAngle) * Double(animationProgress) - 90),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .stroke(color, lineWidth: 2)
            )
        }
    }
}

struct PaymentStatusIndicator: View {
    let payment: LightningService.ActivePayment
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                statusIcon
                    .scaleEffect(pulseAnimation ? 1.2 : 1)
                
                Text(statusText)
                    .font(.ds.callout)
                    .foregroundColor(.ds.textSecondary)
            }
            
            if case .processing = payment.status {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.orange)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch payment.status {
        case .pending:
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
        case .processing:
            Image(systemName: "bolt.circle.fill")
                .foregroundColor(.orange)
        case .splitting:
            Image(systemName: "arrow.triangle.branch")
                .foregroundColor(.blue)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .preparing:
            Image(systemName: "gearshape.fill")
                .foregroundColor(.gray)
        case .sending:
            Image(systemName: "paperplane.fill")
                .foregroundColor(.blue)
        }
    }
    
    private var statusText: String {
        switch payment.status {
        case .pending:
            return "Preparing payment..."
        case .processing:
            return "Processing payment..."
        case .splitting:
            return "Distributing splits..."
        case .completed:
            return "Payment complete!"
        case .failed:
            return "Payment failed"
        case .preparing:
            return "Preparing transaction..."
        case .sending:
            return "Sending payment..."
        }
    }
}

// MARK: - Particle Effects

struct ParticleEffectsLayer: View {
    @Binding var particles: [LightningParticle]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                LightningParticleView(particle: particle)
            }
        }
    }
}

struct LightningParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let targetY: CGFloat
    let color: Color
    let size: CGFloat
    let duration: TimeInterval
    let createdAt = Date()
}

struct LightningParticleView: View {
    let particle: LightningParticle
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [particle.color, particle.color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .position(x: particle.x, y: particle.y - offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: particle.duration)) {
                    offset = particle.y - particle.targetY
                    opacity = 0
                }
            }
    }
}

// MARK: - Additional Supporting Views

struct SplitFlowVisualization: View {
    let payment: LightningService.ActivePayment?
    let animationProgress: CGFloat
    @Binding var particles: [LightningParticle]
    
    var body: some View {
        // Implementation of split flow visualization
        // This would show animated paths from the source to each recipient
        Text("Split Flow Visualization")
            .font(.ds.caption)
            .foregroundColor(.ds.textSecondary)
    }
}

struct SplitProgressRow: View {
    let split: LightningService.PaymentSplit
    let animationProgress: CGFloat
    
    var body: some View {
        HStack {
            Image(systemName: split.type.icon)
                .font(.title3)
                .foregroundColor(split.type.color)
                .scaleEffect(animationProgress)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(split.recipientName)
                    .font(.ds.callout)
                    .fontWeight(.medium)
                
                Text("\(split.amount) sats (\(Int(split.percentage * 100))%)")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
            
            Spacer()
            
            statusView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ds.surface.opacity(0.5))
                .opacity(animationProgress)
        )
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch split.status {
        case .pending:
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
        case .sending:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
    }
}

struct TransactionSummaryCard: View {
    let payment: LightningService.ActivePayment
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Transaction Summary")
                    .font(.ds.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(payment.timestamp.formatted(.relative(presentation: .named)))
                    .font(.ds.caption)
                    .foregroundColor(.ds.textSecondary)
            }
            
            Divider()
            
            // Total amount
            HStack {
                Text("Total Amount")
                    .font(.ds.callout)
                    .foregroundColor(.ds.textSecondary)
                
                Spacer()
                
                Text("\(payment.totalAmount) sats")
                    .font(.ds.callout)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
            
            // Split details
            ForEach(payment.splits) { split in
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: split.type.icon)
                            .font(.caption)
                            .foregroundColor(split.type.color)
                        
                        Text(split.recipientName)
                            .font(.ds.caption)
                    }
                    
                    Spacer()
                    
                    Text("\(split.amount) sats")
                        .font(.ds.caption)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ds.backgroundSecondary)
        )
    }
}

struct ConfettiParticle: View {
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    private let color = [Color.orange, .yellow, .green, .blue, .purple].randomElement()!
    private let size = CGFloat.random(in: 8...16)
    private let shape = [true, false].randomElement()! // true = circle, false = rectangle
    
    var body: some View {
        Group {
            if shape {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: size, height: size * 0.6)
            }
        }
        .rotationEffect(.degrees(rotation))
        .offset(offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: Double.random(in: 2...3))) {
                offset = CGSize(
                    width: .random(in: -200...200),
                    height: .random(in: -300...100)
                )
                rotation = .random(in: -720...720)
                opacity = 0
            }
        }
    }
}

struct CustomSplitEditorView: View {
    @Binding var configuration: LightningService.SplitConfiguration
    @Environment(\.dismiss) var dismiss
    
    @State private var authorPercentage: Double = 50
    @State private var highlighterPercentage: Double = 30
    @State private var curatorPercentage: Double = 15
    @State private var platformPercentage: Double = 5
    
    var body: some View {
        NavigationView {
            Form {
                Section("Split Configuration") {
                    VStack(spacing: 20) {
                        SliderRow(
                            label: "Author",
                            value: $authorPercentage,
                            color: .purple
                        )
                        
                        SliderRow(
                            label: "Highlighter",
                            value: $highlighterPercentage,
                            color: .orange
                        )
                        
                        SliderRow(
                            label: "Curator",
                            value: $curatorPercentage,
                            color: .blue
                        )
                        
                        SliderRow(
                            label: "Platform",
                            value: $platformPercentage,
                            color: .gray
                        )
                    }
                    .padding(.vertical)
                }
                
                Section {
                    HStack {
                        Text("Total")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(authorPercentage + highlighterPercentage + curatorPercentage + platformPercentage))%")
                            .fontWeight(.bold)
                            .foregroundColor(totalIs100 ? .green : .red)
                    }
                }
            }
            .navigationTitle("Custom Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSplit()
                    }
                    .disabled(!totalIs100)
                }
            }
        }
        .onAppear {
            authorPercentage = configuration.author * 100
            highlighterPercentage = configuration.highlighter * 100
            curatorPercentage = configuration.curator * 100
            platformPercentage = configuration.platform * 100
        }
    }
    
    private var totalIs100: Bool {
        abs((authorPercentage + highlighterPercentage + curatorPercentage + platformPercentage) - 100) < 0.1
    }
    
    private func saveSplit() {
        configuration = LightningService.SplitConfiguration(
            author: authorPercentage / 100,
            highlighter: highlighterPercentage / 100,
            curator: curatorPercentage / 100,
            platform: platformPercentage / 100
        )
        dismiss()
    }
}

struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.ds.callout)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.ds.callout.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: 0...100, step: 1)
                .tint(color)
        }
    }
}

// MARK: - Preview
struct LightningPaymentFlowView_Previews: PreviewProvider {
    static var previews: some View {
        LightningPaymentFlowView(
            highlight: HighlightEvent(
                content: "Test highlight",
                context: nil,
                source: nil,
                author: "author_pubkey",
                comment: nil
            ),
            authorProfile: nil,
            highlighterProfile: nil,
            curatorProfile: nil
        )
    }
}