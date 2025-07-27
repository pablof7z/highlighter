import Foundation
import NDKSwift
import Combine
import SwiftUI

/// Lightning service for managing payments using NDKSwift's built-in functionality
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
    private var nwcWallet: NDKNWCWallet?
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
        
        static let article = SplitConfiguration(
            author: 0.7,
            highlighter: 0.0,
            curator: 0.25,
            platform: 0.05
        )
    }
    
    @Published var splitConfiguration = SplitConfiguration.highlight
    
    // MARK: - Initialization
    init() {
        loadSavedConfiguration()
    }
    
    // MARK: - Public Methods
    
    func connectWallet(connectionString: String) async throws {
        guard let ndk = ndk else { throw LightningError.ndkNotInitialized }
        
        // Create NWC wallet using NDKSwift
        let wallet = try await NDKNWCWallet(ndk: ndk, connectionURI: connectionString)
        
        // Connect the wallet
        try await wallet.connect()
        
        // Configure NDK's zap manager with the wallet
        await ndk.zapManager.configureDefaults(nwcWallet: wallet)
        
        self.nwcWallet = wallet
        
        // Update connection state
        isConnected = true
        
        // Get wallet info
        if let info = await wallet.walletInfo {
            walletInfo = WalletInfo(
                alias: info.alias,
                balance: info.balance?.balance_msat ?? 0,
                methods: info.methods
            )
            balance = Int((info.balance?.balance_msat ?? 0) / 1000) // Convert millisats to sats
        }
        
        // Save connection for persistence
        saveConnectionString(connectionString)
        
        // Start balance updates
        startBalanceUpdates()
    }
    
    func disconnectWallet() {
        Task {
            if let wallet = nwcWallet {
                await wallet.disconnect()
            }
            nwcWallet = nil
            isConnected = false
            walletInfo = nil
            balance = 0
            clearConnectionString()
        }
    }
    
    /// Send a smart zap with splits using NDKSwift
    func sendSmartZap(
        amount: Int,
        to highlight: HighlightEvent,
        article: Article? = nil,
        comment: String? = nil
    ) async throws -> ZapTransaction {
        guard let ndk = ndk else { throw LightningError.ndkNotInitialized }
        guard nwcWallet != nil else { throw LightningError.walletNotConnected }
        
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
            
            // Create transactions for each split
            var transactions: [SubTransaction] = []
            
            for split in splits {
                if split.amount > 0 {
                    // Create NDKUser for recipient
                    let recipient = NDKUser(pubkey: split.recipientPubkey)
                    recipient.ndk = ndk
                    
                    // Create NDKEvent for the highlight reference if this is the original zap
                    var eventToZap: NDKEvent? = nil
                    if split.isOriginal {
                        // Find or create the highlight event
                        eventToZap = try await fetchHighlightEvent(highlight.id, ndk: ndk)
                    }
                    
                    // Use NDK's zap manager to send the zap
                    let zapResult = try await ndk.zapManager.zap(
                        event: eventToZap,
                        to: recipient,
                        amountSats: Int64(split.amount),
                        comment: split.isOriginal ? comment : "Split payment from highlight zap",
                        preferredType: .lightning
                    )
                    
                    // Extract payment info from result
                    let paymentHash = extractPaymentHash(from: zapResult)
                    
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
    
    /// Send a simple zap without splits using NDKSwift
    func sendSimpleZap(
        amount: Int,
        to pubkey: String,
        comment: String? = nil
    ) async throws {
        guard let ndk = ndk else { throw LightningError.ndkNotInitialized }
        guard nwcWallet != nil else { throw LightningError.walletNotConnected }
        
        // Create recipient user
        let recipient = NDKUser(pubkey: pubkey)
        recipient.ndk = ndk
        
        // Send zap using NDK
        _ = try await ndk.zapManager.zap(
            to: recipient,
            amountSats: Int64(amount),
            comment: comment,
            preferredType: .lightning
        )
        
        HapticManager.shared.notification(.success)
    }
    
    // MARK: - Configuration
    
    func updateSplitConfiguration(_ config: SplitConfiguration) {
        guard config.isValid else { return }
        splitConfiguration = config
        saveSplitConfiguration()
    }
    
    // MARK: - NDK Integration
    
    func setNDK(_ ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        
        // Auto-reconnect if we have saved credentials
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
        
        // Highlighter gets their share
        let highlighterAmount = Int(Double(totalAmount) * splitConfiguration.highlighter)
        if highlighterAmount > 0 {
            splits.append(PaymentSplit(
                recipientPubkey: highlighterPubkey,
                amount: highlighterAmount,
                role: .highlighter,
                isOriginal: true
            ))
        }
        
        // Author gets their share if different from highlighter
        if let authorPubkey = authorPubkey,
           authorPubkey != highlighterPubkey {
            let authorAmount = Int(Double(totalAmount) * splitConfiguration.author)
            if authorAmount > 0 {
                splits.append(PaymentSplit(
                    recipientPubkey: authorPubkey,
                    amount: authorAmount,
                    role: .author,
                    isOriginal: false
                ))
            }
        }
        
        // Curator gets their share if present and different
        if let curatorPubkey = curatorPubkey,
           curatorPubkey != highlighterPubkey,
           curatorPubkey != authorPubkey {
            let curatorAmount = Int(Double(totalAmount) * splitConfiguration.curator)
            if curatorAmount > 0 {
                splits.append(PaymentSplit(
                    recipientPubkey: curatorPubkey,
                    amount: curatorAmount,
                    role: .curator,
                    isOriginal: false
                ))
            }
        }
        
        // Platform fee (if configured)
        let platformPubkey = "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2" // jack
        let platformAmount = Int(Double(totalAmount) * splitConfiguration.platform)
        if platformAmount > 0 {
            splits.append(PaymentSplit(
                recipientPubkey: platformPubkey,
                amount: platformAmount,
                role: .platform,
                isOriginal: false
            ))
        }
        
        // Ensure total doesn't exceed original amount
        let totalSplit = splits.reduce(0) { $0 + $1.amount }
        if totalSplit > totalAmount {
            // Scale down proportionally if needed
            let scale = Double(totalAmount) / Double(totalSplit)
            splits = splits.map { split in
                var adjusted = split
                adjusted.amount = Int(Double(split.amount) * scale)
                return adjusted
            }
        }
        
        return splits
    }
    
    private func fetchHighlightEvent(_ eventId: String, ndk: NDK) async throws -> NDKEvent? {
        // Try to fetch the highlight event
        let filter = NDKFilter(ids: [eventId])
        return try await ndk.fetchEvent(filter: filter)
    }
    
    private func extractPaymentHash(from zapResult: ZapResult) -> String {
        // Extract payment hash from the zap result
        switch zapResult {
        case .lightning(let receipt):
            return receipt.paymentHash ?? "unknown"
        case .nutzap:
            return "nutzap-\(UUID().uuidString)"
        }
    }
    
    private func startBalanceUpdates() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.updateBalance()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateBalance() async {
        guard let wallet = nwcWallet else { return }
        
        if let newBalance = try? await wallet.getBalance() {
            await MainActor.run {
                self.balance = Int(newBalance / 1000) // Convert millisats to sats
            }
        }
    }
    
    private func updatePendingZapStatus(_ id: UUID, status: PendingZap.Status) {
        if let index = pendingZaps.firstIndex(where: { $0.id == id }) {
            pendingZaps[index].status = status
        }
    }
    
    // MARK: - Persistence
    
    private func saveConnectionString(_ connection: String) {
        UserDefaults.standard.set(connection, forKey: "lightning.nwc.connection")
    }
    
    private func getSavedConnectionString() -> String? {
        UserDefaults.standard.string(forKey: "lightning.nwc.connection")
    }
    
    private func clearConnectionString() {
        UserDefaults.standard.removeObject(forKey: "lightning.nwc.connection")
    }
    
    private func saveSplitConfiguration() {
        let config = [
            "author": splitConfiguration.author,
            "highlighter": splitConfiguration.highlighter,
            "curator": splitConfiguration.curator,
            "platform": splitConfiguration.platform
        ]
        UserDefaults.standard.set(config, forKey: "lightning.splits.config")
    }
    
    private func loadSavedConfiguration() {
        if let saved = UserDefaults.standard.dictionary(forKey: "lightning.splits.config") as? [String: Double] {
            splitConfiguration = SplitConfiguration(
                author: saved["author"] ?? 0.5,
                highlighter: saved["highlighter"] ?? 0.3,
                curator: saved["curator"] ?? 0.15,
                platform: saved["platform"] ?? 0.05
            )
        }
    }
}

// MARK: - Supporting Types

struct WalletInfo {
    let alias: String
    let balance: Int64
    let methods: [String]
}

struct ZapTransaction: Identifiable {
    let id: UUID
    let totalAmount: Int
    let splits: [SubTransaction]
    let highlightId: String?
    let comment: String?
    let timestamp: Date
}

struct SubTransaction {
    let recipientPubkey: String
    let amount: Int
    let role: PaymentRole
    let paymentHash: String
    let timestamp: Date
}

struct PendingZap: Identifiable {
    let id: UUID
    let amount: Int
    let recipientPubkey: String
    var status: Status
    
    enum Status {
        case calculating
        case sending
        case completed
        case failed(String)
    }
}

struct PaymentSplit {
    let recipientPubkey: String
    var amount: Int
    let role: PaymentRole
    let isOriginal: Bool
}

enum PaymentRole: String {
    case highlighter
    case author
    case curator
    case platform
}

struct ActivePayment: Identifiable {
    let id: UUID
    let totalAmount: Int
    let splits: [PaymentSplit]
    let highlightId: String?
    let comment: String?
    var status: PaymentStatus
    let timestamp: Date
}

enum PaymentStatus: Equatable {
    case pending
    case preparing
    case processing
    case splitting
    case sending
    case completed(ZapTransaction)
    case failed(String)
    
    static func == (lhs: PaymentStatus, rhs: PaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending),
             (.preparing, .preparing),
             (.processing, .processing),
             (.splitting, .splitting),
             (.sending, .sending):
            return true
        case let (.completed(lhs), .completed(rhs)):
            return lhs.id == rhs.id
        case let (.failed(lhs), .failed(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
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
    case invalidLNURL
    case failedToGetInvoice
    
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
        case .invalidLNURL:
            return "Invalid LNURL"
        case .failedToGetInvoice:
            return "Failed to get Lightning invoice"
        }
    }
}