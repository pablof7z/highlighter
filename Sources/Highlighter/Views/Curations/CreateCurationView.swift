import SwiftUI
import NDKSwift
import PhotosUI

struct CreateCurationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // Form state
    @State private var curationName = ""
    @State private var curationTitle = ""
    @State private var description = ""
    @State private var imageUrl = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    // UI state
    @State private var currentStep = 0
    @State private var showImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var keyboardHeight: CGFloat = 0
    @State private var animateHeader = false
    @State private var animateForm = false
    @State private var pulseAnimation = false
    @State private var particleAnimation = false
    @State private var selectedColor = Color.highlighterPurple
    @State private var showColorPicker = false
    @State private var nameFieldFocused = false
    @State private var titleFieldFocused = false
    @State private var descriptionFieldFocused = false
    @Namespace private var animation
    
    let gradientColors: [[Color]] = [
        [Color.highlighterPurple, Color.highlighterOrange],
        [Color.blue, Color.purple],
        [Color.pink, Color.orange],
        [Color.green, Color.blue],
        [Color.indigo, Color.pink]
    ]
    
    var isFormValid: Bool {
        !curationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !curationTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @ViewBuilder
    private var headerImageSection: some View {
        ZStack {
            // Dynamic gradient background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: gradientColors[Int(selectedColor.description.hashValue) % gradientColors.count],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)
            
            // Image preview or placeholder
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.xl)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            // Interactive overlay
            VStack {
                HStack {
                    Spacer()
                    
                    // Color picker button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showColorPicker.toggle()
                        }
                        HapticManager.shared.impact(.light)
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .padding(DesignSystem.Spacing.base)
                }
                
                Spacer()
                
                // Upload button
                Button(action: { showImagePicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: selectedImageData == nil ? "photo.badge.plus" : "photo.badge.checkmark")
                            .font(.system(size: 20))
                            .symbolEffect(.bounce, value: selectedImageData != nil)
                        
                        Text(selectedImageData == nil ? "Add Cover Image" : "Change Image")
                            .font(.highlighterBody.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.vertical, DesignSystem.Spacing.small + DesignSystem.Spacing.nano)
                    .background(.ultraThinMaterial)
                    .cornerRadius(DesignSystem.CornerRadius.xl)
                }
                .scaleEffect(animateForm ? 1 : 0.8)
                .opacity(animateForm ? 1 : 0)
            }
            .padding()
        }
        .frame(height: 220)
        .shadow(color: selectedColor.opacity(0.3), radius: DesignSystem.Shadow.elevated.radius, x: DesignSystem.Shadow.elevated.x, y: DesignSystem.Shadow.elevated.y)
        .scaleEffect(animateHeader ? 1 : 0.95)
        .opacity(animateHeader ? 1 : 0)
        .padding(.horizontal)
        .padding(.top, DesignSystem.Spacing.medium)
    }
    
    @ViewBuilder
    private var colorPickerSection: some View {
        if showColorPicker {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<gradientColors.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedColor = gradientColors[index].first ?? .highlighterPurple
                            }
                            HapticManager.shared.impact(.light)
                        }) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: gradientColors[index],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .opacity(selectedColor == gradientColors[index].first ? 1 : 0)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
    
    @ViewBuilder
    private var formFieldsSection: some View {
        VStack(spacing: 24) {
            // Name field
            nameField
            
            // Title field
            titleField
            
            // Description field
            descriptionField
            
            // Image URL field
            if selectedImageData == nil {
                imageUrlField
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Curation ID", systemImage: "number.square.fill")
                    .font(.highlighterCaption.weight(.medium))
                    .foregroundColor(nameFieldFocused ? .highlighterPurple : .highlighterSecondaryText)
                
                Spacer()
                
                if !curationName.isEmpty {
                    Text("\(curationName.count)/50")
                        .font(.ds.footnote)
                        .foregroundColor(curationName.count > 50 ? .red : .highlighterSecondaryText)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: nameFieldFocused)
            
            HStack {
                TextField("my-reading-list", text: $curationName)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onTapGesture { nameFieldFocused = true }
                    .onChange(of: curationName) { _, newValue in
                        if newValue.count > 50 {
                            curationName = String(newValue.prefix(50))
                        }
                    }
                
                if !curationName.isEmpty {
                    Button(action: { curationName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.highlighterSecondaryText)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.highlighterCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                nameFieldFocused ? Color.highlighterPurple : Color.gray.opacity(0.2),
                                lineWidth: nameFieldFocused ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(animateForm && currentStep >= 0 ? 1 : 0.95)
        .opacity(animateForm && currentStep >= 0 ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: animateForm)
    }
    
    @ViewBuilder
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Title", systemImage: "textformat.alt")
                    .font(.highlighterCaption.weight(.medium))
                    .foregroundColor(titleFieldFocused ? .highlighterPurple : .highlighterSecondaryText)
                
                Spacer()
                
                if !curationTitle.isEmpty {
                    Text("\(curationTitle.count)/100")
                        .font(.ds.footnote)
                        .foregroundColor(curationTitle.count > 100 ? .red : .highlighterSecondaryText)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: titleFieldFocused)
            
            HStack {
                TextField("My Reading List", text: $curationTitle)
                    .textFieldStyle(.plain)
                    .onTapGesture { titleFieldFocused = true }
                    .onChange(of: curationTitle) { _, newValue in
                        if newValue.count > 100 {
                            curationTitle = String(newValue.prefix(100))
                        }
                    }
                
                if !curationTitle.isEmpty {
                    Button(action: { curationTitle = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.highlighterSecondaryText)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.highlighterCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                titleFieldFocused ? Color.highlighterPurple : Color.gray.opacity(0.2),
                                lineWidth: titleFieldFocused ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(animateForm && currentStep >= 0 ? 1 : 0.95)
        .opacity(animateForm && currentStep >= 0 ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.2), value: animateForm)
    }
    
    @ViewBuilder
    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Description", systemImage: "text.quote")
                    .font(.highlighterCaption.weight(.medium))
                    .foregroundColor(descriptionFieldFocused ? .highlighterPurple : .highlighterSecondaryText)
                
                Spacer()
                
                Text("Optional")
                    .font(.ds.footnote)
                    .foregroundColor(.highlighterSecondaryText)
            }
            .animation(.easeInOut(duration: 0.2), value: descriptionFieldFocused)
            
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("Describe your curation...")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, DesignSystem.Spacing.micro)
                        .padding(.vertical, DesignSystem.Spacing.small)
                }
                
                TextEditor(text: $description)
                    .font(.highlighterBody)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onTapGesture { descriptionFieldFocused = true }
            }
            .padding(DesignSystem.Spacing.base)
            .frame(minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.highlighterCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                descriptionFieldFocused ? Color.highlighterPurple : Color.gray.opacity(0.2),
                                lineWidth: descriptionFieldFocused ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(animateForm && currentStep >= 0 ? 1 : 0.95)
        .opacity(animateForm && currentStep >= 0 ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.3), value: animateForm)
    }
    
    @ViewBuilder
    private var imageUrlField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Or use image URL", systemImage: "link.circle.fill")
                .font(.highlighterCaption.weight(.medium))
                .foregroundColor(.highlighterSecondaryText)
            
            TextField("https://...", text: $imageUrl)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.highlighterCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(animateForm && currentStep >= 0 ? 1 : 0.95)
        .opacity(animateForm && currentStep >= 0 ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.4), value: animateForm)
    }
    
    @ViewBuilder
    private var infoBoxSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.highlighterPurple, .highlighterPurple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("What are Article Curations?")
                        .font(.highlighterBody.weight(.semibold))
                        .foregroundColor(.highlighterText)
                    
                    Text("Create themed collections of articles, highlights, and content. Perfect for organizing your reading lists, research topics, or sharing knowledge with others.")
                        .font(.highlighterCaption)
                        .foregroundColor(.highlighterSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            // Feature highlights
            HStack(spacing: 16) {
                FeatureBadge(icon: "folder.fill", text: "Organize", color: .highlighterPurple)
                FeatureBadge(icon: "square.and.arrow.up", text: "Share", color: .highlighterOrange)
                FeatureBadge(icon: "sparkles", text: "Discover", color: .blue)
            }
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.highlighterPurple.opacity(0.3), .highlighterOrange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
        .scaleEffect(animateForm ? 1 : 0.95)
        .opacity(animateForm ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.5), value: animateForm)
    }
    
    @ViewBuilder
    private var createButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: createCuration) {
                ZStack {
                    // Background gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isFormValid ? 
                                    [.highlighterPurple, .highlighterPurple.opacity(0.8)] :
                                    [.gray.opacity(0.3), .gray.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Shimmer effect when valid
                    if isFormValid {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white, .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .offset(x: isFormValid ? 200 : -200)
                                    .animation(
                                        .linear(duration: 1.5)
                                        .repeatForever(autoreverses: false),
                                        value: isFormValid
                                    )
                            )
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 18, weight: .semibold))
                            .symbolEffect(.bounce, value: isFormValid)
                        
                        Text("Create Curation")
                            .font(.highlighterBody.weight(.semibold))
                    }
                    .foregroundColor(.white)
                }
                .frame(height: 56)
                .disabled(!isFormValid)
                .scaleEffect(isFormValid ? 1 : 0.98)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
            }
            
            Text("You can add articles and highlights after creating")
                .font(.highlighterCaption)
                .foregroundColor(.highlighterSecondaryText)
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .scaleEffect(animateForm ? 1 : 0.95)
        .opacity(animateForm ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.6), value: animateForm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                AnimatedBackgroundView(particleAnimation: $particleAnimation)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Progress indicator
                            ProgressIndicatorView(currentStep: currentStep, totalSteps: 3)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .opacity(animateHeader ? 1 : 0)
                                .offset(y: animateHeader ? 0 : -20)
                            
                            VStack(spacing: 24) {
                                // Header image section
                                headerImageSection
                                
                                // Color picker
                                colorPickerSection
                                
                                // Form fields
                                formFieldsSection
                    
                                // Info box
                                infoBoxSection
                    
                                // Create button
                                createButtonSection
                            }
                        }
                        .padding(.bottom, keyboardHeight)
                        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                        .id("scrollView")
                    }
                    .onTapGesture {
                        nameFieldFocused = false
                        titleFieldFocused = false
                        descriptionFieldFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .background(Color.highlighterBackground.ignoresSafeArea())
            .navigationTitle("New Curation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                    .foregroundColor(.highlighterPurple)
                }
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: $selectedImage,
                matching: .images
            )
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedImageData = data
                            HapticManager.shared.impact(.medium)
                        }
                    }
                }
            }
            .onAppear {
                startAnimations()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            animateHeader = true
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            animateForm = true
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particleAnimation = true
        }
    }
    
    private func createCuration() {
        guard isFormValid else { return }
        
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                try await appState.createCuration(
                    name: curationName,
                    title: curationTitle,
                    description: description.isEmpty ? nil : description,
                    image: imageUrl.isEmpty ? nil : imageUrl
                )
                
                await MainActor.run {
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.highlighterPurple : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
        .frame(height: 4)
    }
}

struct FeatureBadge: View {
    let icon: String
    let text: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            Text(text)
                .font(.ds.footnote)
                .foregroundColor(.highlighterSecondaryText)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct AnimatedBackgroundView: View {
    @Binding var particleAnimation: Bool
    @State private var gradientRotation = 0.0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.highlighterBackground,
                    Color.highlighterPurple.opacity(0.05),
                    Color.highlighterOrange.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    Color.highlighterPurple.opacity(0.03),
                    Color.clear,
                    Color.highlighterOrange.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation))
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CreateCurationView()
        .environmentObject(AppState())
}
