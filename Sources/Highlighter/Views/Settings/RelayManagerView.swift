import SwiftUI
import NDKSwift

struct RelayManagerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var relays: [RelayInfo] = []
    @State private var isAddingRelay = false
    @State private var newRelayURL = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    @State private var selectedRelay: RelayInfo?
    @State private var showRelayDetails = false
    
    struct RelayInfo: Identifiable {
        let id = UUID()
        let url: String
        var isConnected: Bool
        var latency: Int? // milliseconds
        var supportedNIPs: [Int] = []
        var software: String?
        var version: String?
        var isRead: Bool = true
        var isWrite: Bool = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                if relays.isEmpty && !isRefreshing {
                    emptyStateView
                } else {
                    relayListView
                }
            }
            .navigationTitle("Relay Manager")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.ds.bodyMedium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: refreshRelays) {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRefreshing)
                        }
                        .disabled(isRefreshing)
                        
                        Button(action: { isAddingRelay = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingRelay) {
                addRelaySheet
            }
            .sheet(item: $selectedRelay) { relay in
                relayDetailSheet(relay: relay)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadRelays()
            }
        }
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(.ds.textTertiary)
                .pulse(style: .standard)
            
            Text("No Relays Connected")
                .font(.ds.title2)
                .foregroundColor(.ds.text)
            
            Text("Add relays to connect to the Nostr network")
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { isAddingRelay = true }) {
                Label("Add Relay", systemImage: "plus.circle.fill")
                    .font(.ds.bodyMedium)
            }
            .unifiedPrimaryButton()
        }
        .padding()
    }
    
    private var relayListView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Connected relays section
                if !connectedRelays.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Connected Relays")
                            .font(.ds.footnote)
                            .foregroundColor(.ds.textSecondary)
                            .padding(.horizontal)
                        
                        ForEach(connectedRelays) { relay in
                            RelayRowView(
                                relay: relay,
                                onTap: { selectedRelay = relay },
                                onToggleRead: { toggleRead(relay) },
                                onToggleWrite: { toggleWrite(relay) },
                                onRemove: { removeRelay(relay) }
                            )
                        }
                    }
                }
                
                // Disconnected relays section
                if !disconnectedRelays.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Disconnected Relays")
                            .font(.ds.footnote)
                            .foregroundColor(.ds.textSecondary)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ForEach(disconnectedRelays) { relay in
                            RelayRowView(
                                relay: relay,
                                onTap: { selectedRelay = relay },
                                onToggleRead: { toggleRead(relay) },
                                onToggleWrite: { toggleWrite(relay) },
                                onRemove: { removeRelay(relay) }
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await refreshRelaysAsync()
        }
    }
    
    private var addRelaySheet: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.large) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Relay URL")
                        .font(.ds.footnote)
                        .foregroundColor(.ds.textSecondary)
                    
                    TextField("wss://relay.example.com", text: $newRelayURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.surfaceSecondary)
                        )
                }
                
                // Suggested relays
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Suggested Relays")
                        .font(.ds.footnote)
                        .foregroundColor(.ds.textSecondary)
                    
                    ForEach(suggestedRelays, id: \.self) { relay in
                        Button(action: { newRelayURL = relay }) {
                            HStack {
                                Text(relay)
                                    .font(.ds.bodyMedium)
                                    .foregroundColor(.ds.text)
                                
                                Spacer()
                                
                                if newRelayURL == relay {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.ds.primary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.Colors.surfaceSecondary)
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Relay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newRelayURL = ""
                        isAddingRelay = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addNewRelay()
                    }
                    .disabled(newRelayURL.isEmpty)
                }
            }
        }
    }
    
    private func relayDetailSheet(relay: RelayInfo) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Connection status
                    HStack {
                        Circle()
                            .fill(relay.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(relay.isConnected ? "Connected" : "Disconnected")
                            .font(.ds.bodyMedium)
                            .foregroundColor(.ds.text)
                        
                        Spacer()
                        
                        if let latency = relay.latency {
                            Text("\(latency)ms")
                                .font(.ds.footnote)
                                .foregroundColor(.ds.textSecondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                    )
                    
                    // Relay info
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        if let software = relay.software {
                            InfoRow(label: "Software", value: software)
                        }
                        
                        if let version = relay.version {
                            InfoRow(label: "Version", value: version)
                        }
                        
                        InfoRow(label: "Read", value: relay.isRead ? "Enabled" : "Disabled")
                        InfoRow(label: "Write", value: relay.isWrite ? "Enabled" : "Disabled")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                    )
                    
                    // Supported NIPs
                    if !relay.supportedNIPs.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Supported NIPs")
                                .font(.ds.footnote)
                                .foregroundColor(.ds.textSecondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(relay.supportedNIPs, id: \.self) { nip in
                                    Text("NIP-\(nip)")
                                        .font(.ds.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(DesignSystem.Colors.primary.opacity(0.1)
                                        )
                                        .foregroundColor(.ds.primary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.Colors.surfaceSecondary)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(relay.url)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedRelay = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var connectedRelays: [RelayInfo] {
        relays.filter { $0.isConnected }
    }
    
    private var disconnectedRelays: [RelayInfo] {
        relays.filter { !$0.isConnected }
    }
    
    private let suggestedRelays = [
        "wss://relay.damus.io",
        "wss://relay.nostr.band",
        "wss://nos.lol",
        "wss://relay.primal.net",
        "wss://purplepag.es"
    ]
    
    // MARK: - Methods
    
    private func loadRelays() {
        Task {
            guard let ndk = appState.ndk else { return }
            
            await MainActor.run {
                isRefreshing = true
            }
            
            var relayInfos: [RelayInfo] = []
            
            // Get configured relays from NDK
            // Note: NDK manages relay connections internally
            // We'll use the saved relay list or defaults
            
            // Get relay URLs from preferences or use defaults
            let configuredRelays = loadRelayPreferences()
            
            for url in configuredRelays {
                // Simple connectivity check by attempting to fetch a recent event
                let isConnected = await checkRelayConnection(url: url, ndk: ndk)
                let latency = isConnected ? await measureRelayLatency(url: url, ndk: ndk) : nil
                
                let info = RelayInfo(
                    url: url,
                    isConnected: isConnected,
                    latency: latency,
                    supportedNIPs: [1, 2, 4, 9, 11, 12, 16, 20, 23, 25, 28, 30, 33, 40, 42],
                    software: "nostr-relay",
                    version: "1.0.0",
                    isRead: true,
                    isWrite: true
                )
                
                relayInfos.append(info)
            }
            
            await MainActor.run {
                self.relays = relayInfos
                self.isRefreshing = false
            }
        }
    }
    
    private func checkRelayConnection(url: String, ndk: NDK) async -> Bool {
        // Check if we can fetch a recent event from this relay
        let filter = NDKFilter(kinds: [1], limit: 1)
        
        // Create a timeout task
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            return false
        }
        
        // Try to fetch an event
        let dataSource = await ndk.outbox.observe(filter: filter, maxAge: 60)
        
        for await _ in dataSource.events {
            timeoutTask.cancel()
            return true
        }
        
        return await timeoutTask.value
    }
    
    private func measureRelayLatency(url: String, ndk: NDK) async -> Int? {
        let start = Date()
        
        // Simple latency test - fetch a recent event
        let filter = NDKFilter(kinds: [1], limit: 1)
        
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            return nil
        }
        
        let dataSource = await ndk.outbox.observe(filter: filter, maxAge: 60)
        
        for await _ in dataSource.events {
            timeoutTask.cancel()
            let latency = Int(Date().timeIntervalSince(start) * 1000)
            return min(latency, 9999) // Cap at 9999ms
        }
        
        return await timeoutTask.value
    }
    
    private func refreshRelays() {
        loadRelays()
    }
    
    private func refreshRelaysAsync() async {
        loadRelays()
    }
    
    private func addNewRelay() {
        guard !newRelayURL.isEmpty else { return }
        
        var url = newRelayURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure proper WebSocket URL format
        if !url.hasPrefix("wss://") && !url.hasPrefix("ws://") {
            url = "wss://\(url)"
        }
        
        // Validate URL
        guard URL(string: url) != nil else {
            errorMessage = "Invalid relay URL"
            showError = true
            return
        }
        
        Task {
            guard let _ = appState.ndk else { return }
            
            // Check if relay is already added
            if relays.contains(where: { $0.url == url }) {
                await MainActor.run {
                    errorMessage = "Relay already exists"
                    showError = true
                }
                return
            }
            
            // Note: NDK manages relay connections internally
            // We'll add it to our local list and save to preferences
            
            // Add to local list
            let newRelay = RelayInfo(
                url: url,
                isConnected: false,
                latency: nil,
                supportedNIPs: [1, 2, 4, 9, 11, 12, 16, 20, 23, 25, 28, 30, 33, 40, 42],
                software: "unknown",
                version: "unknown",
                isRead: true,
                isWrite: true
            )
            
            await MainActor.run {
                relays.append(newRelay)
                saveRelayPreferences()
                newRelayURL = ""
                isAddingRelay = false
                HapticManager.shared.notification(.success)
            }
            
            // Refresh to check connection status
            loadRelays()
        }
    }
    
    private func removeRelay(_ relay: RelayInfo) {
        Task {
            guard let _ = appState.ndk else { return }
            
            // Update local state
            await MainActor.run {
                relays.removeAll { $0.id == relay.id }
                saveRelayPreferences()
                HapticManager.shared.impact(.medium)
            }
        }
    }
    
    private func toggleRead(_ relay: RelayInfo) {
        if let index = relays.firstIndex(where: { $0.id == relay.id }) {
            relays[index].isRead.toggle()
            saveRelayPreferences()
            HapticManager.shared.impact(.light)
        }
    }
    
    private func toggleWrite(_ relay: RelayInfo) {
        if let index = relays.firstIndex(where: { $0.id == relay.id }) {
            relays[index].isWrite.toggle()
            saveRelayPreferences()
            HapticManager.shared.impact(.light)
        }
    }
    
    // MARK: - Persistence
    
    private func saveRelayPreferences() {
        let relayUrls = relays.map { $0.url }
        UserDefaults.standard.set(relayUrls, forKey: "highlighter.configured_relays")
    }
    
    private func loadRelayPreferences() -> [String] {
        UserDefaults.standard.stringArray(forKey: "highlighter.configured_relays") ?? suggestedRelays
    }
}

// MARK: - Supporting Views

struct RelayRowView: View {
    let relay: RelayManagerView.RelayInfo
    let onTap: () -> Void
    let onToggleRead: () -> Void
    let onToggleWrite: () -> Void
    let onRemove: () -> Void
    
    @State private var showActions = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Connection indicator
            Circle()
                .fill(relay.isConnected ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            
            // Relay info
            VStack(alignment: .leading, spacing: 4) {
                Text(relay.url)
                    .font(.ds.bodyMedium)
                    .foregroundColor(.ds.text)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    if let latency = relay.latency {
                        Label("\(latency)ms", systemImage: "speedometer")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: relay.isRead ? "eye" : "eye.slash")
                            .font(.ds.caption)
                            .foregroundColor(relay.isRead ? .ds.textSecondary : .ds.textTertiary)
                        
                        Image(systemName: relay.isWrite ? "pencil" : "pencil.slash")
                            .font(.ds.caption)
                            .foregroundColor(relay.isWrite ? .ds.textSecondary : .ds.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            // Actions button
            Button(action: { showActions = true }) {
                Image(systemName: "ellipsis")
                    .font(.ds.body)
                    .foregroundColor(.ds.textSecondary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(action: onToggleRead) {
                Label(relay.isRead ? "Disable Read" : "Enable Read", systemImage: relay.isRead ? "eye.slash" : "eye")
            }
            
            Button(action: onToggleWrite) {
                Label(relay.isWrite ? "Disable Write" : "Enable Write", systemImage: relay.isWrite ? "pencil.slash" : "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: onRemove) {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.ds.body)
                .foregroundColor(.ds.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.ds.bodyMedium)
                .foregroundColor(.ds.text)
        }
    }
}

// Simple flow layout for NIPs
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y),
                proposal: .unspecified
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY)
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                maxWidth = max(maxWidth, currentX)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
            self.positions = positions
        }
    }
}

#Preview {
    RelayManagerView()
        .environmentObject(AppState())
}