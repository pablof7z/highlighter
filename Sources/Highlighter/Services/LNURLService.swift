import Foundation

/// Service for handling LNURL protocol operations
@MainActor
class LNURLService {
    
    enum LNURLError: LocalizedError {
        case invalidAddress
        case invalidURL
        case networkError(String)
        case invalidResponse
        case amountOutOfRange(min: Int, max: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidAddress:
                return "Invalid Lightning address"
            case .invalidURL:
                return "Invalid LNURL"
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidResponse:
                return "Invalid response from service"
            case .amountOutOfRange(let min, let max):
                return "Amount must be between \(min) and \(max) sats"
            }
        }
    }
    
    struct LNURLPayResponse {
        let callback: String
        let minSendable: Int
        let maxSendable: Int
        let metadata: String
        let commentAllowed: Int?
        let tag: String
    }
    
    /// Resolve a Lightning address to LNURL
    static func resolveLightningAddress(_ address: String) async throws -> URL {
        let parts = address.split(separator: "@")
        guard parts.count == 2 else {
            throw LNURLError.invalidAddress
        }
        
        let user = parts[0]
        let domain = parts[1]
        
        let urlString = "https://\(domain)/.well-known/lnurlp/\(user)"
        guard let url = URL(string: urlString) else {
            throw LNURLError.invalidURL
        }
        
        return url
    }
    
    /// Fetch LNURL pay parameters
    static func fetchPayParameters(from url: URL) async throws -> LNURLPayResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LNURLError.networkError("Failed to fetch LNURL parameters")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw LNURLError.invalidResponse
        }
        
        guard let callback = json["callback"] as? String,
              let minSendable = json["minSendable"] as? Int,
              let maxSendable = json["maxSendable"] as? Int,
              let metadata = json["metadata"] as? String,
              let tag = json["tag"] as? String else {
            throw LNURLError.invalidResponse
        }
        
        return LNURLPayResponse(
            callback: callback,
            minSendable: minSendable / 1000, // Convert millisats to sats
            maxSendable: maxSendable / 1000, // Convert millisats to sats
            metadata: metadata,
            commentAllowed: json["commentAllowed"] as? Int,
            tag: tag
        )
    }
    
    /// Request an invoice from LNURL service
    static func requestInvoice(
        payResponse: LNURLPayResponse,
        amount: Int,
        comment: String? = nil,
        zapRequest: String? = nil
    ) async throws -> String {
        // Validate amount
        guard amount >= payResponse.minSendable && amount <= payResponse.maxSendable else {
            throw LNURLError.amountOutOfRange(min: payResponse.minSendable, max: payResponse.maxSendable)
        }
        
        guard var components = URLComponents(string: payResponse.callback) else {
            throw LNURLError.invalidURL
        }
        
        var queryItems = [
            URLQueryItem(name: "amount", value: String(amount * 1000)) // Convert sats to millisats
        ]
        
        if let comment = comment,
           let commentAllowed = payResponse.commentAllowed,
           commentAllowed > 0 {
            let trimmedComment = String(comment.prefix(commentAllowed)
            queryItems.append(URLQueryItem(name: "comment", value: trimmedComment)
        }
        
        if let zapRequest = zapRequest {
            queryItems.append(URLQueryItem(name: "nostr", value: zapRequest)
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw LNURLError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LNURLError.networkError("Failed to get invoice")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let invoice = json["pr"] as? String else {
            throw LNURLError.invalidResponse
        }
        
        return invoice
    }
    
    /// Get invoice for a Lightning address
    static func getInvoice(
        for lightningAddress: String,
        amount: Int,
        comment: String? = nil,
        zapRequest: String? = nil
    ) async throws -> String {
        // Resolve Lightning address to LNURL
        let url = try await resolveLightningAddress(lightningAddress)
        
        // Fetch pay parameters
        let payResponse = try await fetchPayParameters(from: url)
        
        // Request invoice
        return try await requestInvoice(
            payResponse: payResponse,
            amount: amount,
            comment: comment,
            zapRequest: zapRequest
        )
    }
}