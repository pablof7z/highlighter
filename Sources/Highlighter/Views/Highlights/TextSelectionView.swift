import SwiftUI
import UIKit
import NDKSwift

struct TextSelectionView: View {
    let content: String
    let source: String?
    let author: String?
    @State private var selectedRange: NSRange?
    @State private var highlightCreationMode = false
    @State private var selectedText = ""
    @State private var contextBefore = ""
    @State private var contextAfter = ""
    @State private var showHighlightEditor = false
    @State private var selectionRect: CGRect = .zero
    @State private var highlightAnimation = false
    @State private var ripplePositions: [RipplePosition] = []
    @State private var selectionPulse = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var selectionGlow: Double = 0
    @State private var showSelectionHint = false
    @State private var hintOpacity: Double = 1.0
    @Environment(\.dismiss) var dismiss
    @StateObject private var publishingService = PublishingService.shared
    
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header
                header
                
                // Selectable text content
                SelectableTextView(
                    text: content,
                    selectedRange: $selectedRange,
                    selectionRect: $selectionRect,
                    onSelectionChange: handleSelectionChange
                )
                .overlay(alignment: .topLeading) {
                    // Selection highlight overlay
                    if highlightCreationMode && !selectionRect.isEmpty {
                        selectionOverlay
                    }
                }
                .overlay {
                    // Ripple effects
                    ForEach(ripplePositions) { ripple in
                        RippleEffectView(position: ripple.position)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .sheet(isPresented: $showHighlightEditor) {
            HighlightEditorView(
                selectedText: selectedText,
                contextBefore: contextBefore,
                contextAfter: contextAfter,
                source: source,
                author: author,
                onPublish: publishHighlight
            )
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Select Text to Highlight")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Placeholder for balance
                Text("Cancel")
                    .foregroundColor(.clear)
            }
            .padding()
            
            if let source = source {
                Text(source)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Divider()
        }
        .background(.ultraThinMaterial)
    }
    
    private var selectionOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced glowing selection rectangle with pulse
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.25),
                                Color.orange.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: selectionRect.width, height: selectionRect.height)
                    .position(x: selectionRect.midX, y: selectionRect.midY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: selectionPulse ? 3 : 2
                            )
                            .frame(width: selectionRect.width, height: selectionRect.height)
                            .position(x: selectionRect.midX, y: selectionRect.midY)
                    )
                    .scaleEffect(highlightAnimation ? 1.02 : 1.0)
                    .shadow(color: Color.orange.opacity(selectionGlow), radius: highlightAnimation ? 20 : 10)
                    .blur(radius: selectionPulse ? 0.5 : 0)
                
                // Selection handles at corners
                Group {
                    SelectionHandle()
                        .position(x: selectionRect.minX, y: selectionRect.minY)
                        .opacity(highlightAnimation ? 1 : 0)
                        .scaleEffect(selectionPulse ? 1.2 : 1.0)
                    
                    SelectionHandle()
                        .position(x: selectionRect.maxX, y: selectionRect.maxY)
                        .opacity(highlightAnimation ? 1 : 0)
                        .scaleEffect(selectionPulse ? 1.2 : 1.0)
                }
                
                // Action buttons
                if !selectedText.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        
                        HStack(spacing: 16) {
                            // Create highlight button with enhanced animation
                            Button(action: {
                                impactFeedback.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 0.9
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        buttonScale = 1.0
                                    }
                                    createHighlight()
                                }
                            }) {
                                Label("Create Highlight", systemImage: "highlighter")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.orange, Color.orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: Color.orange.opacity(0.4), radius: 8, y: 4)
                            }
                            .scaleEffect(buttonScale * (highlightAnimation ? 1.05 : 1.0))
                            
                            // Copy button
                            Button(action: {
                                UIPasteboard.general.string = selectedText
                                HapticManager.shared.notification(.success)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.secondary.opacity(0.8)))
                            }
                        }
                        .position(x: selectionRect.midX, y: selectionRect.maxY + 50)
                    }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: highlightAnimation)
        }
    }
    
    private func handleSelectionChange(range: NSRange?, text: String) {
        selectedRange = range
        selectedText = text
        
        if let range = range, !text.isEmpty {
            // Haptic feedback on selection
            selectionFeedback.selectionChanged()
            
            highlightCreationMode = true
            extractContext(for: range)
            
            // Start multiple coordinated animations
            withAnimation(.easeInOut(duration: 0.3)) {
                highlightAnimation = true
                selectionGlow = 0.4
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                selectionPulse = true
            }
            
            // Glow animation
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                selectionGlow = 0.6
            }
            
            // Add ripple effect at selection
            if !selectionRect.isEmpty {
                let ripple = RipplePosition(
                    id: UUID(),
                    position: CGPoint(x: selectionRect.midX, y: selectionRect.midY)
                )
                ripplePositions.append(ripple)
                
                // Remove ripple after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    ripplePositions.removeAll { $0.id == ripple.id }
                }
            }
            
            HapticManager.shared.impact(.light)
        } else {
            highlightCreationMode = false
            highlightAnimation = false
        }
    }
    
    private func extractContext(for range: NSRange) {
        let nsString = content as NSString
        let contextLength = 100 // Characters of context to capture
        
        // Extract context before
        let beforeStart = max(0, range.location - contextLength)
        let beforeLength = range.location - beforeStart
        if beforeLength > 0 {
            contextBefore = nsString.substring(with: NSRange(location: beforeStart, length: beforeLength))
            // Find the last sentence boundary
            if let lastPeriod = contextBefore.lastIndex(of: ".") {
                contextBefore = String(contextBefore[contextBefore.index(after: lastPeriod)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Extract context after
        let afterStart = range.location + range.length
        let afterLength = min(contextLength, nsString.length - afterStart)
        if afterLength > 0 {
            contextAfter = nsString.substring(with: NSRange(location: afterStart, length: afterLength))
            // Find the first sentence boundary
            if let firstPeriod = contextAfter.firstIndex(of: ".") {
                contextAfter = String(contextAfter[...firstPeriod])
            }
        }
    }
    
    private func createHighlight() {
        HapticManager.shared.impact(.medium)
        showHighlightEditor = true
    }
    
    private func publishHighlight(comment: String?) {
        Task {
            do {
                // Create highlight event
                let highlight = HighlightEvent(
                    content: selectedText,
                    context: contextBefore + " [...] " + contextAfter,
                    source: source,
                    author: author,
                    comment: comment
                )
                
                // Publish to Nostr
                try await publishingService.publishHighlight(highlight)
                
                HapticManager.shared.notification(.success)
                dismiss()
            } catch {
                HapticManager.shared.notification(.error)
                print("Failed to publish highlight: \(error)")
            }
        }
    }
}

// Custom UITextView wrapper for text selection
struct SelectableTextView: UIViewRepresentable {
    let text: String
    @Binding var selectedRange: NSRange?
    @Binding var selectionRect: CGRect
    let onSelectionChange: (NSRange?, String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.delegate = context.coordinator
        
        // Configure text style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.paragraphSpacing = 16
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        textView.attributedText = NSAttributedString(string: text, attributes: attributes)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update selection if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextView
        
        init(_ parent: SelectableTextView) {
            self.parent = parent
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange,
                  !selectedRange.isEmpty else {
                parent.selectedRange = nil
                parent.selectionRect = .zero
                parent.onSelectionChange(nil, "")
                return
            }
            
            let range = textView.selectedRange
            let selectedText = (textView.text as NSString).substring(with: range)
            
            // Calculate selection rect
            if let start = textView.position(from: textView.beginningOfDocument, offset: range.location),
               let end = textView.position(from: start, offset: range.length),
               let textRange = textView.textRange(from: start, to: end) {
                
                let selectionRects = textView.selectionRects(for: textRange)
                var unionRect = CGRect.zero
                
                for selectionRect in selectionRects {
                    if unionRect.isEmpty {
                        unionRect = selectionRect.rect
                    } else {
                        unionRect = unionRect.union(selectionRect.rect)
                    }
                }
                
                // Convert to view coordinates
                let convertedRect = textView.convert(unionRect, to: textView.superview)
                parent.selectionRect = convertedRect
            }
            
            parent.selectedRange = range
            parent.onSelectionChange(range, selectedText)
        }
    }
}

// Ripple effect for selection
struct RipplePosition: Identifiable {
    let id: UUID
    let position: CGPoint
}

struct RippleEffectView: View {
    let position: CGPoint
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [Color.orange, Color.orange.opacity(0.3)],
                    startPoint: .center,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            .frame(width: 60, height: 60)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    scale = 3
                    opacity = 0
                }
            }
    }
}

// Highlight editor sheet
struct HighlightEditorView: View {
    let selectedText: String
    let contextBefore: String
    let contextAfter: String
    let source: String?
    let author: String?
    let onPublish: (String?) -> Void
    
    @State private var comment = ""
    @State private var isPrivate = false
    @State private var showPreview = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview section
                    if showPreview {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Preview", systemImage: "eye")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HighlightPreviewCard(
                                text: selectedText,
                                contextBefore: contextBefore,
                                contextAfter: contextAfter,
                                source: source,
                                author: author
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Comment section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Add Your Thoughts (Optional)", systemImage: "bubble.left")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("What makes this passage special?", text: $comment, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                    
                    // Privacy toggle
                    Toggle(isOn: $isPrivate) {
                        Label("Keep Private", systemImage: isPrivate ? "lock.fill" : "lock.open")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal)
                    .tint(.orange)
                    
                    Spacer(minLength: 40)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onPublish(comment.isEmpty ? nil : comment)
                        }) {
                            HStack {
                                Image(systemName: "highlighter")
                                Text("Create Highlight")
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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, y: 4)
                        }
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("New Highlight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showPreview.toggle()
                        }
                    }) {
                        Image(systemName: showPreview ? "eye.slash" : "eye")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// Preview card component
struct HighlightPreviewCard: View {
    let text: String
    let contextBefore: String
    let contextAfter: String
    let source: String?
    let author: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Context and highlighted text
            HStack(alignment: .top, spacing: 0) {
                Text(contextBefore + " ")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
                
                Text(text)
                    .foregroundColor(.primary)
                    .font(.system(size: 15, weight: .semibold))
                    .underline(color: .orange)
                    .background(Color.orange.opacity(0.1))
                
                Text(" " + contextAfter)
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            }
            
            Divider()
            
            // Source info
            HStack {
                if let author = author {
                    Label(author, systemImage: "person")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let source = source {
                    if author != nil {
                        Text("•")
                            .foregroundColor(.secondary)
                    }
                    Label(source, systemImage: "book")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    TextSelectionView(
        content: """
        The art of programming is the art of organizing complexity, of mastering multitude and avoiding its bastard chaos as effectively as possible.
        
        Programming is one of the most difficult branches of applied mathematics; the poorer mathematicians had better remain pure mathematicians.
        
        The competent programmer is fully aware of the strictly limited size of his own skull; therefore he approaches the programming task in full humility, and among other things he avoids clever tricks like the plague.
        """,
        source: "A Discipline of Programming",
        author: "Edsger W. Dijkstra"
    )
}

// MARK: - Supporting Components

// Selection handle component for enhanced visual feedback
struct SelectionHandle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.6), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 24, height: 24)
                .allowsHitTesting(false)
        }
    }
}