import SwiftUI
import NDKSwift

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @AppStorage("appTheme") private var appTheme = AppTheme.system
    @AppStorage("highlightColor") private var highlightColor = HighlightColor.orange
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("autoPlayVideos") private var autoPlayVideos = true
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showRelativeTime") private var showRelativeTime = true
    @AppStorage("defaultZapAmount") private var defaultZapAmount = 21
    
    @State private var showRelayManager = false
    @State private var showPrivacyPolicy = false
    @State private var showAbout = false
    @State private var showDeleteAccount = false
    @State private var showExportData = false
    @State private var animateGradient = false
    
    enum AppTheme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var icon: String {
            switch self {
            case .system: return "gear"
            case .light: return "sun.max"
            case .dark: return "moon"
            }
        }
    }
    
    enum HighlightColor: String, CaseIterable {
        case orange = "Orange"
        case purple = "Purple"
        case blue = "Blue"
        case green = "Green"
        case pink = "Pink"
        
        var color: Color {
            switch self {
            case .orange: return .orange
            case .purple: return .purple
            case .blue: return .blue
            case .green: return .green
            case .pink: return .pink
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    // App Icon Header with enhanced animation
                    appIconHeader
                    
                    // Appearance Section
                    SettingsSection(title: "Appearance", icon: "paintbrush") {
                        // Theme Selector
                        VStack(alignment: .leading, spacing: .ds.medium) {
                            Text("Theme")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.textSecondary)
                            
                            HStack(spacing: .ds.small) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    ThemeButton(
                                        theme: theme,
                                        isSelected: appTheme == theme,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                appTheme = theme
                                                HapticManager.shared.impact(.light)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        // Highlight Color
                        VStack(alignment: .leading, spacing: .ds.medium) {
                            Text("Highlight Color")
                                .font(.ds.footnoteMedium)
                                .foregroundColor(.ds.textSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: .ds.small) {
                                    ForEach(HighlightColor.allCases, id: \.self) { color in
                                        ColorButton(
                                            color: color,
                                            isSelected: highlightColor == color,
                                            action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    highlightColor = color
                                                    HapticManager.shared.impact(.light)
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        // Compact Mode Toggle
                        SettingsToggle(
                            title: "Compact Mode",
                            subtitle: "Show more content with smaller UI elements",
                            icon: "rectangle.compress.vertical",
                            isOn: $compactMode
                        )
                    }
                    
                    // General Section
                    SettingsSection(title: "General", icon: "gear") {
                        SettingsToggle(
                            title: "Haptic Feedback",
                            subtitle: "Vibration feedback for interactions",
                            icon: "hand.tap",
                            isOn: $enableHaptics
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsToggle(
                            title: "Auto-Play Videos",
                            subtitle: "Automatically play videos in feed",
                            icon: "play.circle",
                            isOn: $autoPlayVideos
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsToggle(
                            title: "Relative Time",
                            subtitle: "Show times as '2 hours ago' instead of timestamps",
                            icon: "clock",
                            isOn: $showRelativeTime
                        )
                    }
                    
                    // Lightning Section
                    SettingsSection(title: "Lightning", icon: "bolt.fill", iconColor: .yellow) {
                        VStack(alignment: .leading, spacing: .ds.small) {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.ds.title3)
                                    .foregroundColor(.yellow)
                                
                                Text("Default Zap Amount")
                                    .font(.ds.bodyMedium)
                                    .foregroundColor(.ds.text)
                                
                                Spacer()
                                
                                Text("\(defaultZapAmount) sats")
                                    .font(.ds.body)
                                    .foregroundColor(.ds.textSecondary)
                            }
                            
                            // Zap amount slider
                            VStack(spacing: .ds.small) {
                                Slider(value: Binding(
                                    get: { Double(defaultZapAmount) },
                                    set: { defaultZapAmount = Int($0) }
                                ), in: 1...1000, step: 1)
                                .tint(.yellow)
                                
                                // Quick select buttons
                                HStack {
                                    ForEach([21, 100, 500, 1000], id: \.self) { amount in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                                defaultZapAmount = amount
                                                HapticManager.shared.impact(.light)
                                            }
                                        }) {
                                            Text("\(amount)")
                                                .font(.ds.caption)
                                                .foregroundColor(defaultZapAmount == amount ? .white : .ds.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule()
                                                        .fill(defaultZapAmount == amount ? Color.yellow : Color.gray.opacity(0.2)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "Lightning Wallet",
                            subtitle: "Configure your wallet connection",
                            icon: "bolt.circle.fill",
                            iconColor: .yellow,
                            action: {
                                HapticManager.shared.impact(.light)
                                showLightningWallet()
                            }
                        )
                    }
                    
                    // Network Section
                    SettingsSection(title: "Network", icon: "network") {
                        SettingsRow(
                            title: "Relay Manager",
                            subtitle: "Manage relay connections",
                            icon: "server.rack",
                            action: { showRelayManager = true }
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "Outbox Settings",
                            subtitle: "Configure intelligent relay routing",
                            icon: "tray.and.arrow.up",
                            action: {
                                HapticManager.shared.impact(.light)
                                showOutboxSettings()
                            }
                        )
                    }
                    
                    // Data & Privacy Section
                    SettingsSection(title: "Data & Privacy", icon: "lock.shield") {
                        SettingsRow(
                            title: "Export Data",
                            subtitle: "Download all your highlights and content",
                            icon: "square.and.arrow.down",
                            action: { showExportData = true }
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "Clear Cache",
                            subtitle: "Free up storage space",
                            icon: "trash",
                            action: clearCache
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "Privacy Policy",
                            subtitle: "Learn how we protect your data",
                            icon: "hand.raised",
                            action: { showPrivacyPolicy = true }
                        )
                    }
                    
                    // About Section
                    SettingsSection(title: "About", icon: "info.circle") {
                        SettingsRow(
                            title: "Version",
                            subtitle: getVersionString(),
                            icon: "app.badge"
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "About Highlighter",
                            subtitle: "Learn more about this app",
                            icon: "questionmark.circle",
                            action: { showAbout = true }
                        )
                        
                        Divider()
                            .background(DesignSystem.Colors.divider)
                        
                        SettingsRow(
                            title: "Rate on App Store",
                            subtitle: "Share your feedback",
                            icon: "star",
                            action: {
                                openAppStoreReview()
                            }
                        )
                    }
                    
                    // Danger Zone
                    VStack(spacing: .ds.medium) {
                        Button(action: { showDeleteAccount = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.ds.headline)
                                Text("Delete Account")
                                    .font(.ds.bodyMedium)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.red.opacity(0.1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Text("This action cannot be undone")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                    .padding(.top, .ds.large)
                }
                .padding(.vertical, .ds.large)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.ds.bodyMedium)
                }
            }
        }
        .sheet(isPresented: $showRelayManager) {
            RelayManagerView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .alert("Delete Account", isPresented: $showDeleteAccount) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This will remove all your data from this device. Your content on Nostr relays will remain.")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
    
    // MARK: - App Icon Header
    
    private var appIconHeader: some View {
        VStack(spacing: .ds.medium) {
            ZStack {
                // Animated gradient background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                highlightColor.color.opacity(0.3),
                                highlightColor.color.opacity(0.1)
                            ],
                            startPoint: animateGradient ? .topLeading : .bottomTrailing,
                            endPoint: animateGradient ? .bottomTrailing : .topLeading
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Image(systemName: "highlighter")
                    .font(.system(size: 40)
                    .foregroundColor(highlightColor.color)
                    .frame(width: 80, height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(highlightColor.color.opacity(0.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(highlightColor.color.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Text("Highlighter")
                .font(.ds.title2)
                .foregroundColor(.ds.text)
            
            Text("Knowledge at your fingertips")
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
        }
        .padding(.vertical, .ds.large)
    }
    
    // MARK: - Actions
    
    private func clearCache() {
        Task {
            // Clear NDK cache
            if let cache = appState.ndk?.cache {
                do {
                    try await cache.clear()
                    await MainActor.run {
                        HapticManager.shared.notification(.success)
                        appState.errorMessage = "Cache cleared successfully"
                    }
                } catch {
                    await MainActor.run {
                        HapticManager.shared.notification(.error)
                        appState.errorMessage = "Failed to clear cache: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func deleteAccount() {
        Task {
            await appState.logout()
            // Additional cleanup
        }
    }
    
    private func getVersionString() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (Build \(build))"
    }
    
    private func showLightningWallet() {
        // Show Lightning wallet configuration
        showRelayManager = false // Close other sheets first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                let lightningWalletView = LightningWalletView()
                    .environmentObject(appState)
                let hostingController = UIHostingController(rootView: lightningWalletView)
                rootVC.present(hostingController, animated: true)
            }
        }
    }
    
    private func showOutboxSettings() {
        // Show Outbox configuration
        showRelayManager = false // Close other sheets first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showRelayManager = true // Relay manager includes outbox settings
        }
    }
    
    private func openAppStoreReview() {
        // For now, show a thank you message since we don't have an app ID yet
        HapticManager.shared.notification(.success)
        appState.errorMessage = "Thank you for your interest in rating Highlighter! We'll be on the App Store soon."
    }
}

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    var iconColor: Color = .ds.primary
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.medium) {
            // Section header
            Label(title, systemImage: icon)
                .font(.ds.footnoteMedium)
                .foregroundColor(.ds.textSecondary)
                .symbolRenderingMode(.hierarchical)
                .padding(.horizontal, .ds.screenPadding)
            
            // Section content
            VStack(spacing: .ds.medium) {
                content()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(DesignSystem.Colors.surface)
            )
            .padding(.horizontal, .ds.screenPadding)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    var iconColor: Color = .ds.primary
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: .ds.medium) {
                Image(systemName: icon)
                    .font(.ds.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.ds.bodyMedium)
                        .foregroundColor(.ds.text)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.ds.callout)
                        .foregroundColor(.ds.textTertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String?
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: .ds.medium) {
            Image(systemName: icon)
                .font(.ds.title3)
                .foregroundColor(.ds.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.ds.primary.opacity(0.1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ds.bodyMedium)
                    .foregroundColor(.ds.text)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.ds.primary)
        }
    }
}

struct ThemeButton: View {
    let theme: SettingsView.AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .ds.small) {
                Image(systemName: theme.icon)
                    .font(.ds.title2)
                    .foregroundColor(isSelected ? .white : .ds.text)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isSelected ? Color.ds.primary : Color.gray.opacity(0.1))
                    )
                
                Text(theme.rawValue)
                    .font(.ds.caption)
                    .foregroundColor(isSelected ? .ds.primary : .ds.textSecondary)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ColorButton: View {
    let color: SettingsView.HighlightColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .ds.small) {
                Circle()
                    .fill(color.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.ds.bodyBold)
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(color.rawValue)
                    .font(.ds.caption)
                    .foregroundColor(isSelected ? .ds.text : .ds.textSecondary)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Placeholder Views

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .ds.large) {
                    Image(systemName: "highlighter")
                        .font(.system(size: 60)
                        .foregroundColor(.orange)
                        .padding(.top, 40)
                    
                    Text("Highlighter")
                        .font(.ds.largeTitle)
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                    
                    Text("Your personal knowledge companion for the decentralized web. Capture, organize, and share insights from anywhere.")
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: .ds.medium) {
                        Link(destination: URL(string: "https://github.com/highlighter/app")!) {
                            Label("GitHub", systemImage: "link")
                                .font(.ds.bodyMedium)
                        }
                        
                        Link(destination: URL(string: "https://highlighter.com")!) {
                            Label("Website", systemImage: "globe")
                                .font(.ds.bodyMedium)
                        }
                    }
                    .padding(.top, .ds.large)
                    
                    Spacer()
                }
                .padding(.vertical, .ds.large)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}