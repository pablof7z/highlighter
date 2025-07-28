import Foundation
import UIKit
import NDKSwift

enum ImageUploadError: LocalizedError {
    case notConfigured
    case uploadFailed(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Image upload service not configured"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}

// MARK: - Image Upload Service using NDKSwift's Blossom
class ImageUploadService {
    static let shared = ImageUploadService()
    
    private var ndk: NDK?
    private var signer: NDKSigner?
    
    private init() {}
    
    // Configure with NDK instance
    func configure(with ndk: NDK, signer: NDKSigner?) {
        self.ndk = ndk
        self.signer = signer
    }
    
    enum ImageType {
        case profile
        case banner
        case highlight
        
        var maxSize: CGSize {
            switch self {
            case .profile:
                return CGSize(width: 800, height: 800)
            case .banner:
                return CGSize(width: 1500, height: 500)
            case .highlight:
                return CGSize(width: 1200, height: 1200)
            }
        }
        
        var compressionQuality: CGFloat {
            switch self {
            case .profile:
                return 0.85
            case .banner:
                return 0.9
            case .highlight:
                return 0.9
            }
        }
    }
    
    /// Upload image using NDKSwift's Blossom server manager
    func uploadImage(_ data: Data, type: ImageType) async throws -> String {
        guard let ndk = ndk, let signer = signer else {
            throw ImageUploadError.notConfigured
        }
        
        // Process image if needed
        let processedData = try await processImageData(data, type: type)
        
        // TODO: Implement image upload using NDKSwift's Blossom API
        // For now, throw not implemented error
        throw ImageUploadError.notConfigured
    }
    
    /// Upload image from Data with optional processing
    func uploadImageFromData(_ data: Data?, type: ImageType) async throws -> String {
        guard let data = data else {
            throw ImageUploadError.invalidData("No image data provided")
        }
        
        return try await uploadImage(data, type: type)
    }
    
    /// Upload multiple images in parallel
    func uploadImages(_ images: [(data: Data, type: ImageType)]) async throws -> [String] {
        try await withThrowingTaskGroup(of: String.self) { group in
            for image in images {
                group.addTask {
                    try await self.uploadImage(image.data, type: image.type)
                }
            }
            
            var urls: [String] = []
            for try await url in group {
                urls.append(url)
            }
            return urls
        }
    }
    
    /// Upload with fallback to multiple servers
    func uploadImageWithFallback(_ data: Data, type: ImageType) async throws -> String {
        // NDKSwift's Blossom server manager already handles fallback
        return try await uploadImage(data, type: type)
    }
    
    // MARK: - Private Methods
    
    private func processImageData(_ data: Data, type: ImageType) async throws -> Data {
        guard let image = UIImage(data: data) else {
            throw ImageUploadError.invalidData("Invalid image data")
        }
        
        // Resize if needed
        let resizedImage = resizeImage(image, targetSize: type.maxSize)
        
        // Compress
        guard let processedData = resizedImage.jpegData(compressionQuality: type.compressionQuality) else {
            throw ImageUploadError.invalidData("Failed to process image")
        }
        
        return processedData
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        // Don't resize if already smaller
        if size.width <= targetSize.width && size.height <= targetSize.height {
            return image
        }
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // MARK: - Utilities
    
    /// Get optimized image data for upload
    static func optimizeImageForUpload(_ image: UIImage, type: ImageType) -> Data? {
        let service = ImageUploadService.shared
        
        // Resize if needed
        let resized = service.resizeImage(image, targetSize: type.maxSize)
        
        // Try JPEG compression first
        if let jpegData = resized.jpegData(compressionQuality: type.compressionQuality) {
            return jpegData
        }
        
        // Fallback to PNG
        return resized.pngData()
    }
    
    /// Check if image needs optimization
    static func needsOptimization(_ data: Data, for type: ImageType) -> Bool {
        // Check data size
        let maxSize: Int
        switch type {
        case .profile:
            maxSize = 500_000 // 500KB
        case .banner:
            maxSize = 1_000_000 // 1MB
        case .highlight:
            maxSize = 2_000_000 // 2MB
        }
        
        return data.count > maxSize
    }
}