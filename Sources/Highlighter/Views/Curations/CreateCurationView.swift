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
    @State private var selectedColor = DesignSystem.Colors.primary
    @State private var showColorPicker = false
    @State private var nameFieldFocused = false
    @State private var titleFieldFocused = false
    @State private var descriptionFieldFocused = false
    @Namespace private var animation
    
    let gradientColors: [[Color]] = [
        [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
        [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
        [DesignSystem.Colors.secondary, DesignSystem.Colors.secondaryLight],
        [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
        [DesignSystem.Colors.primaryDark, DesignSystem.Colors.primary]
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
                                .font(.ds.body)
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
                            .font(.ds.title3)
                            .symbolEffect(.bounce, value: selectedImageData != nil)
                        
                        Text(selectedImageData == nil ? "Add Cover Image" : "Change Image")
                            .font(DesignSystem.Typography.body.weight(.medium))
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
                                selectedColor = gradientColors[index].first ?? DesignSystem.Colors.primary
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
                                        .stroke(DesignSystem.Colors.surface, lineWidth: 3)
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
                    .font(DesignSystem.Typography.caption.weight(.medium))
                    .foregroundColor(nameFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                if !curationName.isEmpty {
                    Text("\(curationName.count)/50")
                        .font(.ds.footnote)
                        .foregroundColor(curationName.count > 50 ? DesignSystem.Colors.error : DesignSystem.Colors.textSecondary)
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
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                nameFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
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
                    .font(DesignSystem.Typography.caption.weight(.medium))
                    .foregroundColor(titleFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                if !curationTitle.isEmpty {
                    Text("\(curationTitle.count)/100")
                        .font(.ds.footnote)
                        .foregroundColor(curationTitle.count > 100 ? DesignSystem.Colors.error : DesignSystem.Colors.textSecondary)
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
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                titleFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
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
                    .font(DesignSystem.Typography.caption.weight(.medium))
                    .foregroundColor(descriptionFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Text("Optional")
                    .font(.ds.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .animation(.easeInOut(duration: 0.2), value: descriptionFieldFocused)
            
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("Describe your curation...")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .padding(.horizontal, DesignSystem.Spacing.micro)
                        .padding(.vertical, DesignSystem.Spacing.small)
                }
                
                TextEditor(text: $description)
                    .font(DesignSystem.Typography.body)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onTapGesture { descriptionFieldFocused = true }
            }
            .padding(DesignSystem.Spacing.base)
            .frame(minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                descriptionFieldFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border,
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
                .font(DesignSystem.Typography.caption.weight(.medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            TextField("https://...", text: $imageUrl)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(DesignSystem.Spacing.base + DesignSystem.Spacing.nano)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
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
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.white)
                        .font(.ds.body)
                }
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("What are Article Curations?")
                        .font(DesignSystem.Typography.body.weight(.semibold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Create themed collections of articles, highlights, and content. Perfect for organizing your reading lists, research topics, or sharing knowledge with others.")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            // Feature highlights
            HStack(spacing: 16) {
                FeatureBadge(icon: "folder.fill", text: "Organize", color: DesignSystem.Colors.primary)
                FeatureBadge(icon: "square.and.arrow.up", text: "Share", color: DesignSystem.Colors.secondary)
                FeatureBadge(icon: "sparkles", text: "Discover", color: DesignSystem.Colors.primary)
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
                                colors: [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.secondary.opacity(0.3)],
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
                                    [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.8)] :
                                    [DesignSystem.Colors.textTertiary, DesignSystem.Colors.divider],
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
                            .font(.ds.headline).fontWeight(.semibold)
                            .symbolEffect(.bounce, value: isFormValid)
                        
                        Text("Create Curation")
                            .font(DesignSystem.Typography.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                }
                .frame(height: 56)
                .disabled(!isFormValid)
                .scaleEffect(isFormValid ? 1 : 0.98)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
            }
            
            Text("You can add articles and highlights after creating")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
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
            .background(DesignSystem.Colors.background.ignoresSafeArea())
            .navigationTitle("New Curation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
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
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
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
                    .fill(step <= currentStep ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
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
                    .font(.ds.headline)
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            Text(text)
                .font(.ds.footnote)
                .foregroundColor(DesignSystem.Colors.textSecondary)
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
                    DesignSystem.Colors.background,
                    DesignSystem.Colors.primary.opacity(0.05),
                    DesignSystem.Colors.secondary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primary.opacity(0.03),
                    Color.clear,
                    DesignSystem.Colors.secondary.opacity(0.03)
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
