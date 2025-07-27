import SwiftUI
import NDKSwift

struct CreateHighlightView: View {
    @State private var selectedMode = HighlightMode.paste
    @State private var pastedText = ""
    @State private var sourceTitle = ""
    @State private var sourceAuthor = ""
    @State private var sourceURL = ""
    @State private var urlInputVisible = false
    @State private var isSaving = false
    @State private var importedContent = ""
    @State private var showImportOptions = false
    @State private var isImporting = false
    @State private var animateBackground = false
    @State private var commentText = ""
    @State private var contextText = ""
    @Environment(\.dismiss) var dismiss
    
    enum HighlightMode: CaseIterable {
        case paste
        case article
        
        var title: String {
            switch self {
            case .paste: return "Paste Text"
            case .article: return "Import Article"
            }
        }
        
        var icon: String {
            switch self {
            case .paste: return "doc.on.clipboard"
            case .article: return "doc.text"
            }
        }
        
        var description: String {
            switch self {
            case .paste: return "Paste any text to highlight"
            case .article: return "Import from your saved articles"
            }
        }
    }
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                UnifiedGradientBackground(style: .mesh)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mode Selection
                        VStack(spacing: 16) {
                            Text("Create Highlight")
                                .font(.largeTitle.weight(.bold)
                                .foregroundColor(.ds.text)
                            
                            HStack(spacing: 12) {
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
                        }
                        .padding(.top, DesignSystem.Spacing.huge)
                        
                        // Content Input
                        Group {
                            switch selectedMode {
                            case .paste:
                                pasteTextView
                            case .article:
                                importArticleView
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .push(from: .trailing).combined(with: .opacity),
                            removal: .push(from: .leading).combined(with: .opacity)
                        )
                        
                        // Save Button
                        Button(action: saveHighlight) {
                            Label(isSaving ? "Saving..." : "Save Highlight", 
                                  systemImage: isSaving ? "arrow.circlepath" : "checkmark.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.medium)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(isReadyToSave ? Color.ds.primary : Color.secondary.opacity(0.3)
                                )
                                .foregroundColor(.white)
                                .scaleEffect(isSaving ? 0.95 : 1.0)
                        }
                        .disabled(!isReadyToSave || isSaving)
                        .buttonStyle(.plain)
                        .padding(.bottom, DesignSystem.Spacing.huge)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ds.primary)
                }
            }
            .sheet(isPresented: $showImportOptions) {
                SmartArticleImportView()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
    }
    
    private var isReadyToSave: Bool {
        switch selectedMode {
        case .paste:
            return !pastedText.isEmpty
        case .article:
            return !importedContent.isEmpty
        }
    }
    
    // MARK: - Paste Text View
    
    private var pasteTextView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Text Input
            VStack(alignment: .leading, spacing: 8) {
                Label("Highlight Text", systemImage: "highlighter")
                    .font(.headline)
                    .foregroundColor(.ds.text)
                
                TextEditor(text: $pastedText)
                    .frame(minHeight: 150)
                    .padding(DesignSystem.Spacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ds.surfaceSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.ds.border, lineWidth: 1)
                            )
                    )
                    .font(.body)
            }
            
            // Source Information
            VStack(spacing: 12) {
                IconTextField(
                    icon: "book",
                    placeholder: "Source Title (optional)",
                    text: $sourceTitle
                )
                
                IconTextField(
                    icon: "person",
                    placeholder: "Author (optional)",
                    text: $sourceAuthor
                )
                
                IconTextField(
                    icon: "link",
                    placeholder: "Source URL (optional)",
                    text: $sourceURL
                )
            }
            
            // Additional fields
            VStack(alignment: .leading, spacing: 8) {
                Label("Context (optional)", systemImage: "text.alignleft")
                    .font(.headline)
                    .foregroundColor(.ds.text)
                
                TextEditor(text: $contextText)
                    .frame(minHeight: 80)
                    .padding(DesignSystem.Spacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ds.surfaceSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.ds.border, lineWidth: 1)
                            )
                    )
                    .font(.body)
            }
            
            // Comment field
            VStack(alignment: .leading, spacing: 8) {
                Label("Your Comment (optional)", systemImage: "text.bubble")
                    .font(.headline)
                    .foregroundColor(.ds.text)
                
                TextEditor(text: $commentText)
                    .frame(minHeight: 80)
                    .padding(DesignSystem.Spacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ds.surfaceSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.ds.border, lineWidth: 1)
                            )
                    )
                    .font(.body)
            }
            
        }
    }
    
    private var importArticleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Articles")
                .font(.headline)
                .foregroundColor(.ds.text)
            
            if appState.articles.isEmpty {
                ArticlePlaceholderCard()
                    .onTapGesture {
                        showImportOptions = true
                    }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(appState.articles.prefix(5)), id: \.id) { article in
                            ArticleSelectionCard(article: article) {
                                selectArticle(article)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.nano)
                }
            }
            
            Button(action: { showImportOptions = true }) {
                Label("Import New Article", systemImage: "plus.circle.fill")
                    .font(.ds.body).fontWeight(.medium)
                    .foregroundColor(.ds.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.ds.primary.opacity(0.1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.ds.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Actions
    
    private func selectArticle(_ article: Article) {
        importedContent = article.content
        sourceTitle = article.title
        sourceAuthor = "nostr:" + article.author
        sourceURL = article.references.first ?? ""
        selectedMode = .article
        HapticManager.shared.impact(.medium)
    }
    
    private func saveHighlight() {
        Task {
            await MainActor.run {
                isSaving = true
                HapticManager.shared.impact(.medium)
            }
            
            let content = selectedMode == .paste ? pastedText : importedContent
            
            // Create highlight event
            let highlight = HighlightEvent(
                content: content,
                context: contextText.isEmpty ? nil : contextText,
                source: sourceURL.isEmpty ? nil : sourceURL,
                author: sourceAuthor.isEmpty ? nil : sourceAuthor.replacingOccurrences(of: "nostr:", with: ""),
                comment: commentText.isEmpty ? nil : commentText
            )
            
            // Publish the highlight
            do {
                try await appState.publishingService.publishHighlight(highlight)
                await MainActor.run {
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                    // Keep the view open to let user retry
                }
            }
            
            await MainActor.run {
                isSaving = false
            }
        }
    }
    
    private func handleURLImport(_ url: String) {
        guard !url.isEmpty else { return }
        
        Task {
            await MainActor.run {
                isImporting = true
            }
            
            // Since we don't have actual URL import functionality yet,
            // we'll just save the URL and let the user paste content
            await MainActor.run {
                sourceURL = url
                isImporting = false
                urlInputVisible = false
                HapticManager.shared.notification(.success)
            }
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
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.ds.primary : Color.ds.surfaceSecondary)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .strokeBorder(isSelected ? Color.clear : Color.ds.border, lineWidth: 1)
                        )
                    
                    Image(systemName: mode.icon)
                        .font(.ds.title2).fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .ds.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(mode.title)
                        .font(.ds.body).fontWeight(.semibold)
                        .foregroundColor(isSelected ? .ds.text : .ds.textSecondary)
                    
                    Text(mode.description)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.large)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.ds.primary.opacity(0.08) : Color.ds.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(isSelected ? Color.ds.primary.opacity(0.3) : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct ArticleSelectionCard: View {
    let article: Article
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.ds.callout).fontWeight(.semibold)
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let summary = article.summary {
                    Text(summary)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                HStack {
                    Label("\(article.estimatedReadingTime) min", systemImage: "clock")
                        .font(.ds.caption2)
                        .foregroundColor(.ds.textTertiary)
                    
                    Spacer()
                    
                    Text(article.createdAt.formatted(.relative(presentation: .named))
                        .font(.ds.caption2)
                        .foregroundColor(.ds.textTertiary)
                }
            }
            .padding(12)
            .frame(width: 220, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.ds.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.ds.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ArticlePlaceholderCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(DesignSystem.Typography.largeTitle.weight(.regular))
                .foregroundColor(.orange.opacity(0.6)
            
            VStack(spacing: 8) {
                Text("No articles yet")
                    .font(.headline)
                    .foregroundColor(.ds.text)
                
                Text("Import your first article to start highlighting")
                    .font(.subheadline)
                    .foregroundColor(.ds.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Text("Tap to import")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.huge)
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.orange.opacity(0.05)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}


struct IconTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.body)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.medium - 2)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ds.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.ds.border, lineWidth: 1)
        )
    }
}

#Preview {
    CreateHighlightView()
        .environmentObject(AppState())
}