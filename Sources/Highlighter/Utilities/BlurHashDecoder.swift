import UIKit
import SwiftUI

struct BlurHash {
    // BlurHash algorithm constants
    private enum Constants {
        static let minimumHashLength = 6
        static let componentDivisor = 9
        static let maximumValueDivisor: Float = 166
        static let headerLength = 4
        static let componentDataLength = 2
    }
    
    static func decode(blurhash: String, width: Int, height: Int) -> UIImage? {
        guard blurhash.count >= Constants.minimumHashLength else { return nil }
        
        let sizeFlag = String(blurhash[blurhash.startIndex]).decode83()
        let numY = (sizeFlag / Constants.componentDivisor) + 1
        let numX = (sizeFlag % Constants.componentDivisor) + 1
        
        let quantisedMaximumValue = String(blurhash[blurhash.index(blurhash.startIndex, offsetBy: 1)]).decode83()
        let maximumValue = Float(quantisedMaximumValue + 1) / Constants.maximumValueDivisor
        
        guard blurhash.count == Constants.headerLength + Constants.componentDataLength * numX * numY else { return nil }
        
        var colours: [(Float, Float, Float)] = []
        for i in 0 ..< numX * numY {
            if i == 0 {
                let value = String(blurhash[blurhash.index(blurhash.startIndex, offsetBy: 2) ..< blurhash.index(blurhash.startIndex, offsetBy: 6)]).decode83()
                colours.append(decodeDC(value))
            } else {
                let range = blurhash.index(blurhash.startIndex, offsetBy: 4 + i * 2) ..< blurhash.index(blurhash.startIndex, offsetBy: 4 + i * 2 + 2)
                let value = String(blurhash[range]).decode83()
                colours.append(decodeAC(value, maximumValue: maximumValue))
            }
        }
        
        // Image data constants
        let bytesPerPixel = 3  // RGB without alpha
        let bytesPerRow = width * bytesPerPixel
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesPerRow * height)
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                var r: Float = 0
                var g: Float = 0
                var b: Float = 0
                
                for j in 0 ..< numY {
                    for i in 0 ..< numX {
                        let basis = cos(Float.pi * Float(x) * Float(i) / Float(width)) * cos(Float.pi * Float(y) * Float(j) / Float(height))
                        let colour = colours[i + j * numX]
                        r += colour.0 * basis
                        g += colour.1 * basis
                        b += colour.2 * basis
                    }
                }
                
                let intR = UInt8(linearTosRGB(r))
                let intG = UInt8(linearTosRGB(g))
                let intB = UInt8(linearTosRGB(b))
                
                // RGB channel offsets
                let redOffset = 0
                let greenOffset = 1
                let blueOffset = 2
                
                pixels[bytesPerPixel * x + redOffset + y * bytesPerRow] = intR
                pixels[bytesPerPixel * x + greenOffset + y * bytesPerRow] = intG
                pixels[bytesPerPixel * x + blueOffset + y * bytesPerRow] = intB
            }
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let provider = CGDataProvider(dataInfo: nil, data: pixels, size: bytesPerRow * height, releaseData: { _, data, _ in
            data.deallocate()
        }) else { return nil }
        
        // Image format constants
        let bitsPerComponent = 8
        let bitsPerPixel = 24  // 8 bits × 3 channels (RGB)
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Color decoding constants
    private enum ColorConstants {
        static let redShift = 16
        static let greenShift = 8
        static let byteMask = 255
        static let quantizationFactor = 19
        static let centeringOffset: Float = 9
        static let powerExponent: Float = 2
    }
    
    private static func decodeDC(_ value: Int) -> (Float, Float, Float) {
        let intR = value >> ColorConstants.redShift
        let intG = (value >> ColorConstants.greenShift) & ColorConstants.byteMask
        let intB = value & ColorConstants.byteMask
        return (sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB))
    }
    
    private static func decodeAC(_ value: Int, maximumValue: Float) -> (Float, Float, Float) {
        let quantR = value / (ColorConstants.quantizationFactor * ColorConstants.quantizationFactor)
        let quantG = (value / ColorConstants.quantizationFactor) % ColorConstants.quantizationFactor
        let quantB = value % ColorConstants.quantizationFactor
        
        let rgb = (
            signPow((Float(quantR) - ColorConstants.centeringOffset) / ColorConstants.centeringOffset, ColorConstants.powerExponent) * maximumValue,
            signPow((Float(quantG) - ColorConstants.centeringOffset) / ColorConstants.centeringOffset, ColorConstants.powerExponent) * maximumValue,
            signPow((Float(quantB) - ColorConstants.centeringOffset) / ColorConstants.centeringOffset, ColorConstants.powerExponent) * maximumValue
        )
        
        return rgb
    }
    
    // sRGB color space conversion constants
    private enum SRGBConstants {
        static let maxColorValue: Float = 255
        static let linearThreshold: Float = 0.04045
        static let linearDivisor: Float = 12.92
        static let gammaOffset: Float = 0.055
        static let gammaMultiplier: Float = 1.055
        static let gammaExponent: Float = 2.4
        static let inverseLinearThreshold: Float = 0.0031308
    }
    
    private static func sRGBToLinear(_ value: Int) -> Float {
        let v = Float(value) / SRGBConstants.maxColorValue
        if v <= SRGBConstants.linearThreshold {
            return v / SRGBConstants.linearDivisor
        } else {
            return pow((v + SRGBConstants.gammaOffset) / SRGBConstants.gammaMultiplier, SRGBConstants.gammaExponent)
        }
    }
    
    private static func linearTosRGB(_ value: Float) -> Int {
        let v = max(0, min(1, value))
        if v <= SRGBConstants.inverseLinearThreshold {
            return Int(v * SRGBConstants.linearDivisor * SRGBConstants.maxColorValue + 0.5)
        } else {
            return Int((SRGBConstants.gammaMultiplier * pow(v, 1 / SRGBConstants.gammaExponent) - SRGBConstants.gammaOffset) * SRGBConstants.maxColorValue + 0.5)
        }
    }
    
    private static func signPow(_ value: Float, _ exp: Float) -> Float {
        return copysign(pow(abs(value), exp), value)
    }
}

private extension String {
    private static let base83Radix = 83
    
    func decode83() -> Int {
        var value: Int = 0
        for character in self {
            if let digit = decode83Map[character] {
                value = value * String.base83Radix + digit
            }
        }
        return value
    }
}

private let decode83Map: [Character: Int] = {
    let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~")
    var dict: [Character: Int] = [:]
    for (index, character) in chars.enumerated() {
        dict[character] = index
    }
    return dict
}()

// SwiftUI View Modifier
struct BlurHashModifier: ViewModifier {
    let blurhash: String?
    let size: CGSize
    @State private var blurImage: UIImage?
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if let blurImage = blurImage {
                        Image(uiImage: blurImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity)
                    }
                }
            )
            .onAppear {
                if let blurhash = blurhash {
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Performance optimization: decode at lower resolution
                        let resolutionDivisor = 10
                        let fadeInDuration = 0.3
                        
                        let image = BlurHash.decode(
                            blurhash: blurhash,
                            width: Int(size.width / CGFloat(resolutionDivisor)),
                            height: Int(size.height / CGFloat(resolutionDivisor))
                        )
                        DispatchQueue.main.async {
                            withAnimation(.easeIn(duration: fadeInDuration)) {
                                self.blurImage = image
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func blurhashBackground(_ blurhash: String?, size: CGSize) -> some View {
        modifier(BlurHashModifier(blurhash: blurhash, size: size))
    }
}