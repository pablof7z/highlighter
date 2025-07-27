import SwiftUI

// MARK: - State Views

/// Loading view with elegant animations
struct LoadingView: View {
    let message: String?
    let style: LoadingStyle
    @State private var animateGradient = false
    @State private var rotationAngle: Double = 0
    
    enum LoadingStyle {
        case dots
        case spinner
        case skeleton
        case pulse
        
        var animation: Animation {
            switch self {
            case .dots:
                return .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
            case .spinner:
                return .linear(duration: 1).repeatForever(autoreverses: false)
            case .skeleton:
                return .linear(duration: 1.5).repeatForever(autoreverses: false)
            case .pulse:
                return .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            }
        }
    }
    
    init(message: String? = nil, style: LoadingStyle = .dots) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            loadingIndicator
            
            if let message = message {
                Text(message)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        switch style {
        case .dots:
            dotsIndicator
        case .spinner:
            spinnerIndicator
        case .skeleton:
            skeletonIndicator
        case .pulse:
            pulseIndicator
        }
    }
    
    private var dotsIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary,
                                DesignSystem.Colors.primary.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .scaleEffect(animateGradient ? 1.3 : 0.7)
                    .opacity(animateGradient ? 1.0 : 0.5)
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: animateGradient ? 3 : 1,
                        x: 0,
                        y: 1
                    )
                    .animation(
                        style.animation.delay(Double(index) * 0.15),
                        value: animateGradient
                    )
            }
        }
    }
    
    private var spinnerIndicator: some View {
        ZStack {
            // Background circle for depth
            Circle()
                .stroke(
                    DesignSystem.Colors.primary.opacity(0.1),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
            
            // Animated spinner
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [
                            DesignSystem.Colors.primary,
                            DesignSystem.Colors.secondary,
                            DesignSystem.Colors.primary.opacity(0.2)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(rotationAngle))
                .animation(style.animation, value: rotationAngle)
        }
        .frame(width: 32, height: 32)
        .shadow(
            color: DesignSystem.Colors.primary.opacity(0.2),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    private var skeletonIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.surfaceSecondary,
                                DesignSystem.Colors.surfaceSecondary.opacity(0.6),
                                DesignSystem.Colors.surfaceSecondary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 12)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: animateGradient ? 200 : -200)
                        .animation(style.animation, value: animateGradient)
                    )
                    .clipped()
            }
        }
        .frame(width: 150)
    }
    
    private var pulseIndicator: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.1),
                            DesignSystem.Colors.primary.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .scaleEffect(animateGradient ? 1.2 : 0.8)
                .opacity(animateGradient ? 0.3 : 0.8)
                .animation(style.animation, value: animateGradient)
            
            // Inner core
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primary,
                            DesignSystem.Colors.secondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 16, height: 16)
                .shadow(
                    color: DesignSystem.Colors.primary.opacity(0.4),
                    radius: animateGradient ? 6 : 3,
                    x: 0,
                    y: 1
                )
                .scaleEffect(animateGradient ? 1.1 : 1.0)
                .animation(style.animation, value: animateGradient)
        }
    }
    
    private func startAnimation() {
        switch style {
        case .dots, .skeleton, .pulse:
            animateGradient = true
        case .spinner:
            rotationAngle = 360
        }
    }
}

/// Empty state view with illustration and actions
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    let style: EmptyStateStyle
    
    enum EmptyStateStyle {
        case standard
        case minimal
        case illustration
        
        var iconSize: CGFloat {
            switch self {
            case .standard: return 64
            case .minimal: return 48
            case .illustration: return 80
            }
        }
    }
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: EmptyStateStyle = .standard
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: style.iconSize, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.textTertiary,
                                DesignSystem.Colors.textTertiary.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
                
                // Content
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text(title)
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
            }
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .frame(minWidth: 120)
                }
                .unifiedSecondaryButton()
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: 300)
    }
}

/// Error state view with retry functionality
struct ErrorStateView: View {
    let error: Error
    let title: String?
    let subtitle: String?
    let retryAction: (() -> Void)?
    @State private var showDetails = false
    
    init(
        error: Error,
        title: String? = nil,
        subtitle: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.error = error
        self.title = title ?? "Something went wrong"
        self.subtitle = subtitle
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            // Error icon
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DesignSystem.Colors.error.opacity(0.8))
                .symbolRenderingMode(.hierarchical)
            
            // Content
            VStack(spacing: DesignSystem.Spacing.small) {
                Text(title ?? "Something went wrong")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text(error.localizedDescription)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            // Actions
            VStack(spacing: DesignSystem.Spacing.base) {
                if let retryAction = retryAction {
                    Button("Try Again", action: retryAction)
                        .unifiedPrimaryButton()
                }
                
                Button("Show Details") {
                    showDetails.toggle()
                }
                .unifiedSecondaryButton()
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: 300)
        .sheet(isPresented: $showDetails) {
            ErrorDetailsView(error: error)
        }
    }
}

/// Error details view for debugging
struct ErrorDetailsView: View {
    let error: Error
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text(error.localizedDescription)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    let nsError = error as NSError
                    Divider()
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Domain: \(nsError.domain)")
                        Text("Code: \(nsError.code)")
                            
                            if !nsError.userInfo.isEmpty {
                                Text("User Info:")
                                    .font(DesignSystem.Typography.footnoteMedium)
                                
                                ForEach(Array(nsError.userInfo.keys), id: \.self) { key in
                                    Text("\(key): \(String(describing: nsError.userInfo[key]))")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                }
                            }
                    }
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(DesignSystem.Spacing.large)
            }
            .navigationTitle("Error Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Content state wrapper that handles loading, empty, and error states
struct ContentStateView<Content: View, LoadedContent: View>: View {
    let state: ContentState
    let content: () -> Content
    let loadedContent: () -> LoadedContent
    
    enum ContentState {
        case loading(message: String? = nil)
        case empty(icon: String, title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil)
        case error(Error, retryAction: (() -> Void)? = nil)
        case loaded
    }
    
    init(
        state: ContentState,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder loadedContent: @escaping () -> LoadedContent
    ) {
        self.state = state
        self.content = content
        self.loadedContent = loadedContent
    }
    
    var body: some View {
        switch state {
        case .loading(let message):
            content()
                .overlay(
                    LoadingView(message: message)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(DesignSystem.Colors.background.opacity(0.8))
                )
        case .empty(let icon, let title, let subtitle, let actionTitle, let action):
            EmptyStateView(
                icon: icon,
                title: title,
                subtitle: subtitle,
                actionTitle: actionTitle,
                action: action
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let error, let retryAction):
            ErrorStateView(
                error: error,
                retryAction: retryAction
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            loadedContent()
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Wrap content with state management
    func contentState<LoadedContent: View>(
        _ state: ContentStateView<Self, LoadedContent>.ContentState,
        @ViewBuilder loadedContent: @escaping () -> LoadedContent
    ) -> some View {
        ContentStateView(state: state) {
            self
        } loadedContent: {
            loadedContent()
        }
    }
    
    /// Show loading overlay
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    LoadingView(message: message)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(DesignSystem.Colors.background.opacity(0.8))
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("Loading States") {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.xl) {
            LoadingView(message: "Loading your highlights...", style: .dots)
            
            LoadingView(style: .spinner)
            
            LoadingView(style: .skeleton)
            
            LoadingView(style: .pulse)
        }
        .padding(DesignSystem.Spacing.large)
    }
    .background(DesignSystem.Colors.background)
}

#Preview("Empty States") {
    ScrollView {
        VStack(spacing: DesignSystem.Spacing.xl) {
            EmptyStateView(
                icon: "highlighter",
                title: "No Highlights Yet",
                subtitle: "Start highlighting interesting content to see it here",
                actionTitle: "Create Highlight",
                action: {}
            )
            
            EmptyStateView(
                icon: "books.vertical",
                title: "No Books Found",
                subtitle: "Try adjusting your search criteria",
                style: .minimal
            )
        }
        .padding(DesignSystem.Spacing.large)
    }
    .background(DesignSystem.Colors.background)
}

struct SampleError: LocalizedError {
    var errorDescription: String? {
        "Failed to load content from the server"
    }
}

#Preview("Error State") {
    ErrorStateView(
        error: SampleError(),
        retryAction: {}
    )
    .padding(DesignSystem.Spacing.large)
    .background(DesignSystem.Colors.background)
}