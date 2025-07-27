import SwiftUI
import NDKSwift

struct CurationDetailView: View {
    let curation: ArticleCuration
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var isFollowing = false
    @State private var showAddArticle = false
    @State private var curator: NDKUserProfile?
    @State private var currentUserPubkey: String?
    @State private var loadedArticles: [Article] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    ZStack(alignment: .bottomLeading) {
                        // Cover image
                        if let imageUrl = curation.image, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                DesignSystem.Colors.primary.opacity(0.3),
                                                DesignSystem.Colors.secondary.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .frame(height: 250)
                            .clipped()
                        } else {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.Colors.primary.opacity(0.5),
                                            DesignSystem.Colors.secondary.opacity(0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 250)
                        }
                        
                        // Gradient overlay
                        LinearGradient(
                            colors: [Color.clear, DesignSystem.Colors.darkBackground.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        
                        // Title overlay
                        VStack(alignment: .leading, spacing: 8) {
                            Text(curation.title)
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(.white)
                            
                            if let description = curation.description {
                                Text(description)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(.white.opacity(0.9)
                                    .lineLimit(2)
                            }
                        }
                        .padding()
                    }
                    
                    // Curator info
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(curator?.name ?? curator?.displayName ?? "Curator")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.medium)
                            
                            Text("\(curation.articles.count) articles • Updated \(relativeTime(from: curation.updatedAt))")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: toggleFollow) {
                            Text(isFollowing ? "Following" : "Follow")
                                .font(DesignSystem.Typography.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isFollowing ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(DesignSystem.CornerRadius.xl)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: shareCuration) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(DesignSystem.Typography.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.base)
                                .background(DesignSystem.Colors.surface)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                        
                        if let userPubkey = currentUserPubkey, curation.author == userPubkey {
                            Button(action: { showAddArticle = true }) {
                                Label("Add Article", systemImage: "plus.circle")
                                    .font(DesignSystem.Typography.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(DesignSystem.Colors.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(DesignSystem.CornerRadius.medium)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Articles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Articles")
                            .font(DesignSystem.Typography.headline)
                            .padding(.horizontal)
                        
                        if loadedArticles.isEmpty && curation.articles.isEmpty {
                            EmptyArticlesView()
                                .padding(.horizontal)
                        } else {
                            // Show loaded articles
                            ForEach(loadedArticles) { article in
                                LoadedArticleCard(article: article)
                                    .padding(.horizontal)
                            }
                            
                            // Show unresolved references (URLs only)
                            ForEach(curation.articles.filter { ref in 
                                ref.url != nil && !loadedArticles.contains { $0.event.id == ref.eventId }
                            }, id: \.url) { reference in
                                ArticleCard(article: reference)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .task {
            await loadCurator()
            await loadArticles()
            
            // Load current user pubkey
            if let signer = appState.activeSigner {
                currentUserPubkey = try? await signer.pubkey
            }
        }
        .sheet(isPresented: $showAddArticle) {
            AddArticleSheet(curation: curation)
                .environmentObject(appState)
        }
    }
    
    private func loadCurator() async {
        guard let ndk = appState.ndk else { return }
        
        for await profile in await ndk.profileManager.observe(for: curation.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.curator = profile
            }
            break
        }
    }
    
    private func loadArticles() async {
        guard let ndk = appState.ndk else { return }
        
        // Collect event IDs and addresses to fetch
        var eventIds: [String] = []
        var eventAddresses: [(kind: Int, pubkey: String, identifier: String)] = []
        
        for reference in curation.articles {
            if let eventId = reference.eventId {
                eventIds.append(eventId)
            } else if let address = reference.eventAddress {
                // Parse NIP-33 address format: <kind>:<pubkey>:<d-tag>
                let parts = address.split(separator: ":")
                if parts.count == 3,
                   let kind = Int(parts[0]) {
                    eventAddresses.append((
                        kind: kind,
                        pubkey: String(parts[1]),
                        identifier: String(parts[2])
                    )
                }
            }
        }
        
        // Stream articles by event ID
        if !eventIds.isEmpty {
            Task {
                let filter = NDKFilter(ids: eventIds)
                let articleSource = await ndk.outbox.observe(
                    filter: filter,
                    maxAge: 300,
                    cachePolicy: .cacheWithNetwork
                )
                
                for await event in articleSource.events {
                    if event.kind == 30023,
                       let article = try? Article(from: event) {
                        await MainActor.run {
                            if !loadedArticles.contains(where: { $0.id == article.id }) {
                                loadedArticles.append(article)
                                loadedArticles.sort { $0.createdAt > $1.createdAt }
                            }
                        }
                    }
                }
            }
        }
        
        // Stream articles by address (NIP-33 parameterized replaceable events)
        for address in eventAddresses {
            Task {
                let filter = NDKFilter(
                    authors: [address.pubkey],
                    kinds: [address.kind]
                )
                
                let articleSource = await ndk.outbox.observe(
                    filter: filter,
                    maxAge: 300,
                    cachePolicy: .cacheWithNetwork
                )
                
                for await event in articleSource.events {
                    // Check if this event has the matching d-tag
                    if let dTag = event.tags.first(where: { $0.first == "d" })?[safe: 1],
                       dTag == address.identifier,
                       event.kind == 30023,
                       let article = try? Article(from: event) {
                        await MainActor.run {
                            if !loadedArticles.contains(where: { $0.id == article.id }) {
                                loadedArticles.append(article)
                                loadedArticles.sort { $0.createdAt > $1.createdAt }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleFollow() {
        isFollowing.toggle()
        HapticManager.shared.impact(.light)
        // Note: Follow functionality requires contact list management (NIP-02)
        // This demo focuses on curation display features
    }
    
    private func shareCuration() {
        HapticManager.shared.impact(.light)
        // Note: Share functionality would generate a shareable link or QR code
        // This demo focuses on core curation features
    }
    
    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date()
    }
}

struct ArticleCard: View {
    let article: ArticleCuration.ArticleReference
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let url = article.url {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(URL(string: url)?.host ?? "Article")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text(url)
                            .font(DesignSystem.Typography.body)
                            .lineLimit(2)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text("Added \(relativeTime(from: article.addedAt))")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .modernCard()
                .onTapGesture {
                    if let url = URL(string: url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date()
    }
}

struct EmptyArticlesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48)
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.5)
            
            Text("No articles yet")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("Articles added to this curation will appear here")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(DesignSystem.Colors.surface.opacity(0.5)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

struct LoadedArticleCard: View {
    let article: Article
    @State private var showArticleView = false
    @State private var author: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: { showArticleView = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    // Article image thumbnail
                    if let imageUrl = article.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(DesignSystem.Colors.surface)
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        if let summary = article.summary {
                            Text(summary)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(2)
                        }
                        
                        HStack(spacing: 8) {
                            if let author = author {
                                Text(author.name ?? author.displayName ?? "Anonymous")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                            
                            Text("•")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(relativeTime(from: article.createdAt)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text("•")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text("\(article.estimatedReadingTime) min read")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .modernCard()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showArticleView) {
            ArticleView(article: article)
                .environmentObject(appState)
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
    
    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date()
    }
}

struct AddArticleSheet: View {
    let curation: ArticleCuration
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var articleUrl = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Add Article")
                    .font(DesignSystem.Typography.headline)
                
                Text("Add an article URL to your curation")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                TextField("https://...", text: $articleUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle()
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Button(action: addArticle) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Article")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .disabled(articleUrl.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addArticle() {
        guard !articleUrl.isEmpty else { return }
        
        HapticManager.shared.impact(.light)
        
        Task {
            // Note: Adding articles requires updating the curation event
            // This demo focuses on curation viewing
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    CurationDetailView(
        curation: ArticleCuration(
            id: "1",
            event: NDKEvent(id: "", pubkey: "", createdAt: 0, kind: 30004, tags: [], content: "", sig: ""),
            name: "best-reads-2024",
            title: "Best Reads of 2024",
            description: "A collection of the most insightful articles I've read this year",
            image: nil,
            author: "test",
            createdAt: Date(),
            updatedAt: Date(),
            articles: []
        )
    )
    .environmentObject(AppState())
}
