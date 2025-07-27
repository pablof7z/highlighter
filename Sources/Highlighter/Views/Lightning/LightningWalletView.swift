import SwiftUI
import NDKSwift

struct LightningWalletView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var lightning = LightningService()
    @State private var showConnectSheet = false
    @State private var showSplitConfiguration = false
    @State private var selectedTransaction: LightningService.ZapTransaction?
    @State private var pulseAnimation = false
    @State private var balanceRevealAnimation = false
    @State private var connectionString = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    // Wallet Status Card
                    walletStatusCard
                        .premiumEntrance(delay: 0.1)
                    
                    if lightning.isConnected {
                        // Balance Card
                        balanceCard
                            .premiumEntrance(delay: 0.2)
                        
                        // Split Configuration
                        splitConfigurationCard
                            .premiumEntrance(delay: 0.3)
                        
                        // Recent Transactions
                        if !lightning.recentZaps.isEmpty {
                            recentTransactionsSection
                                .premiumEntrance(delay: 0.4)
                        }
                    }
                }
                .padding(.horizontal, .ds.screenPadding)
                .padding(.bottom, 100)
            }
            .background(
                ZStack {
                    DesignSystem.Colors.background
                    MeshGradientBackground()
                        .opacity(0.3)
                        .ignoresSafeArea()
                }
            )
            .navigationTitle("Lightning Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showConnectSheet) {
            ConnectWalletSheet(
                connectionString: $connectionString,
                onConnect: { connection in
                    Task {
                        do {
                            try await lightning.connectWallet(connectionString: connection)
                        } catch {
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showSplitConfiguration) {
            SplitConfigurationSheet(
                configuration: lightning.splitConfig,
                onSave: { config in
                    lightning.updateSplitConfiguration(config)
                }
            )
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailSheet(transaction: transaction)
        }
        .onAppear {
            lightning.setNDK(appState.ndk!, signer: appState.activeSigner)
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var walletStatusCard: some View {
        VStack(spacing: .ds.medium) {
            HStack {
                VStack(alignment: .leading, spacing: .ds.small) {
                    HStack(spacing: .ds.small) {
                        Circle()
                            .fill(lightning.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(lightning.isConnected ? Color.green : Color.red, lineWidth: 2)
                                    .scaleEffect(pulseAnimation ? 1.5 : 1)
                                    .opacity(pulseAnimation ? 0 : 1)
                            )
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                                    pulseAnimation = true
                                }
                            }
                        
                        Text(lightning.isConnected ? "Connected" : "Not Connected")
                            .font(.ds.headline)
                            .foregroundColor(.ds.text)
                    }
                    
                    if let walletInfo = lightning.walletInfo {
                        Text(walletInfo.alias)
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if lightning.isConnected {
                        lightning.disconnectWallet()
                    } else {
                        showConnectSheet = true
                    }
                }) {
                    Label(
                        lightning.isConnected ? "Disconnect" : "Connect",
                        systemImage: lightning.isConnected ? "bolt.slash" : "bolt"
                    )
                    .font(.ds.footnoteMedium)
                }
                .unifiedSecondaryButton()
            }
            
            if let error = lightning.connectionError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.ds.error)
                    Text(error)
                        .font(.ds.caption)
                        .foregroundColor(.ds.error)
                    Spacer()
                }
                .padding(.top, .ds.small)
            }
        }
        .padding(.ds.medium)
        .modernCard()
    }
    
    private var balanceCard: some View {
        let balanceView = VStack(alignment: .leading, spacing: .ds.micro) {
            Text("Balance")
                .font(.ds.caption)
                .foregroundColor(.ds.textSecondary)
            
            HStack(alignment: .firstTextBaseline, spacing: .ds.micro) {
                Text("\(lightning.balance.formatted())")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.ds.text)
                
                Text("sats")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
            }
        }
        
        let lightningIcon = Image(systemName: "bolt.fill")
            .font(.system(size: 30))
            .foregroundColor(.orange)
        
        return VStack(spacing: .ds.medium) {
            HStack {
                balanceView
                
                Spacer()
                
                lightningIcon
            }
        }
        .padding(.ds.large)
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.1),
                    Color.orange.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: .ds.large, style: .continuous))
        .modernCard()
    }
    
    @ViewBuilder
    private var splitConfigurationCard: some View {
        VStack(spacing: .ds.medium) {
            HStack {
                Label("Smart Splits", systemImage: "chart.pie.fill")
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                
                Spacer()
                
                Button("Configure") {
                    showSplitConfiguration = true
                    HapticManager.shared.impact(.light)
                }
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.primary)
            }
            
            // Visual split representation
            HStack(spacing: .ds.small) {
                SplitIndicator(
                    label: "Author",
                    percentage: lightning.splitConfig.authorPercentage,
                    color: .blue
                )
                
                SplitIndicator(
                    label: "Highlighter",
                    percentage: lightning.splitConfig.highlighterPercentage,
                    color: .orange
                )
                
                SplitIndicator(
                    label: "Curator",
                    percentage: lightning.splitConfig.curatorPercentage,
                    color: .purple
                )
            }
        }
        .padding(.ds.medium)
        .modernCard()
    }
    
    @ViewBuilder
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            HStack {
                Label("Recent Zaps", systemImage: "clock.arrow.circlepath")
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                
                Spacer()
            }
            
            VStack(spacing: .ds.small) {
                ForEach(lightning.recentZaps) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        onTap: {
                            selectedTransaction = transaction
                            HapticManager.shared.impact(.light)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SplitIndicator: View {
    let label: String
    let percentage: Double
    let color: Color
    @State private var animatedPercentage: Double = 0
    
    var body: some View {
        VStack(spacing: .ds.micro) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: animatedPercentage)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage * 100))%")
                    .font(.ds.captionMedium)
                    .foregroundColor(.ds.text)
            }
            
            Text(label)
                .font(.ds.micro)
                .foregroundColor(.ds.textSecondary)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedPercentage = percentage
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: LightningService.ZapTransaction
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(isPressed ? 360 : 0))
                }
                
                VStack(alignment: .leading, spacing: .ds.micro) {
                    Text(transaction.formattedAmount)
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    if let comment = transaction.comment {
                        Text(comment)
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: .ds.micro) {
                    Text(transaction.timestamp.formatted(.relative(presentation: .named)))
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<transaction.splits.count, id: \.self) { _ in
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.ds.caption)
                    .foregroundColor(.ds.textTertiary)
            }
            .padding(.ds.base)
            .background(Color.ds.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        } perform: {
            onTap()
        }
    }
}

// MARK: - Sheets

struct ConnectWalletSheet: View {
    @Binding var connectionString: String
    let onConnect: (String) -> Void
    @State private var isScanning = false
    @State private var showPasteAnimation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .ds.large) {
                // Header illustration
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.2), .orange.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse)
                }
                .padding(.top, .ds.large)
                
                VStack(spacing: .ds.small) {
                    Text("Connect Your Lightning Wallet")
                        .font(.ds.title2)
                        .foregroundColor(.ds.text)
                    
                    Text("Use Nostr Wallet Connect to link your Lightning wallet")
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Connection string input
                VStack(alignment: .leading, spacing: .ds.small) {
                    Label("Connection String", systemImage: "link")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.textSecondary)
                    
                    HStack {
                        TextField("nostr+walletconnect://...", text: $connectionString)
                            .textFieldStyle(.plain)
                            .font(.ds.callout)
                        
                        if !connectionString.isEmpty {
                            Button(action: {
                                connectionString = ""
                                HapticManager.shared.impact(.light)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.ds.textTertiary)
                            }
                        }
                    }
                    .padding(.ds.base)
                    .background(Color.ds.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                }
                
                HStack(spacing: .ds.medium) {
                    Button(action: {
                        if let pasteString = UIPasteboard.general.string {
                            connectionString = pasteString
                            showPasteAnimation = true
                            HapticManager.shared.notification(.success)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showPasteAnimation = false
                            }
                        }
                    }) {
                        Label("Paste", systemImage: showPasteAnimation ? "checkmark" : "doc.on.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .unifiedSecondaryButton()
                    .disabled(UIPasteboard.general.string == nil)
                    
                    Button(action: {
                        isScanning = true
                        HapticManager.shared.impact(.light)
                    }) {
                        Label("Scan QR", systemImage: "qrcode.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .unifiedSecondaryButton()
                }
                
                Spacer()
                
                Button(action: {
                    onConnect(connectionString)
                    dismiss()
                }) {
                    Text("Connect Wallet")
                        .frame(maxWidth: .infinity)
                }
                .unifiedPrimaryButton()
                .disabled(connectionString.isEmpty || !connectionString.hasPrefix("nostr+walletconnect://"))
            }
            .padding(.horizontal, .ds.screenPadding)
            .navigationTitle("Connect Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SplitConfigurationSheet: View {
    @State var configuration: LightningService.SplitConfiguration
    let onSave: (LightningService.SplitConfiguration) -> Void
    @State private var showInvalidAlert = false
    @Environment(\.dismiss) var dismiss
    
    var totalPercentage: Double {
        configuration.authorPercentage + configuration.highlighterPercentage + configuration.curatorPercentage
    }
    
    var isValid: Bool {
        abs(totalPercentage - 1.0) < 0.001
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .ds.large) {
                // Visual representation
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.ds.surfaceSecondary)
                        .frame(width: 200, height: 200)
                    
                    // Pie chart
                    PieChart(
                        data: [
                            (value: configuration.authorPercentage, color: .blue),
                            (value: configuration.highlighterPercentage, color: .orange),
                            (value: configuration.curatorPercentage, color: .purple)
                        ]
                    )
                    .frame(width: 180, height: 180)
                }
                .padding(.top, .ds.large)
                
                // Sliders
                VStack(spacing: .ds.medium) {
                    SplitSlider(
                        label: "Author",
                        value: $configuration.authorPercentage,
                        color: .blue
                    )
                    
                    SplitSlider(
                        label: "Highlighter",
                        value: $configuration.highlighterPercentage,
                        color: .orange
                    )
                    
                    SplitSlider(
                        label: "Curator",
                        value: $configuration.curatorPercentage,
                        color: .purple
                    )
                }
                
                // Total indicator
                HStack {
                    Text("Total")
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    Spacer()
                    
                    Text("\(Int(totalPercentage * 100))%")
                        .font(.ds.bodyMedium)
                        .foregroundColor(isValid ? .green : .red)
                        .contentTransition(.numericText())
                }
                .padding()
                .background(Color.ds.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                
                if !isValid {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.ds.error)
                        Text("Splits must total 100%")
                            .font(.ds.caption)
                            .foregroundColor(.ds.error)
                        Spacer()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if isValid {
                        onSave(configuration)
                        dismiss()
                    } else {
                        showInvalidAlert = true
                        HapticManager.shared.notification(.error)
                    }
                }) {
                    Text("Save Configuration")
                        .frame(maxWidth: .infinity)
                }
                .unifiedPrimaryButton()
                .disabled(!isValid)
            }
            .padding(.horizontal, .ds.screenPadding)
            .navigationTitle("Configure Splits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Invalid Configuration", isPresented: $showInvalidAlert) {
            Button("OK") {}
        } message: {
            Text("Please adjust the percentages to total 100%")
        }
    }
}

struct SplitSlider: View {
    let label: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.small) {
            HStack {
                Label(label, systemImage: "circle.fill")
                    .font(.ds.bodyMedium)
                    .foregroundColor(.ds.text)
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(color, color)
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.ds.bodyMedium)
                    .foregroundColor(.ds.text)
                    .contentTransition(.numericText())
            }
            
            Slider(value: $value, in: 0...1, step: 0.05) {
                EmptyView()
            } onEditingChanged: { _ in
                HapticManager.shared.impact(.light)
            }
            .tint(color)
        }
    }
}

struct TransactionDetailSheet: View {
    let transaction: LightningService.ZapTransaction
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    // Header with total amount
                    VStack(spacing: .ds.small) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.2), .orange.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text(transaction.formattedAmount)
                            .font(.ds.largeTitle)
                            .foregroundColor(.ds.text)
                        
                        Text(transaction.timestamp.formatted(.dateTime))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                    .padding(.top, .ds.large)
                    
                    if let comment = transaction.comment {
                        VStack(alignment: .leading, spacing: .ds.small) {
                            Label("Comment", systemImage: "text.bubble")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.textSecondary)
                            
                            Text(comment)
                                .font(.ds.body)
                                .foregroundColor(.ds.text)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.ds.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                        }
                    }
                    
                    // Split breakdown
                    VStack(alignment: .leading, spacing: .ds.medium) {
                        Label("Payment Splits", systemImage: "chart.pie")
                            .font(.ds.headline)
                            .foregroundColor(.ds.text)
                        
                        ForEach(transaction.splits, id: \.paymentHash) { split in
                            SplitDetailRow(split: split, profiles: [:])
                        }
                    }
                }
                .padding(.horizontal, .ds.screenPadding)
                .padding(.bottom, .ds.large)
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SplitDetailRow: View {
    let split: LightningService.SubTransaction
    let profiles: [String: NDKUserProfile]
    
    var roleIcon: String {
        switch split.role {
        case .author: return "person.text.rectangle"
        case .highlighter: return "highlighter"
        case .curator: return "person.crop.square.filled.and.at.rectangle"
        }
    }
    
    var roleColor: Color {
        switch split.role {
        case .author: return .blue
        case .highlighter: return .orange
        case .curator: return .purple
        }
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(roleColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: roleIcon)
                    .font(.system(size: 16))
                    .foregroundColor(roleColor)
            }
            
            VStack(alignment: .leading, spacing: .ds.micro) {
                Text(split.role.rawValue.capitalized)
                    .font(.ds.footnoteMedium)
                    .foregroundColor(.ds.text)
                
                if let profile = profiles[split.recipientPubkey] {
                    Text(profile.displayName ?? PubkeyFormatter.formatShort(split.recipientPubkey))
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                } else {
                    Text(PubkeyFormatter.formatShort(split.recipientPubkey))
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                }
            }
            
            Spacer()
            
            Text("\(split.amount) sats")
                .font(.ds.bodyMedium)
                .foregroundColor(.ds.text)
        }
        .padding(.ds.base)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
    }
}

// MARK: - Pie Chart

struct PieChart: View {
    let data: [(value: Double, color: Color)]
    @State private var animationProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: data[index].color
                    )
                    .scaleEffect(animationProgress)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: animationProgress
                    )
                }
            }
            .onAppear {
                animationProgress = 1
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let values = data.prefix(index).map { $0.value }
        let sum = values.reduce(0, +)
        return .degrees(sum * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let values = data.prefix(index + 1).map { $0.value }
        let sum = values.reduce(0, +)
        return .degrees(sum * 360 - 90)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview

#Preview {
    LightningWalletView()
        .environmentObject(AppState())
}