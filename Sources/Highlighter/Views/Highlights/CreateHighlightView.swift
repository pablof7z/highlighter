import SwiftUI
import NDKSwift

struct CreateHighlightView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMode: HighlightMode = .paste
    @State private var pastedText = ""
    @State private var sourceTitle = ""
    @State private var sourceAuthor = ""
    @State private var sourceURL = ""
    @State private var showTextSelection = false
    @State private var importedContent = ""
    @State private var showImportOptions = false
    @State private var isImporting = false
    @State private var animateBackground = false
    @State private var showSmartImporter = false
    @State private var showAIAnalysis = false
    @State private var aiButtonGlow = false
    @Environment(\.dismiss) var dismiss
    
    enum HighlightMode: CaseIterable {
        case paste
        case importArticle
        case fromURL
        case fromFile
        
        var title: String {
            switch self {
            case .paste: return "Paste Text"
            case .importArticle: return "Import Article"
            case .fromURL: return "From URL"
            case .fromFile: return "From File"
            }
        }
        
        var icon: String {
            switch self {
            case .paste: return "doc.on.clipboard"
            case .importArticle: return "newspaper"
            case .fromURL: return "link"
            case .fromFile: return "doc.text"
            }
        }
        
        var description: String {
            switch self {
            case .paste: return "Paste any text you want to highlight"
            case .importArticle: return "Import from Nostr articles"
            case .fromURL: return "Extract content from any website"
            case .fromFile: return "Import PDF, EPUB, or text files"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                CreateHighlightGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mode selector with beautiful cards
                        VStack(spacing: 16) {
                            ForEach(HighlightMode.allCases, id: \.self) { mode in
                                HighlightModeCard(
                                    mode: mode,
                                    isSelected: selectedMode == mode,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedMode = mode
                                            HapticManager.shared.impact(.light)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.top)
                        
                        // Content input based on mode
                        Group {
                            switch selectedMode {
                            case .paste:
                                pasteTextView
                            case .importArticle:
                                importArticleView
                            case .fromURL:
                                fromURLView
                            case .fromFile:
                                fromFileView
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing).combined(with: .opacity),
                            removal: .push(from: .leading).combined(with: .opacity)
                        ))
                        
                        // Action button
                        if canProceed {
                            Button(action: proceedToHighlight) {
                                HStack {
                                    Image(systemName: "highlighter")
                                    Text("Create Highlights")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: DesignSystem.Colors.secondary.opacity(0.3), radius: DesignSystem.Shadow.small.radius, x: DesignSystem.Shadow.small.x, y: DesignSystem.Shadow.small.y)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Create Highlight")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showTextSelection) {
                TextSelectionView(
                    content: importedContent,
                    source: sourceTitle.isEmpty ? nil : sourceTitle,
                    author: sourceAuthor.isEmpty ? nil : sourceAuthor
                )
            }
            .fullScreenCover(isPresented: $showAIAnalysis) {
                AIAnalysisVisualizationView(
                    text: pastedText,
                    source: sourceTitle.isEmpty ? nil : sourceTitle,
                    author: sourceAuthor.isEmpty ? nil : sourceAuthor
                )
            }
            // .fullScreenCover(isPresented: $showSmartImporter) {
            //     SmartArticleImportView()
            // }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
    }
    
    // MARK: - Input Views
    
    private var pasteTextView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paste Your Text")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $pastedText)
                .frame(minHeight: 200)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if pastedText.isEmpty {
                        Text("Paste any text you'd like to highlight...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
            
            // Optional metadata
            VStack(spacing: 12) {
                ModernTextField(
                    icon: "book",
                    placeholder: "Source Title (optional)",
                    text: $sourceTitle
                )
                
                ModernTextField(
                    icon: "person",
                    placeholder: "Author (optional)",
                    text: $sourceAuthor
                )
            }
            
            // AI Analysis Card
            if !pastedText.isEmpty {
                AIAnalysisCard(
                    hasText: !pastedText.isEmpty,
                    glowing: aiButtonGlow,
                    action: {
                        HapticManager.shared.impact(.medium)
                        showAIAnalysis = true
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        aiButtonGlow = true
                    }
                }
            }
        }
    }
    
    private var importArticleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Articles")
                .font(.headline)
                .foregroundColor(.primary)
            
            if isImporting {
                ProgressView("Loading articles...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                VStack(spacing: 12) {
                    // Placeholder for article list
                    ForEach(0..<3) { _ in
                        ArticlePlaceholderCard()
                    }
                }
            }
            
            Button(action: { showSmartImporter = true }) {
                Label("Smart Import", systemImage: "sparkles")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var fromURLView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import from URL")
                .font(.headline)
                .foregroundColor(.primary)
            
            ModernTextField(
                icon: "link",
                placeholder: "https://example.com/article",
                text: $sourceURL
            )
            
            Text("We'll extract the content and let you select text to highlight")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            if !sourceURL.isEmpty && URL(string: sourceURL) != nil {
                Button(action: importFromURL) {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.down.circle")
                        }
                        Text(isImporting ? "Importing..." : "Import Content")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private var fromFileView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import from File")
                .font(.headline)
                .foregroundColor(.primary)
            
            // File import button
            Button(action: { showSmartImporter = true }) {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Smart Import")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("AI-powered content extraction")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                                .foregroundColor(.orange.opacity(0.5))
                        )
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canProceed: Bool {
        switch selectedMode {
        case .paste:
            return !pastedText.isEmpty
        case .importArticle:
            return !importedContent.isEmpty
        case .fromURL:
            return !sourceURL.isEmpty && URL(string: sourceURL) != nil
        case .fromFile:
            return !importedContent.isEmpty
        }
    }
    
    // MARK: - Actions
    
    private func proceedToHighlight() {
        switch selectedMode {
        case .paste:
            importedContent = pastedText
            showTextSelection = true
        case .importArticle, .fromFile:
            showTextSelection = true
        case .fromURL:
            importFromURL()
        }
    }
    
    private func importFromURL() {
        guard let url = URL(string: sourceURL) else { return }
        
        isImporting = true
        HapticManager.shared.impact(.light)
        
        // Simulate content extraction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            importedContent = "Content extracted from \(url.host ?? "website")..."
            sourceTitle = "Article from \(url.host ?? "website")"
            isImporting = false
            showTextSelection = true
        }
    }
}

// MARK: - Supporting Views

struct HighlightModeCard: View {
    let mode: CreateHighlightView.HighlightMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange : Color.gray.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(mode.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .orange : .secondary)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.orange : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? DesignSystem.Colors.secondary.opacity(0.2) : DesignSystem.Shadow.small.color,
                radius: isSelected ? DesignSystem.Shadow.medium.radius : DesignSystem.Shadow.small.radius,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }
}

struct ArticlePlaceholderCard: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 12)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct CreateHighlightGradientBackground: View {
    @Binding var animate: Bool
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color.orange.opacity(0.05),
                Color(uiColor: .systemBackground)
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
    }
}

struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - AI Analysis Card

struct AIAnalysisCard: View {
    let hasText: Bool
    let glowing: Bool
    let action: () -> Void
    @State private var neuralPulse = false
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Quantum gradient background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.0, blue: 1.0),
                                Color(red: 0.0, green: 0.5, blue: 1.0),
                                Color(red: 0.5, green: 0.0, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(glowing ? 0.8 : 0.6)
                
                // Neural network overlay
                NeuralNetworkOverlay()
                    .opacity(glowing ? 0.5 : 0.3)
                
                // Holographic shimmer
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: particleOffset)
                    .mask(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                
                HStack(spacing: 16) {
                    // Animated AI icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "brain.filled.head.profile")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(neuralPulse ? 1.2 : 1.0)
                            .rotationEffect(.degrees(neuralPulse ? 5 : -5))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AI Analysis")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Discover intelligent highlights with quantum AI")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(glowing ? 180 : 0))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: 88)
            .shadow(color: DesignSystem.Colors.primary.opacity(glowing ? 0.6 : 0.3), radius: glowing ? DesignSystem.Shadow.elevated.radius : DesignSystem.Shadow.medium.radius, x: 0, y: DesignSystem.Shadow.medium.y)
            .scaleEffect(glowing ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                neuralPulse = true
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                particleOffset = 300
            }
        }
    }
}

struct NeuralNetworkOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let nodeCount = 8
                let layerCount = 3
                
                for layer in 0..<layerCount {
                    let x = size.width * CGFloat(layer + 1) / CGFloat(layerCount + 1)
                    
                    for node in 0..<nodeCount {
                        let y = size.height * CGFloat(node + 1) / CGFloat(nodeCount + 1)
                        
                        // Draw connections to next layer
                        if layer < layerCount - 1 {
                            let nextX = size.width * CGFloat(layer + 2) / CGFloat(layerCount + 1)
                            for nextNode in 0..<nodeCount {
                                let nextY = size.height * CGFloat(nextNode + 1) / CGFloat(nodeCount + 1)
                                
                                let path = Path { path in
                                    path.move(to: CGPoint(x: x, y: y))
                                    path.addLine(to: CGPoint(x: nextX, y: nextY))
                                }
                                
                                context.stroke(
                                    path,
                                    with: .color(.white.opacity(0.1)),
                                    lineWidth: 0.5
                                )
                            }
                        }
                        
                        // Draw node
                        context.fill(
                            Circle().path(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)),
                            with: .color(.white.opacity(0.3))
                        )
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    CreateHighlightView()
        .environmentObject(AppState())
}