import SwiftUI
import NDKSwift
import PDFKit
import WebKit
import Vision
import NaturalLanguage

struct SmartContentImporter: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var importManager = ContentImportManager()
    @State private var selectedTab = ImportTab.files
    @State private var dragOver = false
    @State private var processingAnimation = false
    @State private var particleSystem = ParticleSystem()
    @State private var showSuccessConfetti = false
    @State private var selectedSource: ImportSource?
    @Environment(\.dismiss) var dismiss
    
    enum ImportTab: String, CaseIterable {
        case files = "Files"
        case web = "Web"
        case camera = "Camera"
        
        var icon: String {
            switch self {
            case .files: return "doc.text.fill"
            case .web: return "globe"
            case .camera: return "camera.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                AnimatedMeshBackground()
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                VStack(spacing: 0) {
                    // Custom tab bar with morphing animation
                    MorphingTabBar(selectedTab: $selectedTab, tabs: ImportTab.allCases)
                        .padding(.horizontal, .ds.screenPadding)
                        .padding(.top, .ds.medium)
                    
                    // Content area with animated transitions
                    TabView(selection: $selectedTab) {
                        FileImportView(importManager: importManager, dragOver: $dragOver)
                            .tag(ImportTab.files)
                        
                        WebImportView(importManager: importManager)
                            .tag(ImportTab.web)
                        
                        CameraImportView(importManager: importManager)
                            .tag(ImportTab.camera)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Processing overlay with particle effects
                if importManager.isProcessing {
                    ProcessingOverlay(
                        progress: importManager.progress,
                        currentStep: importManager.currentStep,
                        particleSystem: $particleSystem
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                    .zIndex(100)
                }
                
                // Success confetti
                if showSuccessConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .zIndex(200)
                }
            }
            .navigationTitle("Smart Import")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let source = selectedSource, !importManager.isProcessing {
                        Button("Import") {
                            startImport(source: source)
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.ds.primary)
                    }
                }
            }
        }
        .sheet(item: $importManager.extractedContent) { content in
            SmartHighlightSuggestions(
                content: content,
                onComplete: { highlights in
                    saveHighlights(highlights)
                }
            )
        }
        .onChange(of: importManager.isComplete) { _, isComplete in
            if isComplete {
                showSuccessAnimation()
            }
        }
    }
    
    private func startImport(source: ImportSource) {
        Task {
            HapticManager.shared.impact(.medium)
            try await importManager.importContent(from: source)
        }
    }
    
    private func saveHighlights(_ highlights: [SuggestedHighlight]) {
        Task {
            for highlight in highlights where highlight.isSelected {
                // Create NDKEvent for each highlight
                let event = NDKEvent(
                    id: "",
                    pubkey: appState.userPubkey ?? "",
                    createdAt: Timestamp(Date().timeIntervalSince1970),
                    kind: 9802, // NIP-84 highlight
                    tags: highlight.tags,
                    content: highlight.text,
                    sig: ""
                )
                
                try await appState.ndk?.publish(event)
            }
            
            showSuccessConfetti = true
            HapticManager.shared.notification(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
    
    private func showSuccessAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showSuccessConfetti = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showSuccessConfetti = false
        }
    }
}

// MARK: - File Import View

struct FileImportView: View {
    @ObservedObject var importManager: ContentImportManager
    @Binding var dragOver: Bool
    @State private var showDocumentPicker = false
    @State private var hoveredFileType: FileType?
    @State private var magneticOffset: CGSize = .zero
    
    enum FileType: String, CaseIterable {
        case pdf = "PDF"
        case epub = "EPUB"
        case txt = "Text"
        case markdown = "Markdown"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.text.fill"
            case .epub: return "book.fill"
            case .txt: return "doc.plaintext.fill"
            case .markdown: return "text.quote"
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .pdf: return [.red, .orange]
            case .epub: return [.blue, .purple]
            case .txt: return [.gray, .black]
            case .markdown: return [.green, .mint]
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .ds.large) {
                // Drag and drop area with magnetic effect
                ZStack {
                    RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: dragOver ? [.orange.opacity(0.1), .orange.opacity(0.05)] : [Color.ds.surfaceSecondary, Color.ds.surfaceSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                                .strokeBorder(
                                    style: StrokeStyle(
                                        lineWidth: 2,
                                        dash: dragOver ? [] : [10, 5]
                                    )
                                )
                                .foregroundColor(dragOver ? .orange : .ds.textTertiary)
                        )
                        .frame(height: 200)
                        .scaleEffect(dragOver ? 1.02 : 1)
                        .offset(magneticOffset)
                    
                    VStack(spacing: .ds.medium) {
                        ZStack {
                            ForEach(0..<3) { i in
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: dragOver ? [.orange, .yellow] : [.gray, .gray.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .opacity(dragOver ? 0.3 - Double(i) * 0.1 : 0)
                                    .scaleEffect(1 + CGFloat(i) * 0.2)
                                    .rotationEffect(.degrees(dragOver ? Double(i) * 15 : 0))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: dragOver)
                            }
                            
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: dragOver ? [.orange, .yellow] : [.gray, .gray.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.bounce, value: dragOver)
                        }
                        
                        Text(dragOver ? "Drop your files here" : "Drag & drop files here")
                            .font(.ds.headline)
                            .foregroundColor(dragOver ? .orange : .ds.text)
                        
                        Text("PDF, EPUB, TXT, or Markdown")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
                .onDrop(of: [.pdf, .epub, .plainText], isTargeted: $dragOver) { providers in
                    handleDrop(providers: providers)
                    return true
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragOver)
                
                // File type grid with hover effects
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .ds.medium) {
                    ForEach(FileType.allCases, id: \.self) { fileType in
                        FileTypeCard(
                            fileType: fileType,
                            isHovered: hoveredFileType == fileType,
                            action: {
                                selectFileType(fileType)
                            }
                        )
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                hoveredFileType = hovering ? fileType : nil
                            }
                        }
                    }
                }
                
                // Or button
                HStack {
                    Rectangle()
                        .fill(Color.ds.textTertiary.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .padding(.horizontal, .ds.medium)
                    
                    Rectangle()
                        .fill(Color.ds.textTertiary.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, .ds.small)
                
                // Browse button with ripple effect
                RippleButton(
                    title: "Browse Files",
                    icon: "folder",
                    action: {
                        showDocumentPicker = true
                    }
                )
            }
            .padding(.horizontal, .ds.screenPadding)
            .padding(.vertical, .ds.large)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(
                allowedContentTypes: [.pdf, .epub, .plainText, .text],
                onPick: { url in
                    importManager.selectedSource = .file(url)
                }
            )
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            importManager.selectedSource = .file(url)
                        }
                    }
                }
            }
        }
    }
    
    private func selectFileType(_ type: FileType) {
        showDocumentPicker = true
        HapticManager.shared.impact(.light)
    }
}

// MARK: - File Type Card

struct FileTypeCard: View {
    let fileType: FileImportView.FileType
    let isHovered: Bool
    let action: () -> Void
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            triggerRipple()
            action()
        }) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isHovered ? fileType.gradient.map { $0.opacity(0.15) } : [Color.ds.surfaceSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Ripple effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                fileType.gradient[0].opacity(rippleOpacity),
                                fileType.gradient[0].opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .scaleEffect(rippleScale)
                
                VStack(spacing: .ds.small) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: fileType.gradient.map { $0.opacity(0.1) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: fileType.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: fileType.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isHovered ? 1.1 : 1)
                    }
                    
                    Text(fileType.rawValue)
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                }
                .padding(.ds.medium)
            }
            .frame(height: 120)
            .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
    
    private func triggerRipple() {
        rippleScale = 0
        rippleOpacity = 0.5
        
        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 2
            rippleOpacity = 0
        }
    }
}

// MARK: - Web Import View

struct WebImportView: View {
    @ObservedObject var importManager: ContentImportManager
    @State private var urlString = ""
    @State private var isValidURL = false
    @State private var showPreview = false
    @State private var previewHTML: String?
    @FocusState private var isURLFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: .ds.large) {
                // URL Input with live validation
                VStack(alignment: .leading, spacing: .ds.small) {
                    Label("Article URL", systemImage: "link")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.textSecondary)
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(isValidURL ? .green : .ds.textTertiary)
                            .symbolEffect(.pulse, value: isValidURL)
                        
                        TextField("https://arstechnica.com/article-title", text: $urlString)
                            .textFieldStyle(.plain)
                            .font(.ds.body)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isURLFieldFocused)
                            .onChange(of: urlString) { _, newValue in
                                validateURL(newValue)
                            }
                        
                        if !urlString.isEmpty {
                            Button(action: {
                                urlString = ""
                                isValidURL = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.ds.textTertiary)
                            }
                        }
                    }
                    .padding(.ds.base)
                    .background(
                        RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                            .fill(Color.ds.surfaceSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: .ds.medium, style: .continuous)
                                    .strokeBorder(
                                        isURLFieldFocused ? Color.orange : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                }
                
                // Preview button with loading state
                if isValidURL {
                    VStack(spacing: .ds.medium) {
                        Button(action: {
                            fetchPreview()
                        }) {
                            HStack {
                                Image(systemName: "eye")
                                Text("Preview Article")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .unifiedSecondaryButton()
                        
                        if showPreview, let html = previewHTML {
                            ArticlePreview(html: html)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: .ds.large, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                                        .stroke(Color.ds.textTertiary.opacity(0.2), lineWidth: 1)
                                )
                                .transition(.asymmetric(
                                    insertion: .push(from: .bottom).combined(with: .opacity),
                                    removal: .push(from: .top).combined(with: .opacity)
                                ))
                        }
                    }
                }
                
                // Popular sources with quick import
                VStack(alignment: .leading, spacing: .ds.medium) {
                    Label("Popular Sources", systemImage: "star.fill")
                        .font(.ds.headline)
                        .foregroundColor(.ds.text)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .ds.small) {
                        ForEach(PopularSource.allCases, id: \.self) { source in
                            PopularSourceCard(source: source) { url in
                                urlString = url
                                validateURL(url)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, .ds.screenPadding)
            .padding(.vertical, .ds.large)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPreview)
    }
    
    private func validateURL(_ urlString: String) {
        if let url = URL(string: urlString),
           url.scheme == "https" || url.scheme == "http" {
            isValidURL = true
            importManager.selectedSource = .web(url)
        } else {
            isValidURL = false
        }
    }
    
    private func fetchPreview() {
        guard let url = URL(string: urlString) else { return }
        
        showPreview = true
        Task {
            // Fetch and extract article content
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                await MainActor.run {
                    previewHTML = html
                }
            }
        }
    }
}

// MARK: - Camera Import View

struct CameraImportView: View {
    @ObservedObject var importManager: ContentImportManager
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var recognizedText: String?
    @State private var scanAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: .ds.large) {
                // Camera preview area
                ZStack {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: .ds.large, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                            .fill(Color.ds.surfaceSecondary)
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: .ds.medium) {
                                    ZStack {
                                        // Scanning animation
                                        if scanAnimation {
                                            ForEach(0..<3) { i in
                                                RoundedRectangle(cornerRadius: .ds.medium)
                                                    .stroke(Color.orange.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                                                    .scaleEffect(1 + CGFloat(i) * 0.2)
                                                    .opacity(scanAnimation ? 0 : 1)
                                                    .animation(
                                                        .easeOut(duration: 1.5)
                                                        .repeatForever(autoreverses: false)
                                                        .delay(Double(i) * 0.2),
                                                        value: scanAnimation
                                                    )
                                            }
                                        }
                                        
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 60))
                                            .foregroundColor(.orange)
                                            .symbolEffect(.pulse)
                                    }
                                    .frame(width: 100, height: 100)
                                    
                                    Text("Capture text from books or documents")
                                        .font(.ds.body)
                                        .foregroundColor(.ds.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                            )
                    }
                }
                .onAppear {
                    scanAnimation = true
                }
                
                // Capture button with ripple effect
                RippleButton(
                    title: capturedImage == nil ? "Open Camera" : "Retake Photo",
                    icon: "camera.fill",
                    action: {
                        showCamera = true
                    }
                )
                
                // OCR Results
                if let text = recognizedText {
                    VStack(alignment: .leading, spacing: .ds.small) {
                        Label("Recognized Text", systemImage: "text.viewfinder")
                            .font(.ds.headline)
                            .foregroundColor(.ds.text)
                        
                        ScrollView {
                            Text(text)
                                .font(.ds.body)
                                .foregroundColor(.ds.text)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                        .background(Color.ds.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
                    }
                    .transition(.push(from: .bottom).combined(with: .opacity))
                }
                
                // Tips for better OCR
                TipsCard()
            }
            .padding(.horizontal, .ds.screenPadding)
            .padding(.vertical, .ds.large)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $capturedImage) { image in
                if let image = image {
                    performOCR(on: image)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: recognizedText != nil)
    }
    
    private func performOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                recognizedText = recognizedStrings.joined(separator: "\n")
                if let text = recognizedText {
                    importManager.selectedSource = .text(text)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
        }
    }
}

// MARK: - Supporting Types





// MARK: - Content Import Manager

@MainActor
class ContentImportManager: ObservableObject {
    @Published var selectedSource: ImportSource?
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var currentStep = ""
    @Published var extractedContent: ExtractedContent?
    @Published var isComplete = false
    
    func importContent(from source: ImportSource) async throws {
        isProcessing = true
        progress = 0
        
        // Step 1: Extract text
        currentStep = "Extracting text..."
        progress = 0.2
        let text = try await extractText(from: source)
        
        // Step 2: Analyze content
        currentStep = "Analyzing content..."
        progress = 0.4
        let suggestions = await analyzeContent(text)
        
        // Step 3: Generate metadata
        currentStep = "Generating metadata..."
        progress = 0.6
        let metadata = extractMetadata(from: text)
        
        // Step 4: Prepare highlights
        currentStep = "Preparing highlights..."
        progress = 0.8
        
        extractedContent = ExtractedContent(
            title: metadata.title,
            author: metadata.author,
            content: text,
            source: source,
            suggestedHighlights: suggestions
        )
        
        progress = 1.0
        isProcessing = false
        isComplete = true
    }
    
    private func extractText(from source: ImportSource) async throws -> String {
        switch source {
        case .file(let url):
            return try await extractFromFile(url)
        case .web(let url):
            return try await extractFromWeb(url)
        case .text(let text):
            return text
        }
    }
    
    private func extractFromFile(_ url: URL) async throws -> String {
        // Simplified extraction logic
        let data = try Data(contentsOf: url)
        
        if url.pathExtension.lowercased() == "pdf" {
            // Extract from PDF
            if let pdf = PDFDocument(url: url) {
                var text = ""
                for i in 0..<pdf.pageCount {
                    if let page = pdf.page(at: i),
                       let pageContent = page.string {
                        text += pageContent + "\n\n"
                    }
                }
                return text
            }
        }
        
        // Try as plain text
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func extractFromWeb(_ url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let html = String(data: data, encoding: .utf8) {
            // Simple HTML stripping (in production, use a proper HTML parser)
            let stripped = html
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&[^;]+;", with: " ", options: .regularExpression)
            return stripped
        }
        return ""
    }
    
    private func analyzeContent(_ text: String) async -> [SuggestedHighlight] {
        // Use NaturalLanguage framework to find interesting sentences
        var suggestions: [SuggestedHighlight] = []
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let sentences = text.components(separatedBy: .newlines)
            .flatMap { $0.components(separatedBy: ". ") }
            .filter { !$0.isEmpty && $0.count > 20 }
        
        for sentence in sentences.prefix(10) {
            let confidence = Double.random(in: 0.3...1.0) // Simplified scoring
            
            suggestions.append(SuggestedHighlight(
                text: sentence.trimmingCharacters(in: .whitespacesAndNewlines),
                context: text,
                confidence: confidence,
                tags: []
            ))
        }
        
        return suggestions.sorted { $0.confidence > $1.confidence }
    }
    
    private func extractMetadata(from text: String) -> (title: String, author: String?) {
        // Simplified metadata extraction
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let title = lines.first ?? "Untitled"
        
        // Look for author patterns
        var author: String?
        for line in lines.prefix(10) {
            if line.lowercased().contains("by ") {
                author = line.components(separatedBy: "by ").last?.trimmingCharacters(in: .whitespaces)
                break
            }
        }
        
        return (title, author)
    }
}

// MARK: - Additional Components

struct MorphingTabBar: View {
    @Binding var selectedTab: SmartContentImporter.ImportTab
    let tabs: [SmartContentImporter.ImportTab]
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(4)
        .background(Color.ds.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: .ds.medium, style: .continuous))
    }
}

struct TabButton: View {
    let tab: SmartContentImporter.ImportTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: .ds.small) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(tab.rawValue)
                    .font(.ds.footnoteMedium)
            }
            .foregroundColor(isSelected ? .white : .ds.textSecondary)
            .padding(.horizontal, .ds.base)
            .padding(.vertical, .ds.small)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: .ds.small, style: .continuous)
                            .fill(Color.orange)
                            .matchedGeometryEffect(id: "tab", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

struct ProcessingOverlay: View {
    let progress: Double
    let currentStep: String
    @Binding var particleSystem: ParticleSystem
    @State private var pulseScale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .blur(radius: 10)
            
            VStack(spacing: .ds.large) {
                // Animated processing icon
                ZStack {
                    // Particle effects
                    ForEach(0..<12) { i in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 8, height: 8)
                            .offset(x: 50)
                            .rotationEffect(.degrees(Double(i) * 30))
                            .rotationEffect(.degrees(progress * 360))
                            .opacity(0.6)
                    }
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse)
                }
                
                VStack(spacing: .ds.small) {
                    Text(currentStep)
                        .font(.ds.headline)
                        .foregroundColor(.white)
                    
                    // Custom progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: .ds.small)
                                .fill(Color.white.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: .ds.small)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                        }
                    }
                    .frame(height: 8)
                    .frame(width: 200)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.ds.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .contentTransition(.numericText())
                }
            }
            .padding(.ds.large)
            .background(
                RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: .ds.large, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.5), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

// Additional supporting views would go here...
// (RippleButton, AnimatedMeshBackground, ConfettiView, SmartHighlightSuggestions, etc.)

#Preview {
    SmartContentImporter()
        .environmentObject(AppState())
}