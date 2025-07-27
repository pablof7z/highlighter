import SwiftUI
import UniformTypeIdentifiers
import NDKSwift

struct SmartArticleImportView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var importManager = SmartImportManager()
    @State private var isDragging = false
    @State private var urlText = ""
    @State private var showURLError = false
    @State private var dragOffset: CGSize = .zero
    @State private var dragScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0
    @State private var particlePositions: [ImportParticle] = []
    @State private var processingProgress: Double = 0
    @State private var showSuccessAnimation = false
    @State private var selectedSuggestions: Set<String> = []
    @State private var magneticPull: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var floatingOffset: CGFloat = 0
    @State private var aiThinkingAnimation = false
    @State private var brainWaveAnimation: CGFloat = 0
    @State private var neuralNetworkPaths: [NeuralPath] = []
    @State private var showAdvancedOptions = false
    @State private var importQuality: ImportQuality = .balanced
    @State private var contentComplexityScore: Double = 0
    @State private var readingTimeEstimate: Int = 0
    @Environment(\.dismiss) var dismiss
    @Namespace private var animation
    
    enum ImportQuality: String, CaseIterable {
        case quick = "Quick"
        case balanced = "Balanced"
        case thorough = "Thorough"
        
        var icon: String {
            switch self {
            case .quick: return "hare"
            case .balanced: return "dial.medium"
            case .thorough: return "tortoise"
            }
        }
        
        var color: Color {
            switch self {
            case .quick: return .green
            case .balanced: return .orange
            case .thorough: return .purple
            }
        }
        
        var description: String {
            switch self {
            case .quick: return "Fast processing, basic suggestions"
            case .balanced: return "Optimal speed and quality"
            case .thorough: return "Deep analysis, best suggestions"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                UnifiedGradientBackground(style: .subtle)
                
                // Neural network visualization
                NeuralNetworkVisualization(
                    paths: neuralNetworkPaths,
                    isActive: importManager.isProcessing
                )
                .opacity(0.3)
                .blur(radius: 2)
                
                // Floating particles
                ForEach(particlePositions) { particle in
                    ImportParticleView(particle: particle)
                }
                
                ScrollView {
                    VStack(spacing: .ds.sectionSpacing) {
                        // Hero section with animated brain
                        heroSection
                            .padding(.top, .ds.large)
                        
                        // Main import area
                        if !importManager.isProcessing && importManager.processedArticle == nil {
                            importSection
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 1.1).combined(with: .opacity)
                                ))
                        }
                        
                        // Processing animation
                        if importManager.isProcessing {
                            processingSection
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Results section
                        if let article = importManager.processedArticle {
                            resultsSection(article: article)
                                .transition(.push(from: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, .ds.screenPadding)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if importManager.processedArticle != nil {
                        Button("Import") {
                            performImport()
                        }
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.primary)
                        .disabled(selectedSuggestions.isEmpty)
                    }
                }
            }
        }
        .onAppear {
            startAnimations()
            generateNeuralPaths()
        }
        .alert("Invalid URL", isPresented: $showURLError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid URL starting with http:// or https://")
        }
    }
    
    // MARK: - Hero Section
    
    @ViewBuilder
    private var heroSection: some View {
        VStack(spacing: .ds.medium) {
            // Animated AI brain icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.purple.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(1 + brainWaveAnimation * 0.2)
                    .blur(radius: 10)
                
                // Brain icon with neural connections
                Image(systemName: "brain")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.pulse, options: .repeating, value: aiThinkingAnimation)
                    .scaleEffect(1 + floatingOffset / 100)
                    .rotationEffect(.degrees(Foundation.sin(brainWaveAnimation * .pi) * 5))
                
                // Neural sparkles
                ForEach(0..<6) { index in
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                        .offset(x: 35)
                        .rotationEffect(.degrees(Double(index) * 60 + rotationAngle))
                        .opacity(importManager.isProcessing ? 1 : 0.3)
                        .scaleEffect(importManager.isProcessing ? 1.2 : 1)
                }
            }
            .offset(y: floatingOffset)
            
            VStack(spacing: .ds.small) {
                Text("Smart Article Import")
                    .font(.ds.largeTitle)
                    .foregroundColor(.ds.text)
                
                Text("AI-powered highlight suggestions")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
            }
        }
    }
    
    // MARK: - Import Section
    
    @ViewBuilder
    private var importSection: some View {
        VStack(spacing: .ds.large) {
            // Quality selector
            qualitySelector
                .premiumEntrance(delay: 0.1)
            
            // Drop zone
            dropZone
                .premiumEntrance(delay: 0.2)
            
            // URL input
            urlInput
                .premiumEntrance(delay: 0.3)
            
            // Advanced options
            if showAdvancedOptions {
                advancedOptionsSection
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
    }
    
    @ViewBuilder
    private var qualitySelector: some View {
        VStack(spacing: .ds.base) {
            Text("Processing Quality")
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.textSecondary)
            
            HStack(spacing: .ds.base) {
                ForEach(ImportQuality.allCases, id: \.self) { quality in
                    QualityOptionCard(
                        quality: quality,
                        isSelected: importQuality == quality,
                        action: {
                            selectQuality(quality)
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var dropZone: some View {
        ZStack {
            // Background with animated gradient
            RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            isDragging ? Color.purple.opacity(0.1) : Color.ds.surfaceSecondary,
                            isDragging ? Color.orange.opacity(0.1) : Color.ds.surfaceSecondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: isDragging ? [10, 5] : [15, 10]
                            )
                        )
                        .foregroundColor(
                            isDragging ? .ds.primary : .ds.textTertiary.opacity(0.5)
                        )
                        .animation(.easeInOut(duration: 0.3), value: isDragging)
                )
            
            // Magnetic effect overlay
            if isDragging {
                RadialGradient(
                    colors: [
                        Color.purple.opacity(0.2 * magneticPull),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 150
                )
                .clipShape(RoundedRectangle(cornerRadius: .ds.large, style: .continuous))
                .blur(radius: 20)
            }
            
            // Content
            VStack(spacing: .ds.medium) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isDragging ? [.purple, .orange] : [.ds.textTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(dragScale)
                    .offset(dragOffset)
                    .symbolEffect(.bounce, value: isDragging)
                
                VStack(spacing: .ds.small) {
                    Text("Drop Article Here")
                        .font(.ds.headline)
                        .foregroundColor(isDragging ? .ds.primary : .ds.text)
                    
                    Text("PDF, TXT, MD, or any text file")
                        .font(.ds.footnote)
                        .foregroundColor(.ds.textSecondary)
                }
                .opacity(isDragging ? 0.5 : 1)
            }
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 200)
        .scaleEffect(1 + magneticPull * 0.05)
        .rotation3DEffect(
            .degrees(isDragging ? 5 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 1
        )
        .onDrop(of: [.text, .pdf, .plainText], isTargeted: $isDragging) { providers in
            handleDrop(providers)
            return true
        }
    }
    
    @ViewBuilder
    private var urlInput: some View {
        VStack(alignment: .leading, spacing: .ds.small) {
            Text("Or paste a URL")
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.textSecondary)
            
            HStack(spacing: .ds.base) {
                HStack {
                    Image(systemName: "link")
                        .font(.system(size: 16))
                        .foregroundColor(.ds.textTertiary)
                    
                    TextField("https://stratechery.com/2024/article-title", text: $urlText)
                        .font(.ds.body)
                        .foregroundColor(.ds.text)
                        .textFieldStyle(.plain)
                        .submitLabel(.go)
                        .onSubmit {
                            importFromURL()
                        }
                }
                .padding(.horizontal, .ds.base)
                .padding(.vertical, .ds.small)
                .background(DesignSystem.Colors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                
                Button(action: importFromURL) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            urlText.isEmpty ? AnyShapeStyle(Color.ds.textTertiary) :
                                AnyShapeStyle(LinearGradient(
                                    colors: [.purple, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                }
                .disabled(urlText.isEmpty)
                .magneticHover()
            }
        }
    }
    
    @ViewBuilder
    private var advancedOptionsSection: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            Toggle(isOn: $importManager.includeImages) {
                Label("Extract Images", systemImage: "photo")
                    .font(.ds.callout)
            }
            .tint(.ds.primary)
            
            Toggle(isOn: $importManager.preserveFormatting) {
                Label("Preserve Formatting", systemImage: "textformat")
                    .font(.ds.callout)
            }
            .tint(.ds.primary)
            
            Toggle(isOn: $importManager.detectQuotes) {
                Label("Auto-detect Quotes", systemImage: "quote.bubble")
                    .font(.ds.callout)
            }
            .tint(.ds.primary)
        }
        .padding(.ds.medium)
        .background(DesignSystem.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
    }
    
    // MARK: - Processing Section
    
    @ViewBuilder
    private var processingSection: some View {
        VStack(spacing: .ds.large) {
            // AI thinking animation
            AIThinkingAnimation(progress: processingProgress)
            
            VStack(spacing: .ds.base) {
                Text("Analyzing Content")
                    .font(.ds.title2)
                    .foregroundColor(.ds.text)
                
                Text(importManager.processingStatus)
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Progress bar with glow effect
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .frame(height: 8)
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * processingProgress, height: 8)
                    
                    // Glow
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.6), .orange.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * processingProgress, height: 8)
                        .blur(radius: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, .ds.large)
        }
        .padding(.vertical, 60)
        .onAppear {
            simulateProcessing()
        }
    }
    
    // MARK: - Results Section
    
    @ViewBuilder
    private func resultsSection(article: ProcessedArticle) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Article preview with live highlights
                ScrollView {
                    VStack(alignment: .leading, spacing: .ds.large) {
                        // Article header
                        VStack(alignment: .leading, spacing: .ds.small) {
                            Text(article.title)
                                .font(.ds.largeTitle)
                                .foregroundColor(.ds.text)
                            
                            if let author = article.author {
                                Text("by \(author)")
                                    .font(.ds.body)
                                    .foregroundColor(.ds.textSecondary)
                            }
                        }
                        .padding(.horizontal, .ds.screenPadding)
                        .padding(.top, .ds.large)
                        
                        // Live preview with highlights
                        LiveArticlePreview(
                            article: article,
                            selectedSuggestions: selectedSuggestions,
                            onHighlightTap: { suggestionId in
                                toggleSuggestion(suggestionId)
                            }
                        )
                        .padding(.horizontal, .ds.screenPadding)
                    }
                    .padding(.bottom, 100)
                }
                .frame(width: geometry.size.width * 0.6)
                .background(DesignSystem.Colors.background)
                
                // Divider
                Rectangle()
                    .fill(DesignSystem.Colors.divider)
                    .frame(width: 1)
                
                // Right side - AI suggestions panel
                ScrollView {
                    VStack(spacing: .ds.large) {
                        // Article metrics
                        ArticleMetricsCard(
                            article: article,
                            complexityScore: contentComplexityScore,
                            readingTime: readingTimeEstimate,
                            selectedCount: selectedSuggestions.count
                        )
                        .premiumEntrance(delay: 0.1)
                        .padding(.top, .ds.large)
                        
                        // AI suggestions header
                        HStack {
                            Label("AI Analysis", systemImage: "brain")
                                .font(.ds.headline)
                                .foregroundColor(.ds.text)
                            
                            Spacer()
                            
                            // Select all/none buttons
                            HStack(spacing: .ds.small) {
                                Button("All") {
                                    selectAllSuggestions(article)
                                }
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.primary)
                                
                                Text("/")
                                    .font(.ds.footnote)
                                    .foregroundColor(.ds.textTertiary)
                                
                                Button("None") {
                                    selectedSuggestions.removeAll()
                                }
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.primary)
                            }
                        }
                        .premiumEntrance(delay: 0.2)
                        
                        // Suggested highlights with enhanced UI
                        VStack(spacing: .ds.base) {
                            ForEach(Array(article.suggestedHighlights.enumerated()), id: \.element.id) { index, suggestion in
                                EnhancedSuggestionCard(
                                    suggestion: suggestion,
                                    isSelected: selectedSuggestions.contains(suggestion.id),
                                    index: index,
                                    action: {
                                        toggleSuggestion(suggestion.id)
                                    }
                                )
                                .premiumEntrance(delay: 0.3 + Double(index) * 0.05)
                            }
                        }
                    }
                    .padding(.horizontal, .ds.screenPadding)
                    .padding(.bottom, 100)
                }
                .frame(width: geometry.size.width * 0.4)
                .background(DesignSystem.Colors.surfaceSecondary.opacity(0.3))
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDrop(_ providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        
        HapticManager.shared.impact(.medium)
        generateImportParticles()
        
        // Magnetic effect
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            magneticPull = 1.0
            dragScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                magneticPull = 0
                dragScale = 1.0
            }
            
            // Process the dropped file
            if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { (url, error) in
                    if let url = url as? URL {
                        DispatchQueue.main.async {
                            importManager.importFromFile(url)
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (text, error) in
                    if let text = text as? String {
                        DispatchQueue.main.async {
                            importManager.importFromText(text)
                        }
                    }
                }
            }
        }
    }
    
    private func importFromURL() {
        guard !urlText.isEmpty else { return }
        
        if urlText.hasPrefix("http://") || urlText.hasPrefix("https://") {
            HapticManager.shared.impact(.medium)
            importManager.importFromURL(urlText)
        } else {
            showURLError = true
            HapticManager.shared.notification(.error)
        }
    }
    
    private func selectQuality(_ quality: ImportQuality) {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            importQuality = quality
            importManager.processingQuality = quality
        }
    }
    
    private func toggleSuggestion(_ id: String) {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if selectedSuggestions.contains(id) {
                selectedSuggestions.remove(id)
            } else {
                selectedSuggestions.insert(id)
            }
        }
    }
    
    private func selectAllSuggestions(_ article: ProcessedArticle) {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedSuggestions = Set(article.suggestedHighlights.map { $0.id })
        }
    }
    
    private func performImport() {
        guard let article = importManager.processedArticle else { return }
        
        HapticManager.shared.notification(.success)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showSuccessAnimation = true
        }
        
        // Create highlights from selected suggestions
        let selectedHighlights = article.suggestedHighlights.filter { selectedSuggestions.contains($0.id) }
        
        Task {
            do {
                // First, create and publish the article if it doesn't exist
                _ = await createArticleEvent(from: article)
                
                // Then create highlights for selected suggestions
                for suggestion in selectedHighlights {
                    let highlight = HighlightEvent(
                        content: suggestion.text,
                        context: suggestion.hasContext ? suggestion.text : nil,
                        comment: suggestion.reason
                    )
                    
                    try await PublishingService.shared.publishHighlight(highlight)
                }
                
                // Dismiss after successful import
                await MainActor.run {
                    dismiss()
                }
            } catch {
                // Show error if publishing fails
                await MainActor.run {
                    // Could show an alert here, but for now just dismiss
                    dismiss()
                }
            }
        }
    }
    
    private func createArticleEvent(from article: ProcessedArticle) async -> NDKEvent? {
        guard let ndk = appState.ndk,
              let signer = appState.activeSigner else { return nil }
        
        // Create article event if needed
        var tags: [[String]] = []
        
        // Add title tag
        tags.append(["title", article.title])
        
        // Add author tag if available
        if let author = article.author {
            tags.append(["author", author])
        }
        
        // Add bookstr tag
        tags.append(["t", "bookstr"])
        
        do {
            let event = try await NDKEventBuilder(ndk: ndk)
                .kind(30023) // Long-form content
                .content(article.preview)
                .tags(tags)
                .build(signer: signer)
            
            _ = try await ndk.publish(event)
            return event
        } catch {
            return nil
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Brain wave animation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            brainWaveAnimation = 1
        }
        
        // Floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            floatingOffset = -10
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Glow animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 1
        }
        
        // Generate initial particles
        generateParticles()
    }
    
    private func generateParticles() {
        for _ in 0..<15 {
            let particle = ImportParticle(
                x: .random(in: -50...UIScreen.main.bounds.width + 50),
                y: .random(in: -50...UIScreen.main.bounds.height + 50),
                size: .random(in: 4...12),
                color: Bool.random() ? .purple : .orange,
                speed: .random(in: 20...60)
            )
            particlePositions.append(particle)
        }
    }
    
    private func generateImportParticles() {
        for _ in 0..<20 {
            let particle = ImportParticle(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                size: .random(in: 6...16),
                color: .orange,
                speed: .random(in: 40...100)
            )
            particlePositions.append(particle)
        }
    }
    
    private func generateNeuralPaths() {
        for _ in 0..<8 {
            let path = NeuralPath(
                startX: .random(in: 0...UIScreen.main.bounds.width),
                startY: .random(in: 0...UIScreen.main.bounds.height),
                endX: .random(in: 0...UIScreen.main.bounds.width),
                endY: .random(in: 0...UIScreen.main.bounds.height),
                delay: .random(in: 0...2)
            )
            neuralNetworkPaths.append(path)
        }
    }
    
    private func simulateProcessing() {
        // Simulate processing stages
        let stages = [
            "Extracting text content...",
            "Analyzing document structure...",
            "Identifying key concepts...",
            "Running AI analysis...",
            "Generating suggestions...",
            "Ranking by importance...",
            "Finalizing recommendations..."
        ]
        
        for (index, stage) in stages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    importManager.processingStatus = stage
                    processingProgress = Double(index + 1) / Double(stages.count)
                }
                
                if index == stages.count - 1 {
                    // Processing complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        contentComplexityScore = Double.random(in: 0.6...0.9)
                        readingTimeEstimate = Int.random(in: 5...15)
                        // completeProcessing is now handled by the async AI analysis
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QualityOptionCard: View {
    let quality: SmartArticleImportView.ImportQuality
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .ds.small) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                                AnyShapeStyle(LinearGradient(
                                    colors: [quality.color, quality.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )) :
                                AnyShapeStyle(DesignSystem.Colors.surfaceSecondary)
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? quality.color.opacity(0.3) : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: isSelected ? quality.color.opacity(0.3) : .clear,
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                    
                    Image(systemName: quality.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .ds.textSecondary)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .scaleEffect(isPressed ? 0.9 : 1)
                
                Text(quality.rawValue)
                    .font(.ds.footnoteMedium)
                    .foregroundColor(isSelected ? quality.color : .ds.text)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }
    }
}

struct ArticleInfoCard: View {
    let article: ProcessedArticle
    let complexityScore: Double
    let readingTime: Int
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            // Title and source
            VStack(alignment: .leading, spacing: .ds.small) {
                Text(article.title)
                    .font(.ds.title3)
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                
                if let author = article.author {
                    Text("by \(author)")
                        .font(.ds.footnote)
                        .foregroundColor(.ds.textSecondary)
                }
            }
            
            // Metrics
            HStack(spacing: .ds.large) {
                MetricBadge(
                    icon: "clock",
                    value: "\(readingTime) min",
                    color: .blue
                )
                
                MetricBadge(
                    icon: "brain",
                    value: "Score \(Int(complexityScore * 100))",
                    color: .purple
                )
                
                MetricBadge(
                    icon: "highlighter",
                    value: "\(article.suggestedHighlights.count) found",
                    color: .orange
                )
            }
            
            // Preview
            if showDetails {
                Text(article.preview)
                    .font(.ds.callout)
                    .foregroundColor(.ds.textSecondary)
                    .lineLimit(4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Expand button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDetails.toggle()
                }
                HapticManager.shared.impact(.light)
            }) {
                HStack {
                    Text(showDetails ? "Show Less" : "Show Preview")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.ds.primary)
                        .rotationEffect(.degrees(showDetails ? 180 : 0))
                }
            }
        }
        .padding(.ds.medium)
        .background(
            RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                .fill(DesignSystem.Colors.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.2),
                                    Color.orange.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct MetricBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .ds.micro) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.text)
        }
        .padding(.horizontal, .ds.small)
        .padding(.vertical, .ds.micro)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct SuggestedHighlightCard: View {
    let suggestion: ArticleSuggestedHighlight
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    @State private var sparkleAnimation = false
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: .ds.base) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                                AnyShapeStyle(LinearGradient(
                                    colors: [.orange, .orange.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )) :
                                AnyShapeStyle(DesignSystem.Colors.surfaceSecondary)
                        )
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.orange.opacity(0.3) : Color.ds.textTertiary.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isHovered ? 1.1 : 1)
                
                // Content
                VStack(alignment: .leading, spacing: .ds.small) {
                    // Highlight text
                    Text("\"\(suggestion.text)\"")
                        .font(.ds.callout)
                        .foregroundColor(.ds.text)
                        .italic()
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // Metadata
                    HStack(spacing: .ds.base) {
                        // Confidence score
                        HStack(spacing: .ds.micro) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .symbolEffect(.pulse, value: sparkleAnimation)
                            
                            Text("\(Int(suggestion.confidence * 100))% confidence")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                        }
                        
                        // Reason
                        if let reason = suggestion.reason {
                            Text("• \(reason)")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                // Context indicator
                if suggestion.hasContext {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14))
                        .foregroundColor(.ds.textTertiary)
                }
            }
            .padding(.ds.base)
            .background(
                RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                    .fill(
                        isSelected ?
                            AnyShapeStyle(Color.orange.opacity(0.05)) :
                            AnyShapeStyle(DesignSystem.Colors.surfaceSecondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                            .stroke(
                                isSelected ? Color.orange.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
            if hovering {
                sparkleAnimation.toggle()
            }
        }
    }
}

struct AIThinkingAnimation: View {
    let progress: Double
    @State private var nodeAnimations: [Bool] = Array(repeating: false, count: 6)
    @State private var connectionOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Neural network connections
            ForEach(0..<5) { i in
                Path { path in
                    let angle1 = Double(i) * 72 * .pi / 180
                    let angle2 = Double(i + 1) * 72 * .pi / 180
                    let radius: CGFloat = 60
                    
                    let x1 = cos(angle1) * radius
                    let y1 = sin(angle1) * radius
                    let x2 = cos(angle2) * radius
                    let y2 = sin(angle2) * radius
                    
                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .orange.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .opacity(connectionOpacity)
                .blur(radius: 1)
            }
            
            // Neural nodes
            ForEach(0..<6) { i in
                let angle = Double(i) * 60 * .pi / 180
                let radius: CGFloat = 60
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                i % 2 == 0 ? Color.purple : Color.orange,
                                i % 2 == 0 ? Color.purple.opacity(0.3) : Color.orange.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    )
                    .position(x: x, y: y)
                    .scaleEffect(nodeAnimations[i] ? 1.3 : 1)
                    .opacity(nodeAnimations[i] ? 1 : 0.6)
            }
            
            // Center brain
            Image(systemName: "brain")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: progress)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            animateNodes()
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                connectionOpacity = 0.8
            }
        }
    }
    
    private func animateNodes() {
        for i in 0..<6 {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.1)
            ) {
                nodeAnimations[i] = true
            }
        }
    }
}

// MARK: - Supporting Models

struct ImportParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    let speed: CGFloat
    let isBurst: Bool = false
}

struct ImportParticleView: View {
    let particle: ImportParticle
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        particle.color,
                        particle.color.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .position(x: particle.x + offset.width, y: particle.y + offset.height)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                if particle.isBurst {
                    // Burst animation
                    let angle = Double.random(in: 0...360) * .pi / 180
                    let distance = particle.speed
                    
                    withAnimation(.easeOut(duration: 1)) {
                        offset = CGSize(
                            width: cos(angle) * distance,
                            height: sin(angle) * distance
                        )
                        opacity = 0
                        scale = 0.5
                    }
                } else {
                    // Floating animation
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                    ) {
                        offset = CGSize(
                            width: .random(in: -30...30),
                            height: .random(in: -50...50)
                        )
                    }
                }
            }
    }
}

struct NeuralPath: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let delay: Double
}

struct NeuralNetworkVisualization: View {
    let paths: [NeuralPath]
    let isActive: Bool
    @State private var pathAnimation: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(paths) { path in
                Path { p in
                    p.move(to: CGPoint(x: path.startX, y: path.startY))
                    p.addQuadCurve(
                        to: CGPoint(x: path.endX, y: path.endY),
                        control: CGPoint(
                            x: (path.startX + path.endX) / 2 + .random(in: -50...50),
                            y: (path.startY + path.endY) / 2 + .random(in: -50...50)
                        )
                    )
                }
                .trim(from: 0, to: isActive ? pathAnimation : 0)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .orange.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round)
                )
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                    .delay(path.delay),
                    value: isActive
                )
            }
        }
        .onAppear {
            if isActive {
                withAnimation {
                    pathAnimation = 1
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            withAnimation {
                pathAnimation = newValue ? 1 : 0
            }
        }
    }
}

// MARK: - Import Manager

class SmartImportManager: ObservableObject {
    @Published var isProcessing = false
    @Published var processingStatus = ""
    @Published var processedArticle: ProcessedArticle?
    @Published var includeImages = true
    @Published var preserveFormatting = true
    @Published var detectQuotes = true
    @Published var processingQuality: SmartArticleImportView.ImportQuality = .balanced
    
    private let aiEngine = AIHighlightEngine()
    var currentContent: ImportedContent?
    
    struct ImportedContent {
        let text: String
        let title: String?
        let author: String?
        let url: String?
    }
    
    func importFromURL(_ urlString: String) {
        isProcessing = true
        processingStatus = "Fetching article..."
        
        Task {
            do {
                // Fetch content from URL
                guard let url = URL(string: urlString) else {
                    throw ImportError.invalidURL
                }
                
                processingStatus = "Downloading content..."
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let htmlString = String(data: data, encoding: .utf8) {
                    // Extract text content from HTML
                    let text = extractTextFromHTML(htmlString)
                    let title = extractTitleFromHTML(htmlString)
                    
                    currentContent = ImportedContent(
                        text: text,
                        title: title,
                        author: nil,
                        url: urlString
                    )
                    
                    await MainActor.run {
                        self.processContent()
                    }
                } else {
                    throw ImportError.invalidContent
                }
            } catch {
                await MainActor.run {
                    self.processingStatus = "Failed to fetch article"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func importFromFile(_ url: URL) {
        isProcessing = true
        processingStatus = "Reading file..."
        
        Task {
            do {
                let data = try Data(contentsOf: url)
                
                if url.pathExtension.lowercased() == "pdf" {
                    // Handle PDF files - would need PDFKit import
                    processingStatus = "Extracting text from PDF..."
                    // For now, just show error
                    throw ImportError.unsupportedFormat("PDF extraction not yet implemented")
                } else if let text = String(data: data, encoding: .utf8) {
                    // Plain text or markdown file
                    let title = url.deletingPathExtension().lastPathComponent
                    
                    currentContent = ImportedContent(
                        text: text,
                        title: title,
                        author: nil,
                        url: url.absoluteString
                    )
                    
                    await MainActor.run {
                        self.processContent()
                    }
                } else {
                    throw ImportError.invalidContent
                }
            } catch {
                await MainActor.run {
                    self.processingStatus = "Failed to read file: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func importFromText(_ text: String) {
        isProcessing = true
        processingStatus = "Processing text..."
        
        currentContent = ImportedContent(
            text: text,
            title: nil,
            author: nil,
            url: nil
        )
        
        processContent()
    }
    
    private func processContent() {
        Task { @MainActor in
            await performAIAnalysis()
        }
    }
    
    @MainActor
    private func performAIAnalysis() async {
        // Use the actual content provided to the import manager
        guard let content = currentContent else {
            processingStatus = "No content to analyze"
            isProcessing = false
            return
        }
        
        do {
            // Map quality to analysis mode
            let analysisMode: AIHighlightEngine.AnalysisMode
            switch processingQuality {
            case .quick:
                analysisMode = .quick
            case .balanced:
                analysisMode = .balanced
            case .thorough:
                analysisMode = .thorough
            }
            
            // Perform AI analysis on actual content
            let result = try await aiEngine.analyzeText(content.text, mode: analysisMode)
            
            // Convert AI suggestions to article highlights
            let suggestions = result.suggestions.map { suggestion in
                ArticleSuggestedHighlight(
                    text: suggestion.text,
                    confidence: suggestion.confidence,
                    reason: suggestion.reason,
                    hasContext: suggestion.context != nil,
                    category: mapAICategory(suggestion.category)
                )
            }
            
            // Create processed article with real content and AI results
            processedArticle = ProcessedArticle(
                title: content.title ?? "Untitled Article",
                author: content.author,
                preview: String(content.text.prefix(200)) + "...",
                fullText: content.text,
                suggestedHighlights: suggestions
            )
            
            isProcessing = false
        } catch {
            processingStatus = "Error analyzing content: \(error.localizedDescription)"
            isProcessing = false
        }
    }
    
    private func mapAICategory(_ category: AIHighlightEngine.SuggestionCategory) -> HighlightCategory {
        switch category {
        case .thesisStatement:
            return .thesis
        case .statistic:
            return .statistic
        case .keyInsight, .novelConcept:
            return .insight
        case .quote:
            return .quote
        case .definition:
            return .definition
        default:
            return .insight
        }
    }
    
    func completeProcessing() {
        // This is now handled by performAIAnalysis
        // The method is kept for compatibility with the UI flow
    }
    
    // MARK: - Helper Methods
    
    private func extractTextFromHTML(_ html: String) -> String {
        var processedHTML = html
        
        // Remove script and style content first
        let scriptPattern = "<script[^>]*>[\\s\\S]*?</script>"
        processedHTML = processedHTML.replacingOccurrences(of: scriptPattern, with: "", options: [.regularExpression, .caseInsensitive])
        
        let stylePattern = "<style[^>]*>[\\s\\S]*?</style>"
        processedHTML = processedHTML.replacingOccurrences(of: stylePattern, with: "", options: [.regularExpression, .caseInsensitive])
        
        // Convert common block elements to line breaks for better formatting
        let blockElements = ["</p>", "</div>", "</h1>", "</h2>", "</h3>", "</h4>", "</h5>", "</h6>", "</li>", "</br>", "<br>", "<br/>", "</tr>"]
        for element in blockElements {
            processedHTML = processedHTML.replacingOccurrences(of: element, with: "\n", options: .caseInsensitive)
        }
        
        // Convert list items to bullets
        processedHTML = processedHTML.replacingOccurrences(of: "<li>", with: "\n• ", options: .caseInsensitive)
        
        // Remove all remaining HTML tags
        let tagPattern = "<[^>]+>"
        let stripped = processedHTML.replacingOccurrences(of: tagPattern, with: "", options: .regularExpression)
        
        // Decode common HTML entities
        let entities = [
            ("&nbsp;", " "),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#39;", "'"),
            ("&apos;", "'"),
            ("&mdash;", "—"),
            ("&ndash;", "–"),
            ("&hellip;", "..."),
            ("&copy;", "©"),
            ("&reg;", "®"),
            ("&trade;", "™"),
            ("&euro;", "€"),
            ("&pound;", "£"),
            ("&cent;", "¢"),
            ("&yen;", "¥")
        ]
        
        var decoded = stripped
        for (entity, replacement) in entities {
            decoded = decoded.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Decode numeric entities
        let numericPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericPattern, options: []) {
            let matches = regex.matches(in: decoded, options: [], range: NSRange(decoded.startIndex..., in: decoded))
            var result = decoded
            for match in matches.reversed() {
                if let range = Range(match.range, in: decoded),
                   let codeRange = Range(match.range(at: 1), in: decoded),
                   let code = Int(decoded[codeRange]),
                   let scalar = UnicodeScalar(code) {
                    result.replaceSubrange(range, with: String(Character(scalar)))
                }
            }
            decoded = result
        }
        
        // Clean up excessive whitespace
        let lines = decoded.components(separatedBy: .newlines)
        let cleanedLines = lines.map { line in
            // Replace multiple spaces with single space
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        }
        let filtered = cleanedLines.filter { !$0.isEmpty }
        
        // Join with proper paragraph separation
        return filtered.joined(separator: "\n\n")
    }
    
    private func extractTitleFromHTML(_ html: String) -> String? {
        // Try multiple methods to extract title
        
        // Method 1: Standard <title> tag
        if let titleRange = html.range(of: "<title[^>]*>(.*?)</title>", options: [.regularExpression, .caseInsensitive]) {
            let titleTag = String(html[titleRange])
            let cleanTitle = titleTag
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Decode HTML entities in title
            let decodedTitle = cleanTitle
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#39;", with: "'")
                .replacingOccurrences(of: "&apos;", with: "'")
            
            if !decodedTitle.isEmpty {
                return decodedTitle
            }
        }
        
        // Method 2: Try og:title meta tag (common in modern websites)
        if let metaRange = html.range(of: "<meta[^>]*property=[\"']og:title[\"'][^>]*content=[\"']([^\"']+)[\"'][^>]*>", options: [.regularExpression, .caseInsensitive]) {
            let metaTag = String(html[metaRange])
            if let contentRange = metaTag.range(of: "content=[\"']([^\"']+)[\"']", options: .regularExpression) {
                let content = String(metaTag[contentRange])
                let cleanContent = content
                    .replacingOccurrences(of: "content=[\"']", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "[\"']$", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !cleanContent.isEmpty {
                    return cleanContent
                }
            }
        }
        
        // Method 3: Try first h1 tag
        if let h1Range = html.range(of: "<h1[^>]*>(.*?)</h1>", options: [.regularExpression, .caseInsensitive]) {
            let h1Tag = String(html[h1Range])
            let cleanH1 = h1Tag
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanH1.isEmpty && cleanH1.count < 200 { // Reasonable title length
                return cleanH1
            }
        }
        
        return nil
    }
    
    // MARK: - Errors
    
    enum ImportError: LocalizedError {
        case invalidURL
        case invalidContent
        case unsupportedFormat(String)
        case networkError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL provided"
            case .invalidContent:
                return "Unable to process the content"
            case .unsupportedFormat(let format):
                return "Unsupported format: \(format)"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
}

struct ProcessedArticle {
    let id = UUID()
    let title: String
    let author: String?
    let preview: String
    let fullText: String
    let suggestedHighlights: [ArticleSuggestedHighlight]
}

struct ArticleSuggestedHighlight: Identifiable {
    let id = UUID().uuidString
    let text: String
    let confidence: Double
    let reason: String?
    let hasContext: Bool
    let startIndex: Int
    let endIndex: Int
    let category: HighlightCategory
    
    init(text: String, confidence: Double, reason: String?, hasContext: Bool, startIndex: Int = 0, endIndex: Int = 0, category: HighlightCategory = .insight) {
        self.text = text
        self.confidence = confidence
        self.reason = reason
        self.hasContext = hasContext
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.category = category
    }
}

enum HighlightCategory: String, CaseIterable {
    case thesis = "Thesis"
    case statistic = "Statistic"
    case insight = "Insight"
    case quote = "Quote"
    case definition = "Definition"
    
    var color: Color {
        switch self {
        case .thesis: return .purple
        case .statistic: return .blue
        case .insight: return .orange
        case .quote: return .green
        case .definition: return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .thesis: return "lightbulb.fill"
        case .statistic: return "chart.bar.fill"
        case .insight: return "sparkles"
        case .quote: return "quote.bubble.fill"
        case .definition: return "book.fill"
        }
    }
}

// MARK: - New Enhanced Components

struct LiveArticlePreview: View {
    let article: ProcessedArticle
    let selectedSuggestions: Set<String>
    let onHighlightTap: (String) -> Void
    @State private var hoveredHighlight: String? = nil
    @State private var scrollToHighlight: String? = nil
    @State private var highlightAnimations: [String: Bool] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.large) {
            // Article content with inline highlights
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: .ds.medium) {
                    ForEach(generateContentParagraphs(), id: \.self) { paragraph in
                        HighlightedParagraph(
                            text: paragraph,
                            highlights: findHighlightsInParagraph(paragraph),
                            selectedSuggestions: selectedSuggestions,
                            hoveredHighlight: hoveredHighlight,
                            onHighlightTap: onHighlightTap,
                            onHighlightHover: { id in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredHighlight = id
                                }
                            }
                        )
                        .id(paragraph)
                    }
                }
                .onChange(of: scrollToHighlight) { _, newValue in
                    if let highlight = newValue {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            proxy.scrollTo(highlight, anchor: .center)
                        }
                    }
                }
            }
        }
        .padding(.vertical, .ds.large)
        .background(
            RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.elevated.color, radius: DesignSystem.Shadow.elevated.radius, x: DesignSystem.Shadow.elevated.x, y: DesignSystem.Shadow.elevated.y)
        )
    }
    
    private func generateContentParagraphs() -> [String] {
        // Split the article's full text into paragraphs
        let paragraphs = article.fullText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        return paragraphs.isEmpty ? ["No content available"] : paragraphs
    }
    
    private func findHighlightsInParagraph(_ paragraph: String) -> [ArticleSuggestedHighlight] {
        article.suggestedHighlights.filter { highlight in
            paragraph.contains(highlight.text)
        }
    }
}

struct HighlightedParagraph: View {
    let text: String
    let highlights: [ArticleSuggestedHighlight]
    let selectedSuggestions: Set<String>
    let hoveredHighlight: String?
    let onHighlightTap: (String) -> Void
    let onHighlightHover: (String?) -> Void
    @State private var highlightOpacities: [String: Double] = [:]
    
    var body: some View {
        Text(attributedText)
            .font(.ds.body)
            .lineSpacing(8)
            .onAppear {
                animateHighlights()
            }
    }
    
    private var attributedText: AttributedString {
        var attributed = AttributedString(text)
        
        for highlight in highlights {
            if let range = attributed.range(of: highlight.text) {
                let isSelected = selectedSuggestions.contains(highlight.id)
                let isHovered = hoveredHighlight == highlight.id
                
                attributed[range].backgroundColor = isSelected ? 
                    highlight.category.color.opacity(0.3) : 
                    highlight.category.color.opacity(0.1)
                
                attributed[range].underlineStyle = isHovered ? .single : .none
                attributed[range].underlineColor = UIColor(highlight.category.color)
                
                // Add interactive tap
                attributed[range].link = URL(string: "highlight://\(highlight.id)")
            }
        }
        
        return attributed
    }
    
    private func animateHighlights() {
        for highlight in highlights {
            withAnimation(.easeInOut(duration: 0.5).delay(Double.random(in: 0...0.3))) {
                highlightOpacities[highlight.id] = 1.0
            }
        }
    }
}

struct ArticleMetricsCard: View {
    let article: ProcessedArticle
    let complexityScore: Double
    let readingTime: Int
    let selectedCount: Int
    @State private var animateMetrics = false
    
    var body: some View {
        VStack(spacing: .ds.medium) {
            // Animated metrics
            HStack(spacing: .ds.medium) {
                AnimatedMetric(
                    value: readingTime,
                    unit: "min read",
                    icon: "clock.fill",
                    color: .blue,
                    animate: animateMetrics
                )
                
                AnimatedMetric(
                    value: Int(complexityScore * 100),
                    unit: "complexity",
                    icon: "brain",
                    color: .purple,
                    animate: animateMetrics
                )
                
                AnimatedMetric(
                    value: selectedCount,
                    unit: "selected",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    animate: animateMetrics
                )
            }
            
            // Visual complexity indicator
            ComplexityVisualization(score: complexityScore)
                .frame(height: 40)
        }
        .padding(.ds.medium)
        .background(
            RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: DesignSystem.Shadow.medium.color, radius: DesignSystem.Shadow.medium.radius, x: DesignSystem.Shadow.medium.x, y: DesignSystem.Shadow.medium.y)
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                animateMetrics = true
            }
        }
    }
}

struct AnimatedMetric: View {
    let value: Int
    let unit: String
    let icon: String
    let color: Color
    let animate: Bool
    @State private var displayValue: Int = 0
    
    var body: some View {
        VStack(spacing: .ds.micro) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .symbolEffect(.bounce, value: animate)
            
            Text("\(displayValue)")
                .font(.ds.title2.monospacedDigit())
                .foregroundColor(.ds.text)
            
            Text(unit)
                .font(.ds.caption)
                .foregroundColor(.ds.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if animate {
                animateValue()
            }
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                animateValue()
            }
        }
    }
    
    private func animateValue() {
        let steps = 20
        let stepDuration = 0.5 / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                displayValue = Int(Double(value) * (Double(i) / Double(steps)))
            }
        }
    }
}

struct ComplexityVisualization: View {
    let score: Double
    @State private var animatedScore: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background gradient
                LinearGradient(
                    colors: [.green, .yellow, .orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())
                .opacity(0.3)
                
                // Filled portion
                LinearGradient(
                    colors: [.green, .yellow, .orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())
                .frame(width: geometry.size.width * animatedScore)
                
                // Indicator
                Circle()
                    .fill(.white)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.2), lineWidth: 2)
                    )
                    .offset(x: geometry.size.width * animatedScore - 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animatedScore = score
            }
        }
    }
}

struct EnhancedSuggestionCard: View {
    let suggestion: ArticleSuggestedHighlight
    let isSelected: Bool
    let index: Int
    let action: () -> Void
    @State private var isPressed = false
    @State private var showInsight = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: .ds.base) {
                // Header with category badge
                HStack {
                    CategoryBadge(category: suggestion.category)
                    
                    Spacer()
                    
                    // Confidence indicator
                    ConfidenceIndicator(
                        confidence: suggestion.confidence,
                        isAnimating: glowAnimation
                    )
                }
                
                // Highlight text with enhanced styling
                Text("\"\(suggestion.text)\"")
                    .font(.ds.callout)
                    .foregroundColor(.ds.text)
                    .italic()
                    .lineLimit(showInsight ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // AI reasoning with animation
                if let reason = suggestion.reason {
                    HStack(spacing: .ds.small) {
                        Image(systemName: "cpu")
                            .font(.system(size: 12))
                            .foregroundColor(.purple)
                            .symbolEffect(.pulse, value: isSelected)
                        
                        Text(reason)
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                            .transition(.push(from: .bottom).combined(with: .opacity))
                    }
                }
                
                // Selection indicator with animation
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: .ds.small, style: .continuous)
                            .fill(
                                isSelected ?
                                    AnyShapeStyle(LinearGradient(
                                        colors: [suggestion.category.color, suggestion.category.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )) :
                                    AnyShapeStyle(DesignSystem.Colors.surfaceSecondary)
                            )
                            .frame(width: 40, height: 24)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)
                            .offset(x: isSelected ? 8 : -8)
                            .shadow(color: DesignSystem.Shadow.subtle.color, radius: DesignSystem.Shadow.subtle.radius, x: DesignSystem.Shadow.subtle.x, y: DesignSystem.Shadow.subtle.y)
                    }
                    
                    Text(isSelected ? "Selected" : "Select")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(isSelected ? suggestion.category.color : .ds.textSecondary)
                    
                    Spacer()
                    
                    // Expand button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showInsight.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.ds.textSecondary)
                            .rotationEffect(.degrees(showInsight ? 180 : 0))
                    }
                }
            }
            .padding(.ds.medium)
            .background(
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                        .fill(
                            isSelected ?
                                AnyShapeStyle(suggestion.category.color.opacity(0.1)) :
                                AnyShapeStyle(DesignSystem.Colors.surface)
                        )
                    
                    // Glow effect for selected state
                    if isSelected {
                        RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        suggestion.category.color.opacity(0.5),
                                        suggestion.category.color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .blur(radius: glowAnimation ? 3 : 1)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .shadow(
                color: isSelected ? suggestion.category.color.opacity(0.2) : .black.opacity(0.05),
                radius: isSelected ? 15 : 10,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Action handled by button
        } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }
    }
}

struct CategoryBadge: View {
    let category: HighlightCategory
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: .ds.micro) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .medium))
                .symbolEffect(.pulse, value: pulseAnimation)
            
            Text(category.rawValue)
                .font(.ds.caption.weight(.medium))
        }
        .foregroundColor(category.color)
        .padding(.horizontal, .ds.small)
        .padding(.vertical, .ds.micro)
        .background(
            Capsule()
                .fill(category.color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(category.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                pulseAnimation = true
            }
        }
    }
}

struct ConfidenceIndicator: View {
    let confidence: Double
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(
                        Double(index) < confidence * 5 ?
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 6, height: 6)
                    .scaleEffect(isAnimating && Double(index) < confidence * 5 ? 1.2 : 1)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6)
                        .delay(Double(index) * 0.05),
                        value: isAnimating
                    )
            }
        }
    }
}