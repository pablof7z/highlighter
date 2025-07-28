import Foundation

enum CurationError: LocalizedError {
    case notImplemented
    case invalidData
    case publishFailed
    case invalidKind
    case missingIdentifier
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This feature is not yet implemented"
        case .invalidData:
            return "Invalid curation data"
        case .publishFailed:
            return "Failed to publish curation"
        case .invalidKind:
            return "Event is not an article curation (kind:30004)"
        case .missingIdentifier:
            return "Missing required 'd' tag identifier"
        }
    }
}