import SwiftUI

struct MeshGradientBackground: View {
    @State private var gradientPhase: Double = 0
    @State private var animationTimer: Timer?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TimelineView(.animation) { (timeline: TimelineViewDefaultContext) in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Create mesh points
                let rows = 4
                let cols = 4
                let spacing = size.width / CGFloat(cols - 1)
                
                for row in 0..<rows-1 {
                    for col in 0..<cols-1 {
                        let topLeft = meshPoint(row: row, col: col, spacing: spacing, time: time)
                        let topRight = meshPoint(row: row, col: col + 1, spacing: spacing, time: time)
                        let bottomLeft = meshPoint(row: row + 1, col: col, spacing: spacing, time: time)
                        let bottomRight = meshPoint(row: row + 1, col: col + 1, spacing: spacing, time: time)
                        
                        let path = Path { path in
                            path.move(to: topLeft)
                            path.addCurve(
                                to: topRight,
                                control1: CGPoint(x: topLeft.x + spacing/3, y: topLeft.y),
                                control2: CGPoint(x: topRight.x - spacing/3, y: topRight.y)
                            )
                            path.addCurve(
                                to: bottomRight,
                                control1: CGPoint(x: topRight.x, y: topRight.y + spacing/3),
                                control2: CGPoint(x: bottomRight.x, y: bottomRight.y - spacing/3)
                            )
                            path.addCurve(
                                to: bottomLeft,
                                control1: CGPoint(x: bottomRight.x - spacing/3, y: bottomRight.y),
                                control2: CGPoint(x: bottomLeft.x + spacing/3, y: bottomLeft.y)
                            )
                            path.addCurve(
                                to: topLeft,
                                control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y - spacing/3),
                                control2: CGPoint(x: topLeft.x, y: topLeft.y + spacing/3)
                            )
                        }
                        
                        let colors = gradientColors(for: row, col: col, time: time)
                        let gradient = Gradient(colors: colors)
                        
                        context.fill(path, with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: 1, y: 1)
                        ))
                    }
                }
            }
        }
        .blur(radius: 60)
        .opacity(colorScheme == .dark ? 0.5 : 0.3)
    }
    
    private func meshPoint(row: Int, col: Int, spacing: CGFloat, time: TimeInterval) -> CGPoint {
        let baseX = CGFloat(col) * spacing
        let baseY = CGFloat(row) * spacing
        
        // Add wave motion
        let waveX = sin(time * 0.5 + Double(row) * 0.3) * 20
        let waveY = cos(time * 0.4 + Double(col) * 0.2) * 20
        
        return CGPoint(x: baseX + waveX, y: baseY + waveY)
    }
    
    private func gradientColors(for row: Int, col: Int, time: TimeInterval) -> [Color] {
        let phase = time * 0.2 + Double(row + col) * 0.5
        
        let colors: [[Color]] = [
            [.purple, .blue],
            [.orange, .pink],
            [.green, .blue],
            [.purple, .orange]
        ]
        
        let colorIndex = (row + col) % colors.count
        let baseColors = colors[colorIndex]
        
        return baseColors.map { color in
            color.opacity(0.3 + sin(phase) * 0.2)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        MeshGradientBackground()
    }
}