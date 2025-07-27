import Foundation
import NDKSwift

/// Nostr Wallet Connect (NWC) implementation for Lightning wallet integration
@MainActor
class NostrWalletConnect {
    private let ndk: NDK
    private let walletPubkey: String
    private let secret: String
    private let relay: String
    private var dataSource: NDKDataSource<[NDKEvent]>?
    
    struct WalletInfo {
        let alias: String
        let pubkey: String
        let network: String
        let blockHeight: Int
        let blockHash: String
        let methods: [String]
    }
    
    enum NWCError: LocalizedError {
        case invalidConnectionString
        case invalidResponse
        case walletError(String)
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .invalidConnectionString:
                return "Invalid NWC connection string"
            case .invalidResponse:
                return "Invalid response from wallet"
            case .walletError(let message):
                return "Wallet error: \(message)"
            case .timeout:
                return "Request timed out"
            }
        }
    }
    
    init(from connectionString: String, ndk: NDK) throws {
        self.ndk = ndk
        
        // Parse NWC connection string
        // Format: nostr+walletconnect://pubkey?relay=relay-url&secret=secret
        guard let url = URL(string: connectionString),
              url.scheme == "nostr+walletconnect",
              let host = url.host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let relayItem = components.queryItems?.first(where: { $0.name == "relay" }),
              let secretItem = components.queryItems?.first(where: { $0.name == "secret" }),
              let relayValue = relayItem.value,
              let secretValue = secretItem.value else {
            throw NWCError.invalidConnectionString
        }
        
        self.walletPubkey = host
        self.relay = relayValue
        self.secret = secretValue
    }
    
    /// Request wallet information
    func getInfo() async throws -> WalletInfo {
        let request = try await createRequest(method: "get_info", params: [:])
        let response = try await sendRequest(request)
        
        guard let result = response["result"] as? [String: Any] else {
            throw NWCError.invalidResponse
        }
        
        return WalletInfo(
            alias: result["alias"] as? String ?? "Unknown Wallet",
            pubkey: result["pubkey"] as? String ?? walletPubkey,
            network: result["network"] as? String ?? "mainnet",
            blockHeight: result["block_height"] as? Int ?? 0,
            blockHash: result["block_hash"] as? String ?? "",
            methods: result["methods"] as? [String] ?? []
        )
    }
    
    /// Get wallet balance
    func getBalance() async throws -> Int {
        let request = try await createRequest(method: "get_balance", params: [:])
        let response = try await sendRequest(request)
        
        guard let result = response["result"] as? [String: Any],
              let balanceMsat = result["balance"] as? Int else {
            throw NWCError.invalidResponse
        }
        
        // Convert millisats to sats
        return balanceMsat / 1000
    }
    
    /// Pay a Lightning invoice
    func payInvoice(_ invoice: String) async throws -> String {
        let params = ["invoice": invoice]
        let request = try await createRequest(method: "pay_invoice", params: params)
        let response = try await sendRequest(request)
        
        guard let result = response["result"] as? [String: Any],
              let preimage = result["preimage"] as? String else {
            if let error = response["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NWCError.walletError(message)
            }
            throw NWCError.invalidResponse
        }
        
        return preimage
    }
    
    /// Create an invoice
    func makeInvoice(amount: Int, description: String? = nil, expiry: Int? = nil) async throws -> String {
        var params: [String: Any] = ["amount": amount * 1000] // Convert sats to millisats
        
        if let description = description {
            params["description"] = description
        }
        
        if let expiry = expiry {
            params["expiry"] = expiry
        }
        
        let request = try await createRequest(method: "make_invoice", params: params)
        let response = try await sendRequest(request)
        
        guard let result = response["result"] as? [String: Any],
              let invoice = result["invoice"] as? String else {
            throw NWCError.invalidResponse
        }
        
        return invoice
    }
    
    // MARK: - Private Methods
    
    private func createRequest(method: String, params: [String: Any]) async throws -> NDKEvent {
        let requestId = UUID().uuidString
        
        let content: [String: Any] = [
            "method": method,
            "params": params,
            "id": requestId
        ]
        
        let contentData = try JSONSerialization.data(withJSONObject: content)
        let contentString = String(data: contentData, encoding: .utf8) ?? "{}"
        
        // Validate secret is hex
        guard Data(hex: secret) != nil else {
            throw NWCError.invalidConnectionString
        }
        
        // For now, we'll use the app's main signer to sign the event
        // In a real implementation, we'd create a dedicated signer for NWC
        let tags: [[String]] = [
            ["p", walletPubkey]
        ]
        
        // Create event without encryption for now (NIP-04 encryption would be added here)
        let event = NDKEvent(
            kind: 23194, // NWC request kind
            content: contentString,
            tags: tags,
            pubkey: "", // Will be set by signer
            createdAt: Int64(Date().timeIntervalSince1970)
        )
        
        return event
    }
    
    private func sendRequest(_ request: NDKEvent) async throws -> [String: Any] {
        // Publish request to specific relay
        _ = try await ndk.publish(request, to: [relay])
        
        // Set up response listener
        let filter = NDKFilter(
            authors: [walletPubkey],
            kinds: [23195], // NWC response kind
            tags: ["e": Set([request.id])]
        )
        
        // Create data source for receiving response
        let dataSource = await ndk.outbox.observe(
            filter: filter,
            maxAge: 0,
            cachePolicy: .networkOnly
        )
        
        // Use a continuation to handle the async response
        return try await withCheckedThrowingContinuation { continuation in
            var hasResponded = false
            
            Task {
                // Set up timeout
                Task {
                    try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                    if !hasResponded {
                        hasResponded = true
                        continuation.resume(throwing: NWCError.timeout)
                    }
                }
                
                // Listen for response
                for await event in dataSource.events {
                    guard !hasResponded else { break }
                    
                    do {
                        // For now, use unencrypted content
                        // In production, implement NIP-04 decryption here
                        let content = event.content
                        
                        // Parse response
                        guard let data = content.data(using: .utf8),
                              let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            continue
                        }
                        
                        hasResponded = true
                        continuation.resume(returning: response)
                        break
                    } catch {
                        // Continue listening if parsing fails
                        continue
                    }
                }
            }
        }
    }
}

// MARK: - NDKEventKind Extension

// MARK: - Data Extensions

extension Data {
    init?(hex: String) {
        let hex = hex.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard hex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = hex.startIndex
        
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }
        
        self = data
    }
}