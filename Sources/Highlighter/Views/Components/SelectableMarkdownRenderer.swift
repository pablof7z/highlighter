import SwiftUI
import NDKSwift
import NDKSwiftUI

/// A wrapper around NDKMarkdownRenderer that adds text selection capabilities
struct SelectableMarkdownRenderer: View {
    let content: String
    let ndk: NDK
    let onTextSelected: (String, NSRange) -> Void
    
    @State private var selectedRange: NSRange?
    @State private var textGeometry: [TextGeometry] = []
    @State private var showSelectionHandles = false
    @State private var selectionStart: CGPoint = .zero
    @State private var selectionEnd: CGPoint = .zero
    
    // Pass through configuration and handlers
    var configuration = MarkdownConfiguration()
    var onMentionTap: ((String) -> Void)?
    var onHashtagTap: ((String) -> Void)?
    var onLinkTap: ((URL) -> Void)?
    var onNostrEntityTap: ((ContentEntity) -> Void)?
    
    var body: some View {
        // Fallback to simple text for now until NDKMarkdownRenderer is available
        Text(content)
            .textSelection(.enabled)
            .font(.body)
            .foregroundColor(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// UIViewRepresentable that provides text selection
private struct SelectableTextOverlay: UIViewRepresentable {
    let content: String
    let onTextSelected: (String, NSRange) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        // Set the text with transparent color
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.clear
        ]
        
        textView.attributedText = NSAttributedString(string: content, attributes: attributes)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update if content changes
        if uiView.text != content {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.clear
            ]
            uiView.attributedText = NSAttributedString(string: content, attributes: attributes)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextSelected: onTextSelected)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let onTextSelected: (String, NSRange) -> Void
        
        init(onTextSelected: @escaping (String, NSRange) -> Void) {
            self.onTextSelected = onTextSelected
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange,
                  !selectedRange.isEmpty,
                  let selectedText = textView.text(in: selectedRange),
                  !selectedText.isEmpty else { return }
            
            let location = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
            let range = NSRange(location: location, length: length)
            
            // Clear selection after capturing it
            DispatchQueue.main.async {
                textView.selectedTextRange = nil
            }
            
            onTextSelected(selectedText, range)
        }
    }
}

// MARK: - View Extensions

extension SelectableMarkdownRenderer {
    func markdownStyle(_ style: MarkdownConfiguration) -> Self {
        var view = self
        view.configuration = style
        return view
    }
    
    func onMentionTap(_ action: @escaping (String) -> Void) -> Self {
        var view = self
        view.onMentionTap = action
        return view
    }
    
    func onHashtagTap(_ action: @escaping (String) -> Void) -> Self {
        var view = self
        view.onHashtagTap = action
        return view
    }
    
    func onLinkTap(_ action: @escaping (URL) -> Void) -> Self {
        var view = self
        view.onLinkTap = action
        return view
    }
    
    func onNostrEntityTap(_ action: @escaping (ContentEntity) -> Void) -> Self {
        var view = self
        view.onNostrEntityTap = action
        return view
    }
}

// MARK: - Helper Types

private struct TextGeometry {
    let text: String
    let frame: CGRect
    let range: NSRange
}
