import Foundation
import UIKit

// MARK: - Image Upload Service
// Service for uploading images to hosting providers

class ImageUploadService {
    static let shared = ImageUploadService()
    
    private init() {}
    
    enum ImageUploadError: LocalizedError {
        case invalidData
        case invalidResponse
        case uploadFailed(String)
        case noURLReturned
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid image data"
            case .invalidResponse:
                return "Invalid server response"
            case .uploadFailed(let message):
                return "Upload failed: \(message)"
            case .noURLReturned:
                return "No URL returned from server"
            }
        }
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
                return 0.8
            case .banner:
                return 0.85
            case .highlight:
                return 0.9
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Upload image data to hosting service
    func uploadImage(_ data: Data, type: ImageType) async throws -> String {
        // First, process the image to ensure it's within size limits
        let processedData = try await processImage(data, type: type)
        
        // Upload to nostr.build
        return try await uploadToNostrBuild(processedData)
    }
    
    /// Upload image from PhotosPickerItem data
    func uploadImageFromData(_ data: Data?, type: ImageType) async throws -> String {
        guard let data = data else {
            throw ImageUploadError.invalidData
        }
        
        return try await uploadImage(data, type: type)
    }
    
    // MARK: - Private Methods
    
    private func processImage(_ data: Data, type: ImageType) async throws -> Data {
        guard let image = UIImage(data: data) else {
            throw ImageUploadError.invalidData
        }
        
        // Resize image if needed
        let resizedImage = await resizeImage(image, maxSize: type.maxSize)
        
        // Compress image
        guard let compressedData = resizedImage.jpegData(compressionQuality: type.compressionQuality) else {
            throw ImageUploadError.invalidData
        }
        
        return compressedData
    }
    
    private func resizeImage(_ image: UIImage, maxSize: CGSize) async -> UIImage {
        let size = image.size
        
        // Check if resize is needed
        if size.width <= maxSize.width && size.height <= maxSize.height {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        // Resize image
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                image.draw(in: CGRect(origin: .zero, size: newSize)
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
                UIGraphicsEndImageContext()
                continuation.resume(returning: resizedImage)
            }
        }
    }
    
    private func uploadToNostrBuild(_ data: Data) async throws -> String {
        // nostr.build API endpoint
        let url = URL(string: "https://nostr.build/api/v2/upload/files")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ImageUploadError.invalidResponse
            }
            
            // Parse response
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let status = json["status"] as? String,
               status == "success",
               let data = json["data"] as? [[String: Any]],
               let firstFile = data.first,
               let url = firstFile["url"] as? String {
                return url
            }
            
            // Try alternate parsing for different response format
            if let responseString = String(data: responseData, encoding: .utf8),
               responseString.starts(with: "https://") {
                return responseString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            throw ImageUploadError.noURLReturned
        } catch let error as ImageUploadError {
            throw error
        } catch {
            throw ImageUploadError.uploadFailed(error.localizedDescription)
        }
    }
}

// MARK: - Alternative Upload Providers

extension ImageUploadService {
    /// Upload to void.cat (alternative provider)
    private func uploadToVoidCat(_ data: Data) async throws -> String {
        let url = URL(string: "https://void.cat/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ImageUploadError.invalidResponse
            }
            
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let url = result["url"] as? String {
                return url
            }
            
            throw ImageUploadError.noURLReturned
        } catch let error as ImageUploadError {
            throw error
        } catch {
            throw ImageUploadError.uploadFailed(error.localizedDescription)
        }
    }
    
    /// Upload with fallback to alternative providers
    func uploadImageWithFallback(_ data: Data, type: ImageType) async throws -> String {
        let processedData = try await processImage(data, type: type)
        
        // Try primary provider
        do {
            return try await uploadToNostrBuild(processedData)
        } catch {
            // Fallback to alternative provider
            return try await uploadToVoidCat(processedData)
        }
    }
}