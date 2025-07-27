import Foundation
import NDKSwift
import Combine
import SwiftUI

/// Lightning service for managing payments with smart splits
@MainActor
class LightningService: ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var balance: Int = 0
    @Published var recentZaps: [ZapTransaction] = []
    @Published var pendingZaps: [PendingZap] = []
    @Published var connectionError: String?
    @Published var walletInfo: WalletInfo?
    
    // MARK: - Properties
    private var ndk: NDK?
    private var signer: NDKSigner?
    private var nwc: NostrWalletConnect?
    private var cancellables = Set<AnyCancellable>()
    
    // Smart split configurations
    struct SplitConfiguration {
        var author: Double = 0.5
        var highlighter: Double = 0.3
        var curator: Double = 0.15
        var platform: Double = 0.05
        
        var authorPercentage: Double {
            get { author }
            set { author = newValue }
        }
        
        var highlighterPercentage: Double {
            get { highlighter }
            set { highlighter = newValue }
        }
        
        var curatorPercentage: Double {
            get { curator }
            set { curator = newValue }
        }
        
        var isValid: Bool {
            abs((author + highlighter + curator + platform) - 1.0) < 0.001
        }
        
        static let highlight = SplitConfiguration(
            author: 0.5,
            highlighter: 0.3,
            curator: 0.15,
            platform: 0.05
        )
    }
    
    @Published var splitConfig = SplitConfiguration()
    
    // MARK: - Initialization
    init() {
        loadSavedConfiguration()
    }
    
    // MARK: - Public Methods
    
    /// Connect to Lightning wallet via Nostr Wallet Connect
    func connectWallet(connectionString: String) async throws {
        guard let ndk = ndk else { throw LightningError.ndkNotInitialized }
        
        do {
            // Parse NWC connection string
            guard let url = URL(string: connectionString),
                  url.scheme == "nostr+walletconnect" else {
                throw LightningError.invalidConnectionString
            }
            
            // Initialize NWC with parsed parameters
            let nwc = try NostrWalletConnect(from: connectionString, ndk: ndk)
            self.nwc = nwc
            
            // Request wallet info
            let info = try await nwc.getInfo()
            await MainActor.run {
                self.walletInfo = WalletInfo(
                    alias: info.alias,
                    color: "#FF9500", // Default color for now
                    pubkey: info.pubkey,
                    network: info.network,
                    blockHeight: info.blockHeight,
                    methods: info.methods
                )
                self.isConnected = true
                self.connectionError = nil
            }
            
            // Start listening for balance updates
            startBalanceUpdates()
            
            // Save connection for future use
            saveConnectionString(connectionString)
            
            HapticManager.shared.notification(.success)
        } catch {
            await MainActor.run {
                self.connectionError = error.localizedDescription
                self.isConnected = false
            }
            HapticManager.shared.notification(.error)
            throw error
        }
    }
    
    /// Disconnect from Lightning wallet
    func disconnectWallet() {
        nwc = nil
        isConnected = false
        balance = 0
        walletInfo = nil
        clearConnectionString()
        HapticManager.shared.impact(.medium)
    }
    
    /// Send a zap with smart splits
    func sendSmartZap(
        amount: Int,
        to highlight: HighlightEvent,
        article: Article? = nil,
        comment: String? = nil
    ) async throws -> ZapTransaction {
        guard let nwc = nwc else { throw LightningError.walletNotConnected }
        guard ndk != nil else { throw LightningError.ndkNotInitialized }
        
        // Create pending zap for UI feedback
        let pendingZap = PendingZap(
            id: UUID(),
            amount: amount,
            recipientPubkey: highlight.pubkey,
            status: .calculating
        )
        
        await MainActor.run {
            pendingZaps.append(pendingZap)
        }
        
        do {
            // Calculate splits
            let splits = calculateSplits(
                totalAmount: amount,
                highlighterPubkey: highlight.pubkey,
                authorPubkey: highlight.author,
                curatorPubkey: article?.author
            )
            
            // Update pending zap status
            updatePendingZapStatus(pendingZap.id, status: .sending)
            
            // Create zap transactions for each recipient
            var transactions: [SubTransaction] = []
            
            for split in splits {
                if split.amount > 0 {
                    // Create zap request event
                    let zapRequest = try await createZapRequest(
                        amount: split.amount,
                        recipientPubkey: split.recipientPubkey,
                        comment: split.isOriginal ? comment : "Split payment from highlight zap",
                        highlightReference: highlight.id
                    )
                    
                    // Send payment
                    let invoice = try await getInvoiceForZap(
                        zapRequest: zapRequest,
                        recipientPubkey: split.recipientPubkey
                    )
                    
                    let paymentHash = try await nwc.payInvoice(invoice)
                    
                    transactions.append(SubTransaction(
                        recipientPubkey: split.recipientPubkey,
                        amount: split.amount,
                        role: split.role,
                        paymentHash: paymentHash,
                        timestamp: Date()
                    ))
                }
            }
            
            // Create main transaction record
            let transaction = ZapTransaction(
                id: UUID(),
                totalAmount: amount,
                splits: transactions,
                highlightId: highlight.id,
                comment: comment,
                timestamp: Date()
            )
            
            // Update UI
            await MainActor.run {
                recentZaps.insert(transaction, at: 0)
                pendingZaps.removeAll { $0.id == pendingZap.id }
                
                // Trigger success haptics
                HapticManager.shared.notification(.success)
            }
            
            // Publish zap receipt events
            for (split, subTx) in zip(splits, transactions) {
                try await publishZapReceipt(
                    transaction: subTx,
                    originalEvent: highlight.id,
                    split: split
                )
            }
            
            return transaction
            
        } catch {
            updatePendingZapStatus(pendingZap.id, status: .failed(error.localizedDescription))
            
            // Remove failed zap after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.pendingZaps.removeAll { $0.id == pendingZap.id }
            }
            
            HapticManager.shared.notification(.error)
            throw error
        }
    }
    
    /// Send a simple zap without splits
    func sendSimpleZap(
        amount: Int,
        to pubkey: String,
        comment: String? = nil
    ) async throws {
        guard let nwc = nwc else { throw LightningError.walletNotConnected }
        guard ndk != nil else { throw LightningError.ndkNotInitialized }
        
        let zapRequest = try await createZapRequest(
            amount: amount,
            recipientPubkey: pubkey,
            comment: comment,
            highlightReference: nil
        )
        
        let invoice = try await getInvoiceForZap(
            zapRequest: zapRequest,
            recipientPubkey: pubkey
        )
        
        _ = try await nwc.payInvoice(invoice)
        
        HapticManager.shared.notification(.success)
    }
    
    // MARK: - Configuration
    
    func updateSplitConfiguration(_ config: SplitConfiguration) {
        guard config.isValid else { return }
        splitConfig = config
        saveSplitConfiguration()
        HapticManager.shared.impact(.light)
    }
    
    func setNDK(_ ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
        
        // Try to reconnect if we have a saved connection
        if let savedConnection = getSavedConnectionString() {
            Task {
                try? await connectWallet(connectionString: savedConnection)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateSplits(
        totalAmount: Int,
        highlighterPubkey: String,
        authorPubkey: String?,
        curatorPubkey: String?
    ) -> [PaymentSplit] {
        var splits: [PaymentSplit] = []
        
        // Always pay the highlighter
        let highlighterAmount = Int(Double(totalAmount) * splitConfig.highlighterPercentage)
        splits.append(PaymentSplit(
            recipientPubkey: highlighterPubkey,
            amount: highlighterAmount,
            role: .highlighter,
            isOriginal: true
        )
        
        // Pay author if different from highlighter
        if let authorPubkey = authorPubkey, authorPubkey != highlighterPubkey {
            let authorAmount = Int(Double(totalAmount) * splitConfig.authorPercentage)
            splits.append(PaymentSplit(
                recipientPubkey: authorPubkey,
                amount: authorAmount,
                role: .author,
                isOriginal: false
            )
        } else {
            // If highlighter is the author, give them the author portion too
            let extraAmount = Int(Double(totalAmount) * splitConfig.authorPercentage)
            if var highlighterSplit = splits.first {
                highlighterSplit.amount += extraAmount
                splits[0] = highlighterSplit
            }
        }
        
        // Pay curator if exists and different
        if let curatorPubkey = curatorPubkey,
           curatorPubkey != highlighterPubkey && curatorPubkey != authorPubkey {
            let curatorAmount = Int(Double(totalAmount) * splitConfig.curatorPercentage)
            splits.append(PaymentSplit(
                recipientPubkey: curatorPubkey,
                amount: curatorAmount,
                role: .curator,
                isOriginal: false
            )
        } else {
            // Distribute curator portion to highlighter
            let extraAmount = Int(Double(totalAmount) * splitConfig.curatorPercentage)
            if var highlighterSplit = splits.first {
                highlighterSplit.amount += extraAmount
                splits[0] = highlighterSplit
            }
        }
        
        return splits
    }
    
    private func createZapRequest(
        amount: Int,
        recipientPubkey: String,
        comment: String?,
        highlightReference: String?
    ) async throws -> NDKEvent {
        guard let ndk = ndk else {
            throw LightningError.ndkNotInitialized
        }
        guard let signer = signer else {
            throw LightningError.signerNotAvailable
        }
        
        var tags: [[String]] = [
            ["amount", String(amount * 1000)], // Convert sats to millisats
            ["p", recipientPubkey]
        ]
        
        if let highlight = highlightReference {
            tags.append(["e", highlight])
        }
        
        let content = comment ?? ""
        
        return try await NDKEventBuilder(ndk: ndk)
            .kind(9734) // Zap request
            .content(content)
            .tags(tags)
            .build(signer: signer)
    }
    
    private func getInvoiceForZap(zapRequest: NDKEvent, recipientPubkey: String) async throws -> String {
        guard let ndk = ndk else { throw LightningError.ndkNotInitialized }
        
        // Get user's lightning address
        let profileDataSource = await ndk.outbox.observe(
            filter: NDKFilter(
                authors: [recipientPubkey],
                kinds: [0]
            ),
            maxAge: 3600,
            cachePolicy: .cacheWithNetwork
        )
        
        var lightningAddress: String?
        for await event in profileDataSource.events {
            if let profile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                lightningAddress = profile.lud16 ?? profile.lud06
                break
            }
        }
        
        guard let address = lightningAddress else {
            throw LightningError.noLightningAddress
        }
        
        // Get amount from zap request
        var amount = 1000 // Default 1000 sats
        for tag in zapRequest.tags {
            if tag.count >= 2 && tag[0] == "amount" {
                amount = (Int(tag[1]) ?? 1000) / 1000 // Convert millisats to sats
                break
            }
        }
        
        // Serialize zap request for LNURL
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let zapRequestData = try encoder.encode(zapRequest)
        let zapRequestString = String(data: zapRequestData, encoding: .utf8) ?? ""
        
        // Request invoice from LNURL service
        return try await LNURLService.getInvoice(
            for: address,
            amount: amount,
            comment: zapRequest.content.isEmpty ? nil : zapRequest.content,
            zapRequest: zapRequestString
        )
    }
    
    private func publishZapReceipt(
        transaction: SubTransaction,
        originalEvent: String,
        split: PaymentSplit
    ) async throws {
        guard let ndk = ndk,
              let signer = signer else { return }
        
        let tags: [[String]] = [
            ["p", transaction.recipientPubkey],
            ["e", originalEvent],
            ["amount", String(transaction.amount * 1000)],
            ["split-role", split.role.rawValue]
        ]
        
        let event = try await NDKEventBuilder(ndk: ndk)
            .kind(9735) // Zap receipt
            .tags(tags)
            .build(signer: signer)
        
        _ = try await ndk.publish(event)
    }
    
    private func startBalanceUpdates() {
        // Poll balance every 30 seconds
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.updateBalance()
                }
            }
            .store(in: &cancellables)
        
        // Initial balance fetch
        Task {
            await updateBalance()
        }
    }
    
    private func updateBalance() async {
        guard let nwc = nwc else { return }
        
        do {
            let balanceInfo = try await nwc.getBalance()
            await MainActor.run {
                self.balance = balanceInfo / 1000 // Convert millisats to sats
            }
        } catch {
            // Failed to update balance
        }
    }
    
    private func updatePendingZapStatus(_ id: UUID, status: PendingZap.Status) {
        DispatchQueue.main.async {
            if let index = self.pendingZaps.firstIndex(where: { $0.id == id }) {
                self.pendingZaps[index].status = status
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveConnectionString(_ connection: String) {
        do {
            try KeychainManager.shared.save(connection, for: KeychainManager.Keys.nwcConnection)
        } catch {
            // Failed to save NWC connection to keychain
        }
    }
    
    private func getSavedConnectionString() -> String? {
        do {
            return try KeychainManager.shared.retrieve(key: KeychainManager.Keys.nwcConnection)
        } catch {
            // If error is not .noData, log it
            if case KeychainManager.KeychainError.noData = error {
                // Expected when no connection saved
            } else {
                // Failed to retrieve NWC connection from keychain
            }
            return nil
        }
    }
    
    private func clearConnectionString() {
        do {
            try KeychainManager.shared.delete(key: KeychainManager.Keys.nwcConnection)
        } catch {
            // Failed to clear NWC connection from keychain
        }
    }
    
    private func saveSplitConfiguration() {
        UserDefaults.standard.set(splitConfig.authorPercentage, forKey: "highlighter.split.author")
        UserDefaults.standard.set(splitConfig.highlighterPercentage, forKey: "highlighter.split.highlighter")
        UserDefaults.standard.set(splitConfig.curatorPercentage, forKey: "highlighter.split.curator")
    }
    
    private func loadSavedConfiguration() {
        let author = UserDefaults.standard.double(forKey: "highlighter.split.author")
        let highlighter = UserDefaults.standard.double(forKey: "highlighter.split.highlighter")
        let curator = UserDefaults.standard.double(forKey: "highlighter.split.curator")
        
        if author > 0 || highlighter > 0 || curator > 0 {
            splitConfig = SplitConfiguration(
                author: author > 0 ? author : 0.5,
                highlighter: highlighter > 0 ? highlighter : 0.3,
                curator: curator > 0 ? curator : 0.2,
                platform: 0.05
            )
        }
    }
    
    
    // MARK: - Nested Types
    
        struct ZapTransaction: Identifiable, Equatable {
        let id: UUID
        let totalAmount: Int
        let splits: [SubTransaction]
        let highlightId: String
        let comment: String?
        let timestamp: Date
        
        var formattedAmount: String {
            "\(totalAmount.formatted()) sats"
        }
    }
    
        struct SubTransaction: Equatable {
        let recipientPubkey: String
        let amount: Int
        let role: PaymentRole
        let paymentHash: String
        let timestamp: Date
    }
    
        struct PaymentSplit: Identifiable {
        let id = UUID()
        let recipientPubkey: String
        var amount: Int
        let role: PaymentRole
        let isOriginal: Bool // True for the main recipient
        var type: PaymentRole { role } // Alias for compatibility
        var status: SplitStatus = .pending
        
        var recipientName: String {
            switch role {
            case .author: return "Author"
            case .highlighter: return "Highlighter"
            case .curator: return "Curator"
            }
        }
        
        var percentage: Double {
            // Default percentages based on role
            switch role {
            case .highlighter: return 0.5
            case .author: return 0.4
            case .curator: return 0.1
            }
        }
        
        enum SplitStatus {
            case pending
            case sending
            case completed
            case failed
        }
    }
    
        enum PaymentRole: String {
        case author
        case highlighter
        case curator
        
        var icon: String {
            switch self {
            case .author: return "person.fill"
            case .highlighter: return "highlighter"
            case .curator: return "folder.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .author: return DesignSystem.Colors.primary
            case .highlighter: return DesignSystem.Colors.secondary
            case .curator: return DesignSystem.Colors.primaryLight
            }
        }
    }
    
        struct PendingZap: Identifiable {
        let id: UUID
        let amount: Int
        let recipientPubkey: String
        var status: Status
        
        enum Status {
            case calculating
            case sending
            case failed(String)
        }
    }
    
        struct ActivePayment: Identifiable {
        let id: UUID
        let totalAmount: Int
        let splits: [PaymentSplit]
        let highlightId: String?
        let comment: String?
        var status: PaymentStatus
        let timestamp: Date
        
        enum PaymentStatus: Equatable {
            case pending
            case preparing
            case processing
            case splitting
            case sending
            case completed(ZapTransaction)
            case failed(String)
        }
    }
    
        struct WalletInfo {
        let alias: String
        let color: String?
        let pubkey: String
        let network: String
        let blockHeight: Int
        let methods: [String]
    }
    
    // MARK: - Errors
    
        enum LightningError: LocalizedError {
        case walletNotConnected
        case ndkNotInitialized
        case signerNotAvailable
        case invalidConnectionString
        case noLightningAddress
        case insufficientBalance
        case paymentFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .walletNotConnected:
                return "Lightning wallet not connected"
            case .ndkNotInitialized:
                return "NDK not initialized"
            case .signerNotAvailable:
                return "No active signer available"
            case .invalidConnectionString:
                return "Invalid NWC connection string"
            case .noLightningAddress:
                return "Recipient has no Lightning address"
            case .insufficientBalance:
                return "Insufficient balance"
            case .paymentFailed(let reason):
                return "Payment failed: \(reason)"
            }
        }
    }
}

// MARK: - NWC Implementation

/// Simplified NWC implementation
// NostrWalletConnect implementation has been moved to its own file
// See NostrWalletConnect.swift for the full implementation