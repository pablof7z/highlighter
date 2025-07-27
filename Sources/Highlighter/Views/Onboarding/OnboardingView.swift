import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateElements = false
    @State private var showImportSheet = false
    @State private var privateKey = ""
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var appState: AppState
    @Namespace private var namespace
    
    let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Dynamic gradient background
            UnifiedGradientBackground(style: currentPage == 0 ? .subtle : (currentPage == 1 ? .mesh : (currentPage == 2 ? .immersive : .glow)))
            
            // Subtle ambient background
            Color.black.opacity(0.3)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count {
                        Button("Skip") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage = pages.count
                            }
                        }
                        .font(.ds.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                        .transition(.opacity)
                    }
                }
                .frame(height: 60)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            namespace: namespace,
                            isActive: currentPage == index
                        )
                        .tag(index)
                    }
                    
                    // Authentication page
                    OnboardingAuthView(
                        showImportSheet: $showImportSheet,
                        privateKey: $privateKey,
                        isActive: currentPage == pages.count,
                        onComplete: completeOnboarding
                    )
                    .tag(pages.count)
                    .environmentObject(appState)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                
                // Bottom controls
                VStack(spacing: 32) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0...pages.count, id: \.self) { index in
                            OnboardingPageIndicator(
                                isActive: currentPage == index,
                                index: index,
                                currentPage: currentPage
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentPage = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action button (hide on auth page)
                    if currentPage < pages.count {
                        OnboardingActionButton(
                            title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                            isLastPage: currentPage == pages.count - 1,
                            action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentPage += 1
                                    HapticManager.shared.impact(.light)
                                }
                            }
                        )
                        .padding(.horizontal, DesignSystem.Spacing.huge)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateElements = true
            }
        }
        .onChange(of: currentPage) { _ in
            HapticManager.shared.impact(.light)
        }
    }
    
    private func completeOnboarding() {
        HapticManager.shared.notification(.success)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let features: [Feature]
    
    struct Feature {
        let icon: String
        let text: String
    }
    
    static let allPages = [
        OnboardingPage(
            title: "Welcome to\nHighlighter",
            subtitle: "Your personal knowledge companion for the decentralized web",
            icon: "highlighter",
            iconColor: .orange,
            features: [
                Feature(icon: "quote.bubble.fill", text: "Capture insights from anywhere"),
                Feature(icon: "sparkles", text: "AI-powered smart highlights"),
                Feature(icon: "person.2.fill", text: "Share with your community")
            ]
        ),
        OnboardingPage(
            title: "Highlight\nWhat Matters",
            subtitle: "Save and organize the best content from articles, notes, and conversations",
            icon: "text.quote",
            iconColor: .purple,
            features: [
                Feature(icon: "wand.and.stars", text: "One-tap highlighting"),
                Feature(icon: "folder.fill", text: "Smart collections"),
                Feature(icon: "magnifyingglass", text: "Powerful search")
            ]
        ),
        OnboardingPage(
            title: "Build Your\nKnowledge Graph",
            subtitle: "Connect ideas, discover patterns, and grow your understanding",
            icon: "brain",
            iconColor: .blue,
            features: [
                Feature(icon: "link", text: "Connect related highlights"),
                Feature(icon: "chart.xyaxis.line", text: "Visualize your learning"),
                Feature(icon: "lightbulb.fill", text: "Surface insights")
            ]
        ),
        OnboardingPage(
            title: "Join the\nConversation",
            subtitle: "Share highlights, discuss ideas, and learn from others",
            icon: "bubble.left.and.bubble.right.fill",
            iconColor: .green,
            features: [
                Feature(icon: "heart.fill", text: "Support great content"),
                Feature(icon: "bolt.fill", text: "Zap creators directly"),
                Feature(icon: "globe", text: "Decentralized & open")
            ]
        )
    ]
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let namespace: Namespace.ID
    let isActive: Bool
    @State private var animateIcon = false
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 48) {
            Spacer()
            
            // Simplified icon
            ZStack {
                // Subtle background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                page.iconColor.opacity(0.2),
                                page.iconColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Main icon
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.white)
            }
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
            
            // Content
            VStack(spacing: 24) {
                // Title
                Text(page.title)
                    .font(.ds.bodyBold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.ds.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.huge)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                        HStack(spacing: 16) {
                            Image(systemName: feature.icon)
                                .font(.ds.title3))
                                .foregroundColor(page.iconColor)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(page.iconColor.opacity(0.2))
                                )
                            
                            Text(feature.text)
                                .font(.ds.callout)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(x: animateContent ? 0 : -20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1 + 0.2),
                            value: animateContent
                        )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.huge * 1.5)
            }
            
            Spacer()
        }
        .onAppear {
            if isActive {
                animateIcon = true
                withAnimation {
                    animateContent = true
                }
            }
        }
        .onChange(of: isActive) { active in
            if active {
                animateIcon = true
                withAnimation {
                    animateContent = true
                }
            } else {
                animateIcon = false
                animateContent = false
            }
        }
    }
}

// MARK: - Components

struct OnboardingPageIndicator: View {
    let isActive: Bool
    let index: Int
    let currentPage: Int
    
    private var shouldAnimate: Bool {
        abs(currentPage - index) <= 1
    }
    
    var body: some View {
        Capsule()
            .fill(isActive ? Color.white : Color.white.opacity(0.3))
            .frame(width: isActive ? 32 : 8, height: 8)
            .scaleEffect(shouldAnimate ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

struct OnboardingActionButton: View {
    let title: String
    let isLastPage: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var shimmerAnimation = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isLastPage ? Color.orange : Color.white.opacity(0.2),
                                isLastPage ? Color.orange.opacity(0.8) : Color.white.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Simple border for last page
                if isLastPage {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
                
                // Button text
                Text(title)
                    .font(.ds.bodyMedium)
                    .foregroundColor(isLastPage ? .white : .white.opacity(0.9))
            }
            .frame(height: 56)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                action()
            }
        )
        .shadow(
            color: isLastPage ? Color.orange.opacity(0.3) : Color.white.opacity(0.1),
            radius: 20,
            y: 10
        )
        .onAppear {
            if isLastPage {
                shimmerAnimation = true
            }
        }
    }
}

// Floating particles removed for cleaner UI

// MARK: - Authentication Page

struct OnboardingAuthView: View {
    @Binding var showImportSheet: Bool
    @Binding var privateKey: String
    let isActive: Bool
    let onComplete: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var animateContent = false
    @State private var isCreatingAccount = false
    
    var body: some View {
        VStack(spacing: 48) {
            Spacer()
            
            // Icon and title
            VStack(spacing: 24) {
                ZStack {
                    // Subtle background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.2),
                                    Color.orange.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    // Key icon
                    Image(systemName: "key.fill")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundColor(.white)
                }
                .scaleEffect(isActive ? 1.0 : 0.8)
                .opacity(isActive ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
                
                VStack(spacing: 16) {
                    Text("Ready to\nGet Started")
                        .font(.ds.bodyBold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Create your account or sign in to continue")
                        .font(.ds.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.huge)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: animateContent)
                }
            }
            
            Spacer()
            
            // Auth buttons
            VStack(spacing: 16) {
                Button(action: createAccount) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.ds.title3, weight: .medium))
                        Text("Create Account")
                            .font(.ds.bodyMedium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        isCreatingAccount ? 
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                        : nil
                    )
                }
                .disabled(isCreatingAccount)
                .shadow(color: Color.orange.opacity(0.3), radius: 20, y: 10)
                
                Button(action: { showImportSheet = true }) {
                    Text("I have an account")
                        .font(.ds.bodyMedium)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.huge)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: animateContent)
            
            Spacer()
                .frame(height: 50)
        }
        .sheet(isPresented: $showImportSheet) {
            OnboardingImportSheet(privateKey: $privateKey, onImport: importAccount)
        }
        .onAppear {
            if isActive {
                withAnimation {
                    animateContent = true
                }
            }
        }
        .onChange(of: isActive) { active in
            if active {
                withAnimation {
                    animateContent = true
                }
            } else {
                animateContent = false
            }
        }
    }
    
    private func createAccount() {
        isCreatingAccount = true
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                try await appState.createAccount()
                await MainActor.run {
                    HapticManager.shared.notification(.success)
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    isCreatingAccount = false
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
    
    private func importAccount() {
        guard !privateKey.isEmpty else { return }
        
        HapticManager.shared.impact(.medium)
        
        Task {
            do {
                try await appState.importAccount(nsec: privateKey)
                
                await MainActor.run {
                    showImportSheet = false
                    privateKey = ""
                    HapticManager.shared.notification(.success)
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
}

// MARK: - Import Sheet

struct OnboardingImportSheet: View {
    @Binding var privateKey: String
    let onImport: () -> Void
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "key.horizontal.fill")
                            .font(.ds.bodyMedium))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                        
                        Text("Import Your Account")
                            .font(.ds.title, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Enter your private key to sign in")
                            .font(.ds.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 32)
                    
                    // Input section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Private Key")
                            .font(.ds.footnoteMedium)
                            .foregroundColor(.white.opacity(0.6))
                        
                        SecureField("nsec1...", text: $privateKey)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .tint(.orange)
                            .focused($isTextFieldFocused)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    // Security note
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.ds.caption)
                            .foregroundColor(.orange)
                        
                        Text("Your key is stored locally and never leaves your device")
                            .font(.ds.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: onImport) {
                            Text("Import Account")
                                .font(.ds.bodyMedium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.orange, Color.orange.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        .disabled(privateKey.isEmpty)
                        .opacity(privateKey.isEmpty ? 0.6 : 1)
                        .shadow(color: Color.orange.opacity(0.3), radius: 20, y: 10)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.ds.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(height: 44)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, 32)
                }
            }
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.ds.title2))
                            .foregroundColor(.white.opacity(0.3))
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .environmentObject(AppState())
}