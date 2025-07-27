import SwiftUI
import NDKSwift

// MARK: - Article List Card using UnifiedCard
struct ModernArticleListCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    @State private var isBookmarked = false
    
    var body: some View {
        UnifiedCard(
            variant: .standard,
            isSelected: isBookmarked
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Image
                if let imageURL = article.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                        case .failure(_), .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 180)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    // Title
                    Text(article.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(2)
                    
                    // Summary
                    if let summary = article.summary {
                        Text(summary)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(3)
                    }
                    
                    // Metadata
                    HStack {
                        // Author
                        HStack(spacing: DesignSystem.Spacing.mini) {
                            ProfileImage(pubkey: article.author, size: 24)
                            
                            Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Reading time
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        // Date
                        if let publishedAt = article.publishedAt {
                            Text("•")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Text(publishedAt.formatted(.relative(presentation: .named)))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .task {
            await loadAuthor()
            await checkBookmarkStatus()
        }
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: article.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
    
    private func checkBookmarkStatus() async {
        await MainActor.run {
            isBookmarked = appState.bookmarkService.isArticleBookmarked(article.id)
        }
    }
}

// MARK: - Featured Article Card using UnifiedCard
struct ModernArticleFeaturedCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        UnifiedCard(
            variant: .elevated,
            action: nil
        ) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                if let imageURL = article.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 280, height: 200)
                                .clipped()
                        case .failure(_), .empty:
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.primaryDark.opacity(0.2),
                                            DesignSystem.Colors.primary.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 280, height: 200)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    // Title
                    Text(article.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Summary
                    if let summary = article.summary {
                        Text(summary)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Author and metadata
                    HStack {
                        // Author
                        HStack(spacing: DesignSystem.Spacing.mini) {
                            ProfileImage(pubkey: article.author, size: 24)
                            
                            Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Reading time
                        Text("\(article.estimatedReadingTime) min")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding()
            }
            .frame(width: 280, height: 380)
        }
        .task {
            await loadAuthor()
        }
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: article.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
}

// MARK: - Row Article Card using UnifiedCard
struct ModernArticleRowCard: View {
    let article: Article
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        UnifiedCard(
            variant: .standard
        ) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                // Small image on the left
                if let imageURL = article.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                        case .failure(_), .empty:
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.primaryDark.opacity(0.1),
                                            DesignSystem.Colors.primary.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Content on the right
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.mini) {
                    // Title
                    Text(article.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Summary
                    if let summary = article.summary {
                        Text(summary)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Metadata
                    HStack(spacing: DesignSystem.Spacing.small) {
                        // Author
                        HStack(spacing: 4) {
                            ProfileImage(pubkey: article.author, size: 20)
                            
                            Text(author?.displayName ?? PubkeyFormatter.formatShort(article.author))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Reading time & date
                        HStack(spacing: 4) {
                            Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .labelStyle(.titleOnly)
                            
                            if let publishedAt = article.publishedAt {
                                Text("•")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                Text(RelativeTimeFormatter.relativeTime(from: publishedAt))
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .frame(height: 120)
        }
        .task {
            await loadAuthor()
        }
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: article.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
}