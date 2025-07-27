import SwiftUI
import NDKSwift

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showImportSheet = false
    @State private var privateKey = ""
    @State private var viewAppeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: .ds.xxl) {
                    Spacer()
                    
                    // Logo and branding
                    VStack(spacing: .ds.large) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 64, weight: .light))
                            .foregroundColor(.ds.primary)
                            .scaleEffect(viewAppeared ? 1 : 0.5)
                            .opacity(viewAppeared ? 1 : 0)
                            .animation(DesignSystem.Animation.springSmooth.delay(0.1), value: viewAppeared)
                        
                        VStack(spacing: .ds.small) {
                            Text("Highlighter")
                                .font(.ds.largeTitle)
                                .foregroundColor(.ds.text)
                            
                            Text("Save and share the best ideas")
                                .font(.ds.body)
                                .foregroundColor(.ds.textSecondary)
                        }
                        .opacity(viewAppeared ? 1 : 0)
                        .offset(y: viewAppeared ? 0 : 20)
                        .animation(DesignSystem.Animation.smooth.delay(0.2), value: viewAppeared)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: .ds.base) {
                        Button(action: createAccount) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Create Account")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .unifiedPrimaryButton()
                        
                        Button(action: { showImportSheet = true }) {
                            Text("I have an account")
                                .frame(maxWidth: .infinity)
                        }
                        .unifiedSecondaryButton()
                    }
                    .padding(.horizontal, .ds.xxl)
                    .opacity(viewAppeared ? 1 : 0)
                    .offset(y: viewAppeared ? 0 : 20)
                    .animation(DesignSystem.Animation.smooth.delay(0.3), value: viewAppeared)
                    
                    Spacer()
                        .frame(height: .ds.huge)
                }
            }
            .sheet(isPresented: $showImportSheet) {
                ModernImportSheet(privateKey: $privateKey, onImport: importAccount)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewAppeared = true
                }
            }
        }
    }
    
    private func createAccount() {
        HapticManager.shared.impact(HapticManager.ImpactStyle.medium)
        
        Task {
            do {
                try await appState.createAccount()
                HapticManager.shared.notification(.success)
            } catch {
                HapticManager.shared.notification(.error)
            }
        }
    }
    
    private func importAccount() {
        guard !privateKey.isEmpty else { return }
        
        HapticManager.shared.impact(HapticManager.ImpactStyle.medium)
        
        Task {
            do {
                try await appState.importAccount(nsec: privateKey)
                
                await MainActor.run {
                    showImportSheet = false
                    privateKey = ""
                    HapticManager.shared.notification(.success)
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
}

struct ModernImportSheet: View {
    @Binding var privateKey: String
    let onImport: () -> Void
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .ds.large) {
                VStack(alignment: .leading, spacing: .ds.small) {
                    Text("Your private key")
                        .font(.ds.footnoteMedium)
                        .foregroundColor(.ds.textSecondary)
                    
                    SecureField("nsec1...", text: $privateKey)
                        .font(.ds.body)
                        .modernTextField()
                        .focused($isTextFieldFocused)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                VStack(spacing: .ds.small) {
                    Text("Your private key is stored locally and never leaves your device")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Label("Keep this secret", systemImage: "lock.fill")
                        .font(.ds.captionMedium)
                        .foregroundColor(.ds.warning)
                }
                .padding(.top, .ds.small)
                
                Spacer()
                
                VStack(spacing: .ds.base) {
                    Button(action: onImport) {
                        Text("Import Account")
                            .frame(maxWidth: .infinity)
                    }
                    .unifiedPrimaryButton()
                    .disabled(privateKey.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .unifiedSecondaryButton()
                }
            }
            .padding(.ds.large)
            .navigationTitle("Import Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.ds.body)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
