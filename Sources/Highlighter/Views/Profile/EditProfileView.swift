import SwiftUI
import PhotosUI
import NDKSwift

struct EditProfileView: View {
    @Binding var profile: EnhancedProfileView.EditableProfile
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedBannerItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var isLoadingBanner = false
    @State private var showingDeleteConfirmation = false
    @State private var keyboardHeight: CGFloat = 0
    
    // Form validation
    @State private var isValidNip05 = true
    @State private var isValidWebsite = true
    @State private var isValidLud16 = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    // Profile Picture Section
                    profilePictureSection
                    
                    // Banner Section
                    bannerSection
                    
                    // Form Fields
                    VStack(spacing: .ds.medium) {
                        // Display Name
                        FormField(
                            title: "Display Name",
                            text: $profile.displayName,
                            placeholder: "Your name",
                            icon: "person.fill",
                            maxLength: 50
                        )
                        
                        // About/Bio
                        FormField(
                            title: "About",
                            text: $profile.about,
                            placeholder: "Tell us about yourself",
                            icon: "text.alignleft",
                            isMultiline: true,
                            maxLength: 500
                        )
                        
                        // Website
                        FormField(
                            title: "Website",
                            text: $profile.website,
                            placeholder: "https://yourwebsite.com",
                            icon: "globe",
                            keyboardType: .URL,
                            isValid: $isValidWebsite
                        )
                        .onChange(of: profile.website) { value in
                            validateWebsite(value)
                        }
                        
                        // NIP-05 Verification
                        FormField(
                            title: "NIP-05 Identifier",
                            text: $profile.nip05,
                            placeholder: "you@yourdomain.com",
                            icon: "checkmark.seal",
                            keyboardType: .emailAddress,
                            isValid: $isValidNip05
                        )
                        .onChange(of: profile.nip05) { value in
                            validateNip05(value)
                        }
                        
                        // Lightning Address
                        FormField(
                            title: "Lightning Address",
                            text: $profile.lud16,
                            placeholder: "you@wallet.com",
                            icon: "bolt.fill",
                            iconColor: .yellow,
                            keyboardType: .emailAddress,
                            isValid: $isValidLud16
                        )
                        .onChange(of: profile.lud16) { value in
                            validateLud16(value)
                        }
                    }
                    .padding(.horizontal, .ds.screenPadding)
                    
                    // Advanced Options
                    DisclosureGroup {
                        VStack(spacing: .ds.medium) {
                            Button(action: { showingDeleteConfirmation = true }) {
                                Label("Clear Profile Picture", systemImage: "trash")
                                    .font(.ds.body)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.red.opacity(0.1))
                                    )
                            }
                            
                            Text("Profile changes are published to all connected relays")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    } label: {
                        Label("Advanced Options", systemImage: "gearshape")
                            .font(.ds.bodyMedium)
                            .foregroundColor(.ds.text)
                    }
                    .padding(.horizontal, .ds.screenPadding)
                    .padding(.vertical, .ds.small)
                    .background(DesignSystem.Colors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, .ds.screenPadding)
                }
                .padding(.vertical, .ds.large)
                .padding(.bottom, keyboardHeight)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .font(.ds.bodyMedium)
                    .disabled(!isFormValid)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                keyboardHeight = 0
            }
        }
        .confirmationDialog("Delete Profile Picture", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                profile.picture = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove your profile picture?")
        }
    }
    
    // MARK: - Profile Picture Section
    
    private var profilePictureSection: some View {
        VStack(spacing: .ds.medium) {
            Text("Profile Picture")
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.textSecondary)
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    if isLoadingPhoto {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 120, height: 120)
                            .background(DesignSystem.Colors.surfaceSecondary)
                            .clipShape(Circle())
                    } else if !profile.picture.isEmpty, let url = URL(string: profile.picture) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            profilePlaceholder
                        }
                    } else {
                        profilePlaceholder
                    }
                    
                    // Edit overlay
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 120, height: 120)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text("Change")
                                    .font(.ds.caption)
                            }
                            .foregroundColor(.white)
                        )
                        .opacity(0.8)
                }
            }
            .onChange(of: selectedPhotoItem) { item in
                Task {
                    await loadPhoto(from: item)
                }
            }
        }
    }
    
    private var profilePlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.ds.textSecondary)
            )
    }
    
    // MARK: - Banner Section
    
    private var bannerSection: some View {
        VStack(spacing: .ds.medium) {
            Text("Banner")
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.textSecondary)
            
            PhotosPicker(
                selection: $selectedBannerItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    if isLoadingBanner {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(DesignSystem.Colors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else if !profile.banner.isEmpty, let url = URL(string: profile.banner) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        } placeholder: {
                            bannerPlaceholder
                        }
                    } else {
                        bannerPlaceholder
                    }
                    
                    // Edit overlay
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .frame(height: 150)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 24))
                                Text("Change Banner")
                                    .font(.ds.caption)
                            }
                            .foregroundColor(.white)
                        )
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, .ds.screenPadding)
            .onChange(of: selectedBannerItem) { item in
                Task {
                    await loadBanner(from: item)
                }
            }
        }
    }
    
    private var bannerPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 150)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.ds.textSecondary)
            )
    }
    
    // MARK: - Form Validation
    
    private var isFormValid: Bool {
        isValidNip05 && isValidWebsite && isValidLud16
    }
    
    private func validateWebsite(_ url: String) {
        guard !url.isEmpty else {
            isValidWebsite = true
            return
        }
        
        let pattern = #"^https?://[^\s/$.?#].[^\s]*$"#
        isValidWebsite = url.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func validateNip05(_ identifier: String) {
        guard !identifier.isEmpty else {
            isValidNip05 = true
            return
        }
        
        let pattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        isValidNip05 = identifier.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func validateLud16(_ address: String) {
        guard !address.isEmpty else {
            isValidLud16 = true
            return
        }
        
        // Same as email validation for Lightning addresses
        let pattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        isValidLud16 = address.range(of: pattern, options: .regularExpression) != nil
    }
    
    // MARK: - Photo Loading
    
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingPhoto = true
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Upload image to hosting service
                let imageUrl = try await ImageUploadService.shared.uploadImageWithFallback(
                    data,
                    type: .profile
                )
                
                await MainActor.run {
                    profile.picture = imageUrl
                    isLoadingPhoto = false
                }
            }
        } catch {
            await MainActor.run {
                isLoadingPhoto = false
                // Show error to user
                print("Failed to upload profile image: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadBanner(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingBanner = true
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Upload image to hosting service
                let imageUrl = try await ImageUploadService.shared.uploadImageWithFallback(
                    data,
                    type: .banner
                )
                
                await MainActor.run {
                    profile.banner = imageUrl
                    isLoadingBanner = false
                }
            }
        } catch {
            await MainActor.run {
                isLoadingBanner = false
                // Show error to user
                print("Failed to upload banner image: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Save Profile
    
    private func saveProfile() {
        HapticManager.shared.notification(.success)
        onSave()
        dismiss()
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var iconColor: Color = .ds.primary
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    var maxLength: Int? = nil
    @Binding var isValid: Bool
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String,
        iconColor: Color = .ds.primary,
        keyboardType: UIKeyboardType = .default,
        isMultiline: Bool = false,
        maxLength: Int? = nil,
        isValid: Binding<Bool> = .constant(true)
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.iconColor = iconColor
        self.keyboardType = keyboardType
        self.isMultiline = isMultiline
        self.maxLength = maxLength
        self._isValid = isValid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.small) {
            // Header
            HStack {
                Label(title, systemImage: icon)
                    .font(.ds.footnoteMedium)
                    .foregroundColor(.ds.textSecondary)
                    .symbolRenderingMode(.hierarchical)
                
                Spacer()
                
                if let maxLength = maxLength {
                    Text("\(text.count)/\(maxLength)")
                        .font(.ds.caption)
                        .foregroundColor(text.count > maxLength ? .red : .ds.textTertiary)
                }
            }
            
            // Input field
            Group {
                if isMultiline {
                    TextEditor(text: $text)
                        .font(.ds.body)
                        .foregroundColor(.ds.text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 100)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.ds.body)
                        .foregroundColor(.ds.text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DesignSystem.Colors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isValid ? Color.clear : Color.red.opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
            .onChange(of: text) { newValue in
                if let maxLength = maxLength, newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                }
            }
            
            // Error message
            if !isValid {
                Text("Please enter a valid \(title.lowercased())")
                    .font(.ds.caption)
                    .foregroundColor(.red)
            }
        }
    }
}