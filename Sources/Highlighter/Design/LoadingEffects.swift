import SwiftUI

// Shimmer effect is already defined in DesignSystem.swift
// Premium entrance animation is already defined in AnimationSystem.swift

// MARK: - Loading Skeleton Components

struct SkeletonBox: View {
    let width: CGFloat?
    let height: CGFloat
    
    init(width: CGFloat? = nil, height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .shimmer()
    }
}

struct ArticleCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(16/9, contentMode: .fit)
                .shimmer()
            
            VStack(alignment: .leading, spacing: .ds.small) {
                // Title
                SkeletonBox(height: 20)
                SkeletonBox(width: 200, height: 20)
                
                // Description
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonBox(height: 14)
                    SkeletonBox(height: 14)
                    SkeletonBox(width: 150, height: 14)
                }
                
                // Author and date
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .shimmer()
                    
                    SkeletonBox(width: 100, height: 12)
                    
                    Spacer()
                    
                    SkeletonBox(width: 60, height: 12)
                }
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct HighlightCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            // Header
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .shimmer()
                
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonBox(width: 100, height: 12)
                    SkeletonBox(width: 60, height: 10)
                }
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: .ds.small) {
                SkeletonBox(height: 16)
                SkeletonBox(height: 16)
                SkeletonBox(width: 200, height: 16)
            }
            
            // Actions
            HStack(spacing: .ds.large) {
                SkeletonBox(width: 40, height: 20)
                SkeletonBox(width: 40, height: 20)
                SkeletonBox(width: 40, height: 20)
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CurationCardSkeleton: View {
    var body: some View {
        HStack(spacing: .ds.medium) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBox(width: 150, height: 16)
                SkeletonBox(height: 12)
                
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonBox(width: 60, height: 10)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Animated Loading Dots

struct LoadingDotsView: View {
    @State private var animateDots = [false, false, false]
    let dotSize: CGFloat
    let color: Color
    
    init(dotSize: CGFloat = 10, color: Color = .ds.primary) {
        self.dotSize = dotSize
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: dotSize / 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(animateDots[index] ? 1.2 : 0.8)
                    .opacity(animateDots[index] ? 1 : 0.6)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animateDots[index]
                    )
            }
        }
        .onAppear {
            for index in 0..<3 {
                animateDots[index] = true
            }
        }
    }
}

// MARK: - Pull to Refresh Indicator

struct PullToRefreshIndicator: View {
    let progress: CGFloat
    let isRefreshing: Bool
    
    var body: some View {
        ZStack {
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .ds.primary))
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.ds.primary)
                    .rotationEffect(.degrees(progress * 180))
                    .opacity(progress)
            }
        }
        .frame(width: 40, height: 40)
        .background(
            Circle()
                .fill(DesignSystem.Colors.surface)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
        .scaleEffect(isRefreshing ? 1 : progress)
    }
}

// MARK: - Animated Success Checkmark

struct SuccessCheckmarkView: View {
    @State private var animateCheckmark = false
    @State private var animateCircle = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 50, height: 50)
                .scaleEffect(animateCircle ? 1 : 0)
                .opacity(animateCircle ? 1 : 0)
            
            Path { path in
                path.move(to: CGPoint(x: 15, y: 25))
                path.addLine(to: CGPoint(x: 22, y: 32))
                path.addLine(to: CGPoint(x: 35, y: 18))
            }
            .trim(from: 0, to: animateCheckmark ? 1 : 0)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 50, height: 50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animateCircle = true
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                animateCheckmark = true
            }
        }
    }
}

// MARK: - Animated Error View

struct ErrorAnimationView: View {
    @State private var animate = false
    let message: String
    
    var body: some View {
        VStack(spacing: .ds.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .scaleEffect(animate ? 1 : 0.5)
                .rotationEffect(.degrees(animate ? 0 : -10))
            
            Text(message)
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

// MARK: - Content Loading State View

struct ContentLoadingStateView<Content: View>: View {
    let isLoading: Bool
    let isEmpty: Bool
    let error: Error?
    let emptyStateView: AnyView
    let errorView: (Error) -> AnyView
    let content: () -> Content
    
    init(
        isLoading: Bool,
        isEmpty: Bool,
        error: Error? = nil,
        emptyStateView: AnyView,
        errorView: @escaping (Error) -> AnyView = { error in
            AnyView(ErrorAnimationView(message: error.localizedDescription))
        },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.isEmpty = isEmpty
        self.error = error
        self.emptyStateView = emptyStateView
        self.errorView = errorView
        self.content = content
    }
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: .ds.large) {
                    LoadingDotsView()
                    Text("Loading...")
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                errorView(error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content()
            }
        }
        .animation(.default, value: isLoading)
        .animation(.default, value: isEmpty)
        .animation(.default, value: error != nil)
    }
}