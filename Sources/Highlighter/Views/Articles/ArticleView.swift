import SwiftUI
import NDKSwift
import NDKSwiftUI

struct ArticleView: View {
    let article: Article
    @EnvironmentObject var appState: AppState
    @State private var selectedRange: NSRange?
    @State private var showHighlightCreator = false
    @State private var highlights: [HighlightEvent] = []
    @State private var scrollOffset: CGFloat = 0
    @State private var showingSwarmOverlay = false
    @State private var selectedText = ""
    @State private var contextText = ""
    @State private var isBookmarked = false
    @State private var showShareSheet = false
    @State private var readingProgress: Double = 0
    @State private var estimatedReadTime: Int = 0
    @State private var fontScale: CGFloat = 1.0
    @State private var showReadingSettings = false
    @State private var highlightOpacity: Double = 0.3
    @State private var selectedHighlight: HighlightEvent?
    @State private var showHighlightDetail = false
    @State private var author: NDKUserProfile?
    @State private var showTextSelection = false
    @StateObject private var swarmManager = SwarmHighlightManager(ndk: NDK(relayUrls: []))
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        articleViewContent
            .navigationBarHidden(true)
            .sheet(isPresented: $showHighlightCreator) {
                highlightCreatorSheet
            }
            .sheet(isPresented: $showingSwarmOverlay) {
                swarmOverlaySheet
            }
            .sheet(isPresented: $showHighlightDetail) {
                highlightDetailSheet
            }
            .sheet(isPresented: $showReadingSettings) {
                readingSettingsSheet
            }
            .sheet(isPresented: $showTextSelection) {
                textSelectionSheet
            }
            .task {
                await initializeArticle()
            }
            .onDisappear {
                // End reading session when leaving the article
                appState.readingProgressService.endReadingSession()
            }
    }
    
    // MARK: - Main Article View Content
    private var articleViewContent: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                UnifiedGradientBackground(style: .subtle)
                mainContent(geometry: geometry)
                floatingNavBar(in: geometry)
            }
        }
    }
    
    // MARK: - Sheet Views
    private var highlightCreatorSheet: some View {
        CreateHighlightView()
    }
    
    private var swarmOverlaySheet: some View {
        SwarmOverlayView(
            text: article.content
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
    
    @ViewBuilder
    private var highlightDetailSheet: some View {
        if let highlight = selectedHighlight {
            HighlightDetailView(highlight: highlight)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
    
    private var readingSettingsSheet: some View {
        ReadingSettingsView(
            fontScale: $fontScale,
            highlightOpacity: $highlightOpacity
        )
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
    
    private var textSelectionSheet: some View {
        TextSelectionView(
            content: article.content,
            source: article.title,
            author: author?.displayName ?? String(article.author.prefix(16))
        )
    }
    
    // MARK: - Main Content View
    private func mainContent(geometry: GeometryProxy) -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 0) {
                    heroHeader(in: geometry)
                        .id("top")
                    
                    readingProgressBar(geometry: geometry)
                    articleContentSection()
                }
                .background(scrollTracker(geometry: geometry))
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
    }
    
    // MARK: - Reading Progress Bar
    private func readingProgressBar(geometry: GeometryProxy) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.secondary,
                            DesignSystem.Colors.primary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geo.size.width * readingProgress, height: 3)
                .animation(.spring(response: 0.3), value: readingProgress)
        }
        .frame(height: 3)
        .padding(.top, -3)
    }
    
    // MARK: - Article Content Section
    private func articleContentSection() -> some View {
        VStack(alignment: .leading, spacing: .ds.xxl) {
            titleSection()
                .padding(.horizontal, .ds.screenPadding)
                .padding(.top, .ds.large)
            
            Divider()
                .padding(.horizontal, .ds.screenPadding)
            
            articleBodyContent()
                .padding(.horizontal, .ds.screenPadding)
            
            if !highlights.isEmpty {
                Divider()
                    .padding(.horizontal, .ds.screenPadding)
                
                CommunityHighlightsSection(
                    highlights: highlights,
                    onHighlightTap: { highlight in
                        selectedHighlight = highlight
                        showHighlightDetail = true
                    }
                )
                .padding(.horizontal, .ds.screenPadding)
            }
            
            RelatedArticlesSection(currentArticle: article)
                .padding(.top, .ds.sectionSpacing)
            
            ArticleFooter(article: article)
                .padding(.horizontal, .ds.screenPadding)
                .padding(.bottom, 100)
        }
    }
    
    // MARK: - Title Section
    private func titleSection() -> some View {
        VStack(alignment: .leading, spacing: .ds.large) {
            Text(article.title)
                .font(.ds.largeTitle.weight(.bold))
                .foregroundColor(.ds.text)
                .fixedSize(horizontal: false, vertical: true)
                .premiumEntrance(delay: 0.1)
            
            if let summary = article.summary {
                Text(summary)
                    .font(.ds.headline.weight(.regular))
                    .foregroundColor(.ds.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .premiumEntrance(delay: 0.15)
            }
            
            articleMetadataRow()
        }
    }
    
    // MARK: - Article Metadata Row
    private func articleMetadataRow() -> some View {
        HStack(spacing: .ds.large) {
            AuthorChip(pubkey: article.author, profile: author)
                .premiumEntrance(delay: 0.2)
            
            HStack(spacing: .ds.small) {
                Image(systemName: "clock")
                    .font(.ds.caption)
                Text("\(estimatedReadTime) min read")
                    .font(.ds.caption)
            }
            .foregroundColor(.ds.textTertiary)
            .premiumEntrance(delay: 0.25)
            
            Spacer()
            
            ReadingSettingsButton(showSettings: $showReadingSettings)
                .premiumEntrance(delay: 0.3)
        }
    }
    
    // MARK: - Article Body Content
    @ViewBuilder
    private func articleBodyContent() -> some View {
        if article.content.isEmpty {
            emptyContentView()
        } else if let ndk = appState.ndk {
            SelectableMarkdownRenderer(
                content: article.content,
                ndk: ndk,
                onTextSelected: { text, range in
                    // Extract context from the full content
                    let nsString = article.content as NSString
                    let contextRange = NSRange(
                        location: max(0, range.location - 50),
                        length: min(nsString.length - max(0, range.location - 50), range.length + 100)
                    )
                    let context = nsString.substring(with: contextRange)
                    handleTextSelection(text: text, context: context, range: range)
                }
            )
            .markdownStyle(createArticleMarkdownStyle(fontScale: fontScale))
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("NDK not initialized")
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
                .padding()
        }
    }
    
    // MARK: - Empty Content View
    private func emptyContentView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.ds.textTertiary)
            
            Text("No content available")
                .font(.ds.headline)
                .foregroundColor(.ds.textSecondary)
            
            Text("This article appears to be empty.")
                .font(.ds.body)
                .foregroundColor(.ds.textTertiary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    // MARK: - Scroll Tracker
    private func scrollTracker(geometry: GeometryProxy) -> some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named("scroll")).minY
                )
                .onAppear {
                    calculateReadingProgress(geo: geo, in: geometry)
                }
                .onChange(of: geo.frame(in: .named("scroll")).minY) { _, _ in
                    calculateReadingProgress(geo: geo, in: geometry)
                }
        }
    }
    
    // MARK: - Initialize Article
    private func initializeArticle() async {
        // Initialize article
        
        await loadHighlights()
        await loadAuthor()
        estimatedReadTime = article.estimatedReadingTime
        impactMedium.prepare()
        selectionFeedback.prepare()
        
        // Initialize swarm manager
        if let ndk = appState.ndk {
            swarmManager.ndk = ndk
            let articleUrl = article.tags.first(where: { $0.first == "r" })?[safe: 1]
            swarmManager.loadSwarmHighlights(
                for: articleUrl,
                articleEvent: article.identifier
            )
        }
        
        // Restore previous reading progress
        if let previousProgress = appState.readingProgressService.getProgress(for: article.id) {
            readingProgress = previousProgress.progress
            // Note: We could also restore scroll position here if needed
        }
        
        // Start reading session
        appState.readingProgressService.startReadingSession(for: article.id)
    }
    
    // MARK: - Enhanced Components
    
    private func heroHeader(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            // Dynamic background with parallax and blur
            if let imageUrl = article.image {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        ZStack {
                            // Blurred background layer
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 400)
                                .blur(radius: 30)
                                .scaleEffect(1.2)
                                .offset(y: scrollOffset * 0.3)
                                .opacity(0.6)
                            
                            // Main image
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width - 40, height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: .ds.large, style: .continuous))
                                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                                .offset(y: scrollOffset * 0.5)
                                .scaleEffect(1 + (scrollOffset > 0 ? scrollOffset * 0.0005 : 0))
                        }
                    case .empty, .failure:
                        UnifiedGradientBackground(style: .subtle)
                            .frame(width: geometry.size.width, height: 400)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                UnifiedGradientBackground(style: .mesh)
                    .frame(width: geometry.size.width, height: 400)
            }
            
            // Enhanced gradient overlay
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.clear,
                        DesignSystem.Colors.background.opacity(0.3),
                        DesignSystem.Colors.background.opacity(0.7),
                        DesignSystem.Colors.background.opacity(0.95),
                        DesignSystem.Colors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                DesignSystem.Colors.background
                    .frame(height: 50)
            }
        }
        .frame(height: 400)
        .clipped()
    }
    
    private func floatingNavBar(in geometry: GeometryProxy) -> some View {
        let isScrolled = scrollOffset < -50
        
        return VStack(spacing: 0) {
            HStack {
                // Back button with dynamic styling
                Button(action: { dismiss() }) {
                    HStack(spacing: .ds.mini) {
                        Image(systemName: "arrow.left")
                            .font(.ds.body).fontWeight(.semibold)
                        
                        if isScrolled {
                            Text("Articles")
                                .font(.ds.footnoteMedium)
                                .transition(.asymmetric(
                                    insertion: .push(from: .leading),
                                    removal: .push(from: .trailing)
                                ))
                        }
                    }
                    .foregroundColor(.ds.text)
                    .padding(.horizontal, .ds.base)
                    .padding(.vertical, .ds.small)
                    .background(
                        Capsule()
                            .fill(DesignSystem.Colors.surface.opacity(isScrolled ? 0.95 : 0.8))
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    )
                }
                .magneticHover()
                
                Spacer()
                
                // Action buttons
                HStack(spacing: .ds.base) {
                    // Swarm view button with indicator
                    Button(action: { showingSwarmOverlay = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "sparkles")
                                .font(.ds.headline).fontWeight(.medium)
                                .foregroundColor(.ds.primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(DesignSystem.Colors.surface.opacity(isScrolled ? 0.95 : 0.8))
                                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                                )
                            
                            if !highlights.isEmpty {
                                Circle()
                                    .fill(DesignSystem.Colors.secondary)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -5, y: 5)
                            }
                        }
                    }
                    .magneticHover()
                    
                    // Text selection mode
                    Button(action: { showTextSelection = true }) {
                        Image(systemName: "highlighter")
                            .font(.ds.headline).fontWeight(.medium)
                            .foregroundColor(.ds.secondary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.surface.opacity(isScrolled ? 0.95 : 0.8))
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            )
                    }
                    .magneticHover()
                    
                    // Enhanced bookmark button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isBookmarked.toggle()
                        }
                        if isBookmarked {
                            HapticManager.shared.notification(.success)
                        } else {
                            HapticManager.shared.impact(.light)
                        }
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.ds.headline).fontWeight(.medium)
                            .foregroundColor(isBookmarked ? .ds.primary : .ds.text)
                            .symbolEffect(.bounce, value: isBookmarked)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.surface.opacity(isScrolled ? 0.95 : 0.8))
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            )
                    }
                    .magneticHover()
                    
                    // Share button
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.ds.headline).fontWeight(.medium)
                            .foregroundColor(.ds.text)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.surface.opacity(isScrolled ? 0.95 : 0.8))
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            )
                    }
                    .magneticHover()
                }
            }
            .padding(.horizontal, .ds.screenPadding)
            .padding(.top, geometry.safeAreaInsets.top + 10)
            .padding(.bottom, .ds.base)
            
            // Article title when scrolled
            if isScrolled {
                Text(article.title)
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                    .padding(.horizontal, .ds.screenPadding)
                    .padding(.bottom, .ds.base)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(
            DesignSystem.Colors.background
                .opacity(isScrolled ? 0.95 : 0)
                .ignoresSafeArea()
                .background(.ultraThinMaterial.opacity(isScrolled ? 1 : 0))
        )
        .animation(.spring(response: 0.3), value: isScrolled)
    }
    
    private var selectionToolbar: some View {
        VStack(spacing: .ds.small) {
            HStack(spacing: .ds.small) {
                // Highlight button
                Button(action: {
                    selectionFeedback.selectionChanged()
                    createHighlight()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "highlighter")
                            .font(.ds.title3).fontWeight(.medium)
                        Text("Highlight")
                            .font(.ds.caption).fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(width: 70, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.secondary,
                                        DesignSystem.Colors.secondaryDark
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .ds.secondary.opacity(0.3), radius: 6, y: 3)
                    )
                }
                .unifiedBounceButton()
                
                // Copy button
                Button(action: {
                    UIPasteboard.general.string = selectedText
                    HapticManager.shared.notification(.success)
                    selectedRange = nil
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.ds.title3).fontWeight(.medium)
                        Text("Copy")
                            .font(.ds.caption).fontWeight(.medium)
                    }
                    .foregroundColor(.ds.text)
                    .frame(width: 70, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                            .fill(DesignSystem.Colors.surface)
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    )
                }
                .unifiedBounceButton()
                
                // Dismiss button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedRange = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.ds.callout).fontWeight(.medium)
                        .foregroundColor(.ds.textSecondary)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surface)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        )
                }
            }
            
            // Selected text preview
            Text(selectedText)
                .font(.ds.caption)
                .foregroundColor(.ds.textSecondary)
                .lineLimit(2)
                .padding(.horizontal, .ds.base)
                .padding(.vertical, .ds.small)
                .frame(maxWidth: 250)
                .background(
                    RoundedRectangle(cornerRadius: .ds.small, style: .continuous)
                        .fill(DesignSystem.Colors.surface.opacity(0.9))
                )
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleTextSelection(text: String, context: String, range: NSRange) {
        selectedText = text
        contextText = context
        selectedRange = range
        selectionFeedback.selectionChanged()
    }
    
    private func createHighlight() {
        showHighlightCreator = true
        selectedRange = nil
    }
    
    
    private func calculateReadingProgress(geo: GeometryProxy, in containerGeo: GeometryProxy) {
        let totalHeight = geo.size.height
        let visibleHeight = containerGeo.size.height
        let currentOffset = -geo.frame(in: .named("scroll")).minY
        
        let progress = (currentOffset + visibleHeight) / totalHeight
        readingProgress = min(max(0, progress), 1)
        
        // Update reading progress in the service
        appState.readingProgressService.updateProgress(
            for: article.id,
            progress: readingProgress,
            scrollPosition: currentOffset
        )
    }
    
    
    private func createArticleMarkdownStyle(fontScale: CGFloat) -> MarkdownConfiguration {
        var config = MarkdownConfiguration()
        
        config.textColor = .ds.text
        config.headingColor = .ds.text
        config.linkColor = .ds.primary
        config.codeBackgroundColor = DesignSystem.Colors.surfaceSecondary
        config.blockquoteColor = .ds.textSecondary
        config.blockquoteBorderColor = .ds.primary
        config.mentionColor = .ds.primary
        config.hashtagColor = .ds.secondary
        config.nostrEntityColor = .ds.primary
        
        config.bodyFont = .system(size: 17 * fontScale, weight: .regular, design: .serif)
        config.h1Font = .system(size: 32 * fontScale, weight: .bold, design: .serif)
        config.h2Font = .system(size: 26 * fontScale, weight: .semibold, design: .serif)
        config.h3Font = .system(size: 22 * fontScale, weight: .medium, design: .serif)
        
        config.contentPadding = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return config
    }
    
    private func loadAuthor() async {
        guard let ndk = appState.ndk else { return }
        
        let profileDataSource = ndk.observe(
            filter: NDKFilter(
                authors: [article.author],
                kinds: [0]
            ),
            maxAge: 3600,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileDataSource.events {
            if let fetchedProfile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                await MainActor.run {
                    self.author = fetchedProfile
                }
                break
            }
        }
    }
    
    private func loadHighlights() async {
        guard let ndk = appState.ndk else { return }
        
        // Create filter for highlights related to this article
        var tagsFilter: [String: Set<String>] = [:]
        
        // Add article event ID tag
        tagsFilter["e"] = [article.id]
        
        // Also look for highlights by the same author
        let filter = NDKFilter(
            kinds: [9802], // NIP-84 highlight kind
            limit: 50,
            tags: tagsFilter
        )
        
        // Fetch events using NDK's outbox
        let dataSource = ndk.observe(
            filter: filter,
            maxAge: TimeConstants.hour,
            cachePolicy: .cacheWithNetwork
        )
        
        var loadedHighlights: [HighlightEvent] = []
        
        for await event in dataSource.events {
            // Extract context from tags (not needed here as HighlightEvent.init will extract it)
            
            // Create HighlightEvent from NDK event
            do {
                let highlight = try HighlightEvent(from: event)
                loadedHighlights.append(highlight)
            } catch {
                // Skip invalid highlight events
            }
        }
        
        // Sort by creation date, newest first and update state
        await MainActor.run {
            highlights = loadedHighlights.sorted { $0.createdAt > $1.createdAt }
        }
    }
}

// MARK: - Supporting Views

struct AuthorChip: View {
    let pubkey: String
    let profile: NDKUserProfile?
    
    var body: some View {
        HStack(spacing: .ds.small) {
            Group {
                if let picture = profile?.picture, let url = URL(string: picture) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(DesignSystem.Colors.surfaceSecondary)
                            .overlay(
                                Text(displayName.prefix(1).uppercased())
                                    .font(.ds.captionMedium)
                                    .foregroundColor(.ds.text)
                            )
                    }
                } else {
                    Circle()
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .overlay(
                            Text(displayName.prefix(1).uppercased())
                                .font(.ds.captionMedium)
                                .foregroundColor(.ds.text)
                        )
                }
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            
            Text(displayName)
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.text)
        }
        .padding(.horizontal, .ds.base)
        .padding(.vertical, .ds.mini)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.surfaceSecondary.opacity(0.5))
        )
    }
    
    private var displayName: String {
        profile?.displayName ?? String(pubkey.prefix(8))
    }
}

struct ReadingSettingsButton: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "textformat.size")
                .font(.ds.body).fontWeight(.medium)
                .foregroundColor(.ds.text)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.surfaceSecondary.opacity(0.5))
                )
        }
    }
}


// MARK: - Enhanced Supporting Components

struct CommunityHighlightsSection: View {
    let highlights: [HighlightEvent]
    let onHighlightTap: (HighlightEvent) -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.large) {
            Text("Community Highlights")
                .font(.ds.headline)
                .foregroundColor(.ds.text)
            
            VStack(spacing: .ds.base) {
                ForEach(highlights.prefix(5), id: \.id) { highlight in
                    HighlightCard(highlight: highlight)
                        .environmentObject(appState)
                }
            }
        }
    }
}

struct RelatedArticlesSection: View {
    let currentArticle: Article
    @State private var relatedArticles: [Article] = []
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if !relatedArticles.isEmpty {
            VStack(alignment: .leading, spacing: .ds.large) {
                Text("You Might Also Like")
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .padding(.horizontal, .ds.screenPadding)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .ds.medium) {
                        ForEach(relatedArticles, id: \.id) { article in
                            RelatedArticleCard(article: article)
                                .frame(width: 300)
                        }
                    }
                    .padding(.horizontal, .ds.screenPadding)
                }
            }
        }
    }
    
    private func loadRelatedArticles() {
        guard let ndk = appState.ndk else { return }
        
        Task {
            // Create filter for articles from the same author or with similar tags
            var filters: [NDKFilter] = []
            
            // Articles from the same author
            filters.append(NDKFilter(
                authors: [currentArticle.author],
                kinds: [30023], // Long-form content
                limit: 10
            ))
            
            // Articles with similar tags
            let articleTags = currentArticle.tags.filter { $0.count > 1 && $0[0] == "t" }.map { $0[1] }
            if !articleTags.isEmpty {
                var tagsFilter: [String: Set<String>] = [:]
                tagsFilter["t"] = Set(articleTags)
                
                filters.append(NDKFilter(
                    kinds: [30023],
                    limit: 10,
                    tags: tagsFilter
                ))
            }
            
            var allRelatedArticles: [Article] = []
            
            for filter in filters {
                // Use NDK's outbox to fetch events
                let dataSource = ndk.observe(
                    filter: filter,
                    maxAge: TimeConstants.hour,
                    cachePolicy: .cacheWithNetwork
                )
                
                for await event in dataSource.events {
                    // Skip the current article
                    if event.id == currentArticle.id { continue }
                    
                    do {
                        let relatedArticle = try Article(from: event)
                        allRelatedArticles.append(relatedArticle)
                    } catch {
                        // Skip invalid articles
                    }
                    
                    // Limit to prevent too many results
                    if allRelatedArticles.count >= 20 { break }
                }
            }
            
            // Remove duplicates based on article ID and limit to 6 articles
            var uniqueArticleIds = Set<String>()
            let uniqueArticles = allRelatedArticles.filter { article in
                if uniqueArticleIds.contains(article.id) {
                    return false
                }
                uniqueArticleIds.insert(article.id)
                return true
            }.prefix(6)
            
            await MainActor.run {
                relatedArticles = Array(uniqueArticles)
            }
        }
    }
}

struct RelatedArticleCard: View {
    let article: Article
    
    var body: some View {
        NavigationLink(destination: ArticleView(article: article)) {
            VStack(alignment: .leading, spacing: .ds.base) {
                if let imageUrl = article.image {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 160)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                        case .empty, .failure:
                            RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                                .fill(DesignSystem.Colors.surfaceSecondary)
                                .frame(height: 160)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.ds.title2)
                                        .foregroundColor(.ds.textTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: .ds.small) {
                    Text(article.title)
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let summary = article.summary {
                        Text(summary)
                            .font(.ds.callout)
                            .foregroundColor(.ds.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        Text(String(article.author.prefix(16)))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                        
                        Spacer()
                        
                        Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                    }
                }
                .padding(.horizontal, .ds.base)
                .padding(.bottom, .ds.base)
            }
        }
        .modernCard(noPadding: true)
    }
}

struct ArticleFooter: View {
    let article: Article
    
    var body: some View {
        VStack(spacing: .ds.large) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: .ds.small) {
                    Text("Thanks for reading")
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                    
                    Text("Support the author")
                        .font(.ds.callout)
                        .foregroundColor(.ds.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Zap Author")
                    }
                    .font(.ds.footnoteMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, .ds.medium)
                    .padding(.vertical, .ds.small)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.ds.secondary, .ds.secondaryDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
                .magneticHover()
            }
            
            // Tags
            if !article.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .ds.small) {
                        ForEach(article.hashtags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.ds.caption)
                                .foregroundColor(.ds.primary)
                                .padding(.horizontal, .ds.base)
                                .padding(.vertical, .ds.micro)
                                .background(
                                    Capsule()
                                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Sheet Views

struct ReadingSettingsView: View {
    @Binding var fontScale: CGFloat
    @Binding var highlightOpacity: Double
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .ds.large) {
                // Font size control
                VStack(alignment: .leading, spacing: .ds.base) {
                    Text("Text Size")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.text)
                    
                    HStack {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundColor(.ds.textSecondary)
                        
                        Slider(value: $fontScale, in: 0.8...1.5)
                            .tint(.ds.primary)
                        
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(.ds.textSecondary)
                    }
                    
                    Text("The quick brown fox jumps over the lazy dog")
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: .ds.small, style: .continuous)
                                .fill(DesignSystem.Colors.surfaceSecondary)
                        )
                }
                
                // Highlight opacity control
                VStack(alignment: .leading, spacing: .ds.base) {
                    Text("Highlight Visibility")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.text)
                    
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.ds.textSecondary)
                        
                        Slider(value: $highlightOpacity, in: 0.1...0.5)
                            .tint(.ds.secondary)
                        
                        Image(systemName: "circle.fill")
                            .foregroundColor(.ds.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ArticleHighlightDetailView: View {
    let highlight: HighlightEvent
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .ds.large) {
                // Highlight content
                Text("\"\(highlight.content)\"")
                    .font(.ds.title3)
                    .italic()
                    .foregroundColor(.ds.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                            .fill(DesignSystem.Colors.highlightSubtle)
                    )
                
                if let comment = highlight.comment {
                    VStack(alignment: .leading, spacing: .ds.small) {
                        Text("Comment")
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.ds.textSecondary)
                        
                        Text(comment)
                            .font(.ds.body)
                            .foregroundColor(.ds.text)
                    }
                }
                
                // Author info
                HStack {
                    Circle()
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(highlight.author.prefix(2)).uppercased())
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.text)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(String(highlight.author.prefix(8)))
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.ds.text)
                        
                        NDKUIRelativeTime(timestamp: Int64(highlight.createdAt.timeIntervalSince1970))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textTertiary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("21")
                        }
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, .ds.base)
                        .padding(.vertical, .ds.small)
                        .background(
                            Capsule()
                                .fill(Color.ds.secondary)
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Highlight")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Add this extension if not already present
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ArticleView(article: Article(
        id: "test",
        identifier: "test-article",
        title: "The Future of Knowledge Sharing",
        summary: "Exploring how decentralized protocols are reshaping the way we share and preserve human knowledge.",
        content: """
        # The Future of Knowledge Sharing
        
        In an age where information flows freely yet centralized platforms control the narrative, we stand at a crossroads. The question isn't whether we need change, but how quickly we can adapt to a new paradigm.
        
        ## The Current Landscape
        
        Today's knowledge ecosystem is dominated by gatekeepers. Social media algorithms decide what we see, search engines filter our queries, and content platforms monetize our creations while retaining ownership.
        
        This model has served its purpose, but the cracks are showing. Censorship, data breaches, and the loss of digital sovereignty have become commonplace. We've traded convenience for control, and the price is becoming too high to bear.
        
        ## Enter Decentralization
        
        Imagine a world where your thoughts, insights, and creations belong to you. Where no single entity can silence your voice or erase your contributions. This isn't a utopian dream—it's the promise of decentralized protocols like Nostr.
        
        By distributing data across multiple relays and using cryptographic signatures for verification, we create a system that's both resilient and trustworthy. Your content lives on, regardless of any single point of failure.
        
        ## The Power of Collective Intelligence
        
        But decentralization is just the foundation. The real magic happens when we layer collective intelligence on top. Picture millions of minds collaborating, highlighting the best insights, and building upon each other's work.
        
        This is swarm intelligence in action. When readers highlight passages, they're not just bookmarking for themselves—they're signaling value to the entire network. The most resonant ideas naturally rise to the surface, creating a meritocracy of thought.
        
        ## Looking Ahead
        
        The tools we build today will shape how future generations learn, think, and create. By embracing open protocols and collective curation, we're not just preserving knowledge—we're accelerating its evolution.
        
        The future of knowledge sharing isn't about any single platform or technology. It's about creating systems that amplify human potential while respecting individual sovereignty. And that future is being written right now, one highlight at a time.
        """,
        author: "npub1example",
        publishedAt: Date(),
        image: "https://picsum.photos/800/400",
        hashtags: ["knowledge", "decentralization", "nostr", "future"],
        createdAt: Timestamp.now
    ))
    .environmentObject(AppState())
}