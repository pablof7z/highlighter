import SwiftUI
import NDKSwift
import NDKSwiftUI

struct CurationDetailView: View {
    let curation: ArticleCuration
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var isFollowing = false
    @State private var showAddArticle = false
    @State private var curator: NDKUserMetadata?
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
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding()
                    }
                    
                    // Curator info
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(curator?.name ?? curator?.displayName ?? "Curator")
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.medium)
                            
                            Text("\(curation.articles.count) articles • Updated \(NDKUIRelativeTime(timestamp: Int64(curation.updatedAt.timeIntervalSince1970)))")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: toggleFollow) {
                            Text(isFollowing ? "Following" : "Follow")
                                .font(DesignSystem.Typography.footnoteMedium)
                        }
                        .unifiedPrimaryButton(enabled: true, variant: .standard)
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
                                    .font(DesignSystem.Typography.footnoteMedium)
                                    .frame(maxWidth: .infinity)
                            }
                            .unifiedPrimaryButton()
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
        let ndk = appState.ndk
        
        for await profile in await ndk.profileManager.subscribe(for: curation.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.curator = profile
            }
            break
        }
    }
    
    private func loadArticles() async {
        let ndk = appState.ndk
        
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
                    ))
                }
            }
        }
        
        // Stream articles by event ID
        if !eventIds.isEmpty {
            Task {
                let filter = NDKFilter(ids: eventIds)
                let articleSource = ndk.subscribe(
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
                
                let articleSource = ndk.subscribe(
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
        Task {
            let ndk = appState.ndk
        guard
                  let signer = appState.activeSigner else { return }
            
            do {
                let pubkey = try await signer.pubkey
                
                if isFollowing {
                    // Unfollow
                    let filter = NDKFilter(
                        authors: [pubkey],
                        kinds: [3]
                    )
                    
                    let events = ndk.subscribe(filter: filter, maxAge: 300, cachePolicy: .cacheWithNetwork).events
                    for await contactListEvent in events {
                        var tags = contactListEvent.tags.filter { tag in
                            !(tag.first == "p" && tag[safe: 1] == curation.author)
                        }
                        
                        let newEvent = try await NDKEventBuilder(ndk: ndk)
                            .kind(3)
                            .content(contactListEvent.content)
                            .tags(tags)
                            .build(signer: signer)
                        
                        try await ndk.publish(newEvent)
                        break
                    }
                } else {
                    // Follow
                    let filter = NDKFilter(
                        authors: [pubkey],
                        kinds: [3]
                    )
                    
                    var tags: [[String]] = []
                    var content = ""
                    
                    let events = ndk.subscribe(filter: filter, maxAge: 300, cachePolicy: .cacheWithNetwork).events
                    for await contactListEvent in events {
                        tags = contactListEvent.tags
                        content = contactListEvent.content
                        break
                    }
                    
                    // Add new follow
                    tags.append(["p", curation.author])
                    
                    let newEvent = try await NDKEventBuilder(ndk: ndk)
                        .kind(3)
                        .content(content)
                        .tags(tags)
                        .build(signer: signer)
                    
                    try await ndk.publish(newEvent)
                }
                
                await MainActor.run {
                    isFollowing.toggle()
                    HapticManager.shared.impact(.medium)
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
    
    private func shareCuration() {
        HapticManager.shared.impact(.light)
        
        // Create shareable nostr: URL
        let nostrURL = "nostr:\(curation.event.id)"
        
        // Create share content
        let shareText = """
        Check out this curation: "\(curation.title)"
        \(curation.description ?? "")
        
        \(nostrURL)
        """
        
        // Present share sheet
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
    
}

struct ArticleCard: View {
    let article: ArticleCuration.ArticleReference
    
    var body: some View {
        if let url = article.url {
            UnifiedCard(
                variant: .standard,
                action: {
                    if let url = URL(string: url) {
                        HapticManager.shared.impact(.light)
                        UIApplication.shared.open(url)
                    }
                }
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        // Domain indicator with icon
                        HStack(spacing: DesignSystem.Spacing.micro) {
                            Image(systemName: "link.circle.fill")
                                .font(DesignSystem.Typography.micro)
                                .foregroundColor(DesignSystem.Colors.primary.opacity(0.8))
                            
                            Text(URL(string: url)?.host ?? "Article")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        // URL preview
                        Text(url)
                            .font(DesignSystem.Typography.body)
                            .lineLimit(2)
                            .foregroundColor(DesignSystem.Colors.text)
                            .multilineTextAlignment(.leading)
                        
                        // Time with icon
                        HStack(spacing: DesignSystem.Spacing.micro) {
                            Image(systemName: "clock")
                                .font(DesignSystem.Typography.micro)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            HStack(spacing: 0) {
                                Text("Added ")
                                NDKUIRelativeTime(timestamp: Int64(article.addedAt.timeIntervalSince1970))
                            }
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.base)
                    
                    // Action indicator
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.05))
                                .frame(width: 32, height: 32)
                        )
                }
            }
            .premiumCardInteraction()
        }
    }
    
}

struct EmptyArticlesView: View {
    @State private var iconRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            // Animated icon container
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.1),
                                DesignSystem.Colors.secondary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)
                    .blur(radius: 10)
                
                // Icon with subtle animation
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    iconRotation = 5
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                }
            }
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("No articles yet")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text("Articles added to this curation will appear here")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
        .padding(.horizontal, DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.border.opacity(0.5),
                                    DesignSystem.Colors.border.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: DesignSystem.Colors.primary.opacity(0.05),
            radius: 20,
            x: 0,
            y: 10
        )
    }
}

struct LoadedArticleCard: View {
    let article: Article
    @State private var showArticleView = false
    @State private var author: NDKUserMetadata?
    @State private var isPressed = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        UnifiedCard(
            variant: .elevated,
            isSelected: isPressed,
            action: {
                HapticManager.shared.impact(.light)
                showArticleView = true
            }
        ) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
                // Article image thumbnail with loading state
                Group {
                    if let imageUrl = article.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure(_):
                                ZStack {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [DesignSystem.Colors.primary.opacity(0.1), DesignSystem.Colors.secondary.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    Image(systemName: "photo")
                                        .font(DesignSystem.Typography.title3)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                            case .empty:
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                    .fill(DesignSystem.Colors.surfaceSecondary)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .clipped()
                    } else {
                        // No image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.primary.opacity(0.05), DesignSystem.Colors.secondary.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Image(systemName: "doc.richtext")
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(DesignSystem.Colors.primary.opacity(0.3))
                        }
                        .frame(width: 80, height: 80)
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    // Title with better typography
                    Text(article.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Summary if available
                    if let summary = article.summary {
                        Text(summary)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Metadata row with icons
                    HStack(spacing: DesignSystem.Spacing.small) {
                        // Author with icon
                        if let author = author {
                            HStack(spacing: DesignSystem.Spacing.micro) {
                                Image(systemName: "person.circle.fill")
                                    .font(DesignSystem.Typography.micro)
                                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.6))
                                
                                Text(author.displayName ?? author.name ?? "Anonymous")
                                    .font(DesignSystem.Typography.footnoteMedium)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .lineLimit(1)
                            }
                            
                            Text("•")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                        
                        // Time with icon
                        HStack(spacing: DesignSystem.Spacing.micro) {
                            Image(systemName: "clock")
                                .font(DesignSystem.Typography.micro)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            NDKUIRelativeTime(timestamp: Int64(article.createdAt.timeIntervalSince1970))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        // Reading time
                        HStack(spacing: DesignSystem.Spacing.micro) {
                            Image(systemName: "book")
                                .font(DesignSystem.Typography.micro)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Text("\(article.estimatedReadingTime) min")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer(minLength: 0)
            }
        }
        .pressEvents(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .sheet(isPresented: $showArticleView) {
            ArticleView(article: article)
                .environmentObject(appState)
        }
        .task {
            await loadAuthor()
        }
    }
    
    private func loadAuthor() async {
        let ndk = appState.ndk
        
        for await profile in await ndk.profileManager.subscribe(for: article.author, maxAge: TimeConstants.hour) {
            await MainActor.run {
                self.author = profile
            }
            break
        }
    }
    
}

struct AddArticleSheet: View {
    let curation: ArticleCuration
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var articleUrl = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                // Header section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    HStack {
                        Image(systemName: "link.badge.plus")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Spacer()
                    }
                    
                    Text("Add Article")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Add an article URL to your curation")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.bottom, DesignSystem.Spacing.medium)
                
                // URL Input field with modern styling
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    HStack {
                        Image(systemName: "link")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        TextField("https://example.com/article", text: $articleUrl)
                            .font(DesignSystem.Typography.body)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .focused($isTextFieldFocused)
                    }
                    .padding(DesignSystem.Spacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .strokeBorder(
                                        isTextFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
                                        lineWidth: isTextFieldFocused ? 2 : 1
                                    )
                            )
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isTextFieldFocused)
                }
                
                Spacer()
                
                // Action button
                Button(action: addArticle) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "plus.circle.fill")
                        }
                        Text("Add Article")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .unifiedPrimaryButton()
                .disabled(articleUrl.isEmpty || isLoading)
                .opacity(articleUrl.isEmpty ? 0.6 : 1.0)
                
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
        guard !articleUrl.isEmpty,
              let ndk = appState.ndk,
              let signer = appState.activeSigner else { return }
        
        HapticManager.shared.impact(.light)
        isLoading = true
        
        Task {
            do {
                // Create updated article references
                var updatedArticles = curation.articles
                let newReference = ArticleCuration.ArticleReference(from: ["r", articleUrl])
                updatedArticles.append(newReference)
                
                // Create updated tags
                var tags = curation.event.tags.filter { tag in
                    tag.first != "a" && tag.first != "e"
                }
                
                // Add article references as tags
                for article in updatedArticles {
                    if let eventId = article.eventId {
                        tags.append(["e", eventId])
                    } else if let eventAddress = article.eventAddress {
                        tags.append(["a", eventAddress])
                    } else if let url = article.url {
                        tags.append(["r", url])
                    }
                }
                
                // Keep other metadata tags
                tags.append(["d", curation.name])
                tags.append(["title", curation.title])
                if let description = curation.description {
                    tags.append(["summary", description])
                }
                if let image = curation.image {
                    tags.append(["image", image])
                }
                
                // Create updated curation event
                let updatedEvent = try await NDKEventBuilder(ndk: ndk)
                    .kind(30004)
                    .content(curation.event.content)
                    .tags(tags)
                    .build(signer: signer)
                
                try await ndk.publish(updatedEvent)
                
                await MainActor.run {
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to add article: \(error.localizedDescription)"
                    showError = true
                    HapticManager.shared.notification(.error)
                }
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
