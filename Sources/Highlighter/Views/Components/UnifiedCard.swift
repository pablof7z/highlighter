import SwiftUI
import NDKSwift

// MARK: - Unified Card System
// A flexible, reusable card component that consolidates multiple similar card implementations

struct UnifiedCard<Content: View>: View {
    let content: Content
    let variant: CardVariant
    let isSelected: Bool
    let action: (() -> Void)?
    
    init(
        variant: CardVariant = .standard,
        isSelected: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        content
            .padding(variant.padding)
            .frame(maxWidth: variant.maxWidth, minHeight: variant.minHeight)
            .background(variant.backgroundView)
            .overlay(variant.borderView(isSelected: isSelected))
            .clipShape(RoundedRectangle(cornerRadius: variant.cornerRadius, style: .continuous))
            .shadow(
                color: variant.shadowColor(isSelected: isSelected),
                radius: variant.shadowRadius(isSelected: isSelected),
                x: 0,
                y: variant.shadowY(isSelected: isSelected)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .opacity(isSelected ? 1.0 : 0.95)
            .animation(AnimationSystem.Curves.premiumSpring, value: isSelected)
            .premiumCardInteraction()
            .premiumEntrance(delay: 0.1)
    }
}

// MARK: - Card Variants
enum CardVariant {
    case standard
    case compact
    case glass
    case elevated
    case highlight
    case placeholder
    
    var padding: CGFloat {
        switch self {
        case .standard, .glass, .elevated, .highlight: return DesignSystem.Spacing.cardPadding
        case .compact: return DesignSystem.Spacing.base
        case .placeholder: return DesignSystem.Spacing.cardPadding
        }
    }
    
    var maxWidth: CGFloat? {
        switch self {
        case .compact: return 280
        default: return nil
        }
    }
    
    var minHeight: CGFloat? {
        switch self {
        case .compact: return 140
        case .elevated: return 160
        default: return nil
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .standard, .elevated, .highlight: return DesignSystem.CornerRadius.large
        case .compact, .glass: return DesignSystem.CornerRadius.medium
        case .placeholder: return DesignSystem.CornerRadius.large
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .glass:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
        case .placeholder:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(DesignSystem.Colors.surface)
        default:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(DesignSystem.Colors.surface)
        }
    }
    
    @ViewBuilder
    func borderView(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                borderGradient(isSelected: isSelected),
                lineWidth: borderWidth(isSelected: isSelected)
            )
    }
    
    private func borderGradient(isSelected: Bool) -> LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [DesignSystem.Colors.secondary, DesignSystem.Colors.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        switch self {
        case .highlight:
            return LinearGradient(
                colors: [DesignSystem.Colors.secondary.opacity(0.3), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .glass:
            return LinearGradient(
                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [DesignSystem.Colors.border, DesignSystem.Colors.border.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func borderWidth(isSelected: Bool) -> CGFloat {
        switch self {
        case .highlight where isSelected: return 2
        case .highlight: return 1.5
        default: return isSelected ? 2 : 1
        }
    }
    
    func shadowColor(isSelected: Bool) -> Color {
        if isSelected {
            return DesignSystem.Colors.secondary.opacity(0.3)
        }
        
        switch self {
        case .standard: return DesignSystem.Shadow.small.color
        case .compact: return DesignSystem.Shadow.subtle.color
        case .glass: return Color.black.opacity(0.1)
        case .elevated: return DesignSystem.Shadow.medium.color
        case .highlight: return Color.black.opacity(0.08)
        case .placeholder: return DesignSystem.Shadow.subtle.color
        }
    }
    
    func shadowRadius(isSelected: Bool) -> CGFloat {
        if isSelected { return 12 }
        
        switch self {
        case .standard: return DesignSystem.Shadow.small.radius
        case .compact: return DesignSystem.Shadow.subtle.radius
        case .glass: return 8
        case .elevated: return DesignSystem.Shadow.medium.radius
        case .highlight: return 8
        case .placeholder: return DesignSystem.Shadow.subtle.radius
        }
    }
    
    func shadowY(isSelected: Bool) -> CGFloat {
        if isSelected { return 6 }
        
        switch self {
        case .standard: return DesignSystem.Shadow.small.y
        case .compact: return DesignSystem.Shadow.subtle.y
        case .glass: return 4
        case .elevated: return DesignSystem.Shadow.medium.y
        case .highlight: return 4
        case .placeholder: return DesignSystem.Shadow.subtle.y
        }
    }
}

// MARK: - Specialized Card Components

// Highlight Card using the unified system
struct ModernHighlightCard: View {
    let highlight: HighlightEvent
    @EnvironmentObject var appState: AppState
    @State private var author: NDKUserProfile?
    @State private var isZapped = false
    @State private var showDetail = false
    
    var body: some View {
        UnifiedCard(
            variant: .standard,
            isSelected: isZapped,
            action: { showDetail = true }
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Quote
                Text("\"\(highlight.content)\"")
                    .font(.ds.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.ds.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Comment if available
                if let comment = highlight.comment {
                    Text(comment)
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                        .padding(.top, .ds.micro)
                }
                
                // Metadata row
                HStack {
                    // Author
                    HStack(spacing: .ds.small) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.ds.primary)
                        
                        Text(author?.name ?? author?.displayName ?? String(highlight.author.prefix(8)))
                            .font(.ds.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.ds.text)
                    }
                    
                    Spacer()
                    
                    // Actions
                    HStack(spacing: .ds.medium) {
                        // Zap button
                        Button(action: zapHighlight) {
                            Image(systemName: isZapped ? "bolt.fill" : "bolt")
                                .font(.system(size: 16))
                                .foregroundColor(isZapped ? .ds.warning : .ds.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Time
                        Text(RelativeTimeFormatter.relativeTime(from: highlight.createdAt))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
                
                // Source indicator
                if let url = highlight.url {
                    HStack(spacing: .ds.micro) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(URL(string: url)?.host ?? "Source")
                            .font(.ds.caption)
                    }
                    .foregroundColor(.ds.primary)
                }
            }
        }
        .task {
            await loadAuthor()
        }
        .sheet(isPresented: $showDetail) {
            HighlightDetailView(highlight: highlight)
                .environmentObject(appState)
        }
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: highlight.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
    
    private func zapHighlight() {
        isZapped.toggle()
        HapticManager.shared.impact(.light)
        // Note: Actual zapping requires wallet integration (NIP-57/NIP-60)
        // This demo app only simulates the UI interaction
    }
}

// Compact Highlight Card using the unified system
struct ModernCompactHighlightCard: View {
    let highlight: HighlightEvent
    @State private var showDetail = false
    
    var body: some View {
        UnifiedCard(
            variant: .compact,
            action: { showDetail = true }
        ) {
            VStack(alignment: .leading, spacing: .ds.small) {
                Text("\"\(highlight.content)\"")
                    .font(.ds.body)
                    .fontWeight(.medium)
                    .foregroundColor(.ds.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(minHeight: 60, alignment: .topLeading)
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.ds.primary)
                    
                    Text(String(highlight.author.prefix(8)))
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "bolt")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            HighlightDetailView(highlight: highlight)
        }
    }
}

// Placeholder Card using the unified system
struct PlaceholderCard: View {
    let lines: Int
    
    init(lines: Int = 3) {
        self.lines = lines
    }
    
    var body: some View {
        UnifiedCard(variant: .placeholder) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<lines, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(index == 0 ? 0.2 : 0.15))
                        .frame(height: 16)
                        .frame(maxWidth: index == lines - 1 ? .infinity * 0.7 : .infinity)
                }
            }
        }
        .shimmer()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Standard cards
            ModernHighlightCard(
                highlight: HighlightEvent(
                    id: "1",
                    event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 9802, tags: [], content: "", sig: ""),
                    content: "The best way to predict the future is to invent it.",
                    author: "test",
                    createdAt: Date(),
                    context: nil,
                    url: "https://example.com",
                    referencedEvent: nil,
                    attributedAuthors: [],
                    comment: "A profound insight"
                )
            )
            .environmentObject(AppState())
            
            // Compact cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { _ in
                        ModernCompactHighlightCard(
                            highlight: HighlightEvent(
                                id: "2",
                                event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 9802, tags: [], content: "", sig: ""),
                                content: "Innovation distinguishes between a leader and a follower.",
                                author: "test2",
                                createdAt: Date(),
                                context: nil,
                                url: nil,
                                referencedEvent: nil,
                                attributedAuthors: [],
                                comment: nil
                            )
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Placeholder cards
            PlaceholderCard(lines: 4)
            PlaceholderCard(lines: 2)
        }
        .padding()
    }
    .background(DesignSystem.Colors.background)
}