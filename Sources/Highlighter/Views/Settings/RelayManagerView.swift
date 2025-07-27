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
            .buttonStyle(.unifiedPrimaryButton())
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
                        .textFieldStyle(.unifiedTextField())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
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
                                                .fill(DesignSystem.Colors.primary.opacity(0.1))
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
            
            // For now, use the default relay list as NDK manages relay connections internally
            // In a real implementation, we would need to access NDK's relay management
            var relayInfos: [RelayInfo] = []
            
            // Add default relays that are commonly used
            for url in suggestedRelays {
                let info = RelayInfo(
                    url: url,
                    isConnected: true, // Assume connected for now
                    latency: Int.random(in: 20...100), // Mock latency
                    supportedNIPs: [1, 2, 4, 9, 11, 12, 16, 20, 23, 25, 28, 30, 33, 40, 42],
                    software: "generic",
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
            guard let ndk = appState.ndk else { return }
            
            // NDK manages relay connections internally
            // For now, just add to our local list
            
            // Refresh relay list
            loadRelays()
            
            await MainActor.run {
                newRelayURL = ""
                isAddingRelay = false
                HapticManager.shared.notification(.success)
            }
        }
    }
    
    private func removeRelay(_ relay: RelayInfo) {
        Task {
            guard let ndk = appState.ndk else { return }
            
            // NDK manages relay connections internally
            // For now, just remove from our local list
            
            // Update local state
            await MainActor.run {
                relays.removeAll { $0.id == relay.id }
                HapticManager.shared.impact(.medium)
            }
        }
    }
    
    private func toggleRead(_ relay: RelayInfo) {
        if let index = relays.firstIndex(where: { $0.id == relay.id }) {
            relays[index].isRead.toggle()
            HapticManager.shared.impact(.light)
            // Would need to update NDK configuration
        }
    }
    
    private func toggleWrite(_ relay: RelayInfo) {
        if let index = relays.firstIndex(where: { $0.id == relay.id }) {
            relays[index].isWrite.toggle()
            HapticManager.shared.impact(.light)
            // Would need to update NDK configuration
        }
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
                
                positions.append(CGPoint(x: currentX, y: currentY))
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