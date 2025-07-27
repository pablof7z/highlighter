import SwiftUI
import NDKSwift
import UniformTypeIdentifiers

// Move DraggedArticle outside to make it accessible to nested types
struct DraggedArticle: Codable, Transferable {
    let url: String?
    let eventId: String?
    let title: String
    
    var identifier: String {
        eventId ?? url ?? title
    }
    
    static var typeIdentifier: String {
        UTType.draggedArticle.identifier
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .draggedArticle)
    }
}

extension UTType {
    static let draggedArticle = UTType(exportedAs: "com.highlighter.draggedArticle")
}

struct CurationManagementView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // View state
    @State private var viewMode: ViewMode = .grid
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent
    @State private var selectedCurations: Set<ArticleCuration> = []
    @State private var isEditMode = false
    @State private var showCreateCuration = false
    @State private var curationToEdit: ArticleCuration?
    @State private var showDeleteConfirmation = false
    
    // Drag and drop state
    @State private var draggedArticle: DraggedArticle?
    @State private var hoveredCuration: ArticleCuration?
    @State private var dropAnimation = false
    
    // Animation state
    @State private var appearAnimation = false
    @State private var headerAnimation = false
    @Namespace private var animation
    
    enum ViewMode: String, CaseIterable {
        case grid = "square.grid.2x2"
        case list = "list.bullet"
        case carousel = "rectangle.stack"
        
        var title: String {
            switch self {
            case .grid: return "Grid"
            case .list: return "List"
            case .carousel: return "Carousel"
            }
        }
    }
    
    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case alphabetical = "A-Z"
        case articleCount = "Most Articles"
        
        var icon: String {
            switch self {
            case .recent: return "clock"
            case .alphabetical: return "textformat"
            case .articleCount: return "number"
            }
        }
    }
    
    var filteredCurations: [ArticleCuration] {
        let curations = appState.userCurations.filter { curation in
            searchText.isEmpty ||
            curation.title.localizedCaseInsensitiveContains(searchText) ||
            (curation.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .recent:
            return curations.sorted { $0.updatedAt > $1.updatedAt }
        case .alphabetical:
            return curations.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .articleCount:
            return curations.sorted { $0.articles.count > $1.articles.count }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.primary.opacity(0.03),
                        DesignSystem.Colors.secondary.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced header
                    VStack(spacing: 16) {
                        // Search bar with animations
                        HStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .font(.ds.body)
                                
                                TextField("Search curations...", text: $searchText)
                                    .textFieldStyle(.plain)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                            .transition(.scale.combined(with: .opacity)
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.base)
                            .padding(.vertical, DesignSystem.Spacing.small + 2)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                            
                            // Sort button
                            Menu {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(action: { 
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            sortOption = option
                                        }
                                        HapticManager.shared.impact(.light)
                                    }) {
                                        Label(option.rawValue, systemImage: option.icon)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .symbolEffect(.bounce, value: sortOption)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .opacity(headerAnimation ? 1 : 0)
                        .offset(y: headerAnimation ? 0 : -20)
                        
                        // View mode selector with smooth transitions
                        HStack(spacing: 0) {
                            ForEach(ViewMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewMode = mode
                                    }
                                    HapticManager.shared.impact(.light)
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: mode.rawValue)
                                            .font(.ds.title3)
                                            .foregroundColor(viewMode == mode ? .white : DesignSystem.Colors.textSecondary)
                                        
                                        Text(mode.title)
                                            .font(.caption2)
                                            .foregroundColor(viewMode == mode ? .white : DesignSystem.Colors.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DesignSystem.Spacing.small)
                                    .background(
                                        ZStack {
                                            if viewMode == mode {
                                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small + 2)
                                                    .fill(DesignSystem.Colors.primary)
                                                    .matchedGeometryEffect(id: "viewMode", in: animation)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(DesignSystem.Spacing.micro)
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(DesignSystem.CornerRadius.medium + 2)
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .opacity(headerAnimation ? 1 : 0)
                        .offset(y: headerAnimation ? 0 : -20)
                    }
                    .padding(.top, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.large)
                    
                    // Content area with transitions
                    ZStack {
                        switch viewMode {
                        case .grid:
                            GridView(
                                curations: filteredCurations,
                                selectedCurations: $selectedCurations,
                                isEditMode: isEditMode,
                                hoveredCuration: $hoveredCuration,
                                draggedArticle: draggedArticle,
                                curationToEdit: $curationToEdit,
                                shareCuration: shareCuration,
                                deleteCuration: deleteCuration,
                                addArticleToCuration: addArticleToCuration
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            )
                            
                        case .list:
                            ListView(
                                curations: filteredCurations,
                                selectedCurations: $selectedCurations,
                                isEditMode: isEditMode,
                                hoveredCuration: $hoveredCuration,
                                draggedArticle: draggedArticle,
                                curationToEdit: $curationToEdit,
                                shareCuration: shareCuration,
                                deleteCuration: deleteCuration,
                                addArticleToCuration: addArticleToCuration
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            )
                            
                        case .carousel:
                            CarouselView(
                                curations: filteredCurations,
                                curationToEdit: $curationToEdit
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    
                    // Empty state
                    if filteredCurations.isEmpty {
                        CurationEmptyStateView(searchText: searchText)
                            .transition(.scale.combined(with: .opacity)
                    }
                }
            }
            .navigationTitle("Manage Curations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if !filteredCurations.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isEditMode.toggle()
                                    if !isEditMode {
                                        selectedCurations.removeAll()
                                    }
                                }
                                HapticManager.shared.impact(.light)
                            }) {
                                Text(isEditMode ? "Done" : "Edit")
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                        
                        Button(action: { showCreateCuration = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .symbolEffect(.bounce, value: showCreateCuration)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateCuration) {
                CreateCurationView()
                    .environmentObject(appState)
            }
            .sheet(item: $curationToEdit) { curation in
                CurationDetailView(curation: curation)
                    .environmentObject(appState)
            }
            .confirmationDialog(
                "Delete \(selectedCurations.count) Curation\(selectedCurations.count == 1 ? "" : "s")?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteCurations()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                startAnimations()
            }
            .onDrop(of: [.draggedArticle], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.4)) {
            appearAnimation = true
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            headerAnimation = true
        }
    }
    
    private func deleteCurations() {
        Task {
            do {
                // Convert Set to Array for the deletion
                let curationsToDelete = Array(selectedCurations)
                
                // Publish deletion events
                try await appState.publishingService.deleteCurations(curationsToDelete)
                
                // Note: Local state removal would be handled by DataStreamManager
                // when it receives the deletion events from the relays
                
                HapticManager.shared.notification(.success)
                selectedCurations.removeAll()
                isEditMode = false
                
            } catch {
                HapticManager.shared.notification(.error)
                // Could show an error alert here
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.draggedArticle.identifier) {
                _ = provider.loadTransferable(type: DraggedArticle.self) { result in
                    switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            // Handle adding article to curation
                            HapticManager.shared.impact(.medium)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dropAnimation = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dropAnimation = false
                            }
                        }
                    case .failure(_):
                        // Failed to load dragged article
                        break
                    }
                }
                return true
            }
        }
        return false
    }
    
    private func shareCuration(_ curation: ArticleCuration) {
        let shareText = """
        Check out my curation: \(curation.title)
        
        \(curation.description ?? "A collection of articles on Nostr")
        
        nostr:\(curation.id)
        """
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
    
    private func deleteCuration(_ curation: ArticleCuration) {
        Task {
            do {
                // Delete the curation event
                try await appState.publishingService.deleteCuration(curation)
                
                await MainActor.run {
                    // Remove from selected curations if present
                    selectedCurations.remove(curation)
                    HapticManager.shared.notification(.success)
                }
            } catch {
                await MainActor.run {
                    HapticManager.shared.notification(.error)
                }
            }
        }
    }
    
    private func addArticleToCuration(_ article: DraggedArticle, _ curation: ArticleCuration) async {
        // Find the actual article from the data
        guard let actualArticle = appState.articles.first(where: { $0.id == article.identifier }) else {
            HapticManager.shared.notification(.error)
            return
        }
        
        do {
            try await appState.publishingService.updateCuration(curation, addingArticle: actualArticle)
            HapticManager.shared.notification(.success)
        } catch {
            HapticManager.shared.notification(.error)
        }
    }
}

// MARK: - Grid View

struct GridView: View {
    let curations: [ArticleCuration]
    @Binding var selectedCurations: Set<ArticleCuration>
    let isEditMode: Bool
    @Binding var hoveredCuration: ArticleCuration?
    let draggedArticle: DraggedArticle?
    @Binding var curationToEdit: ArticleCuration?
    let shareCuration: (ArticleCuration) -> Void
    let deleteCuration: (ArticleCuration) -> Void
    let addArticleToCuration: (DraggedArticle, ArticleCuration) async -> Void
    
    @State private var dropTargets: [String: Bool] = [:]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(curations) { curation in
                    gridItem(for: curation)
                }
            }
            .padding(DesignSystem.Spacing.screenPadding)
        }
    }
    
    @ViewBuilder
    private func gridItem(for curation: ArticleCuration) -> some View {
        let isSelected = selectedCurations.contains(curation)
        let isHovered = hoveredCuration?.id == curation.id && draggedArticle != nil
        
        CurationGridItem(
            curation: curation,
            isSelected: isSelected,
            isEditMode: isEditMode,
            isHovered: isHovered
        )
        .onTapGesture {
            handleTap(curation: curation)
        }
        .onDrop(of: [.draggedArticle], isTargeted: Binding(
            get: { dropTargets[curation.id] ?? false },
            set: { isTargeted in
                dropTargets[curation.id] = isTargeted
                hoveredCuration = isTargeted ? curation : nil
            }
        )) { providers in
            handleDropOnCuration(providers: providers, curation: curation)
        }
        .contextMenu {
            CurationContextMenu(curation: curation, curationToEdit: $curationToEdit, shareCuration: shareCuration, deleteCuration: deleteCuration)
        }
    }
    
    private func handleTap(curation: ArticleCuration) {
        if isEditMode {
            toggleSelection(curation)
        } else {
            curationToEdit = curation
        }
    }
    
    private func toggleSelection(_ curation: ArticleCuration) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCurations.contains(curation) {
                selectedCurations.remove(curation)
            } else {
                selectedCurations.insert(curation)
            }
        }
        HapticManager.shared.impact(.light)
    }
    
    private func handleDropOnCuration(providers: [NSItemProvider], curation: ArticleCuration) -> Bool {
        guard let provider = providers.first,
              provider.hasItemConformingToTypeIdentifier(DraggedArticle.typeIdentifier) else {
            return false
        }
        
        provider.loadDataRepresentation(forTypeIdentifier: DraggedArticle.typeIdentifier) { data, error in
            guard let data = data,
                  let draggedArticle = try? JSONDecoder().decode(DraggedArticle.self, from: data) else {
                return
            }
            
            Task {
                await addArticleToCuration(draggedArticle, curation)
            }
        }
        
        HapticManager.shared.impact(.medium)
        return true
    }
}

// MARK: - List View

struct ListView: View {
    let curations: [ArticleCuration]
    @Binding var selectedCurations: Set<ArticleCuration>
    let isEditMode: Bool
    @Binding var hoveredCuration: ArticleCuration?
    let draggedArticle: DraggedArticle?
    @Binding var curationToEdit: ArticleCuration?
    let shareCuration: (ArticleCuration) -> Void
    let deleteCuration: (ArticleCuration) -> Void
    let addArticleToCuration: (DraggedArticle, ArticleCuration) async -> Void
    
    @State private var dropTargets: [String: Bool] = [:]
    
    var body: some View {
        List {
            ForEach(curations) { curation in
                listRow(for: curation)
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func listRow(for curation: ArticleCuration) -> some View {
        let isSelected = selectedCurations.contains(curation)
        let isHovered = hoveredCuration?.id == curation.id && draggedArticle != nil
        
        CurationListRow(
            curation: curation,
            isSelected: isSelected,
            isEditMode: isEditMode,
            isHovered: isHovered
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        .listRowBackground(Color.clear)
        .onTapGesture {
            handleTap(curation: curation)
        }
        .onDrop(of: [.draggedArticle], isTargeted: Binding(
            get: { dropTargets[curation.id] ?? false },
            set: { isTargeted in
                dropTargets[curation.id] = isTargeted
                hoveredCuration = isTargeted ? curation : nil
            }
        )) { providers in
            handleDropOnCuration(providers: providers, curation: curation)
        }
        .contextMenu {
            CurationContextMenu(curation: curation, curationToEdit: $curationToEdit, shareCuration: shareCuration, deleteCuration: deleteCuration)
        }
    }
    
    private func handleTap(curation: ArticleCuration) {
        if isEditMode {
            toggleSelection(curation)
        } else {
            curationToEdit = curation
        }
    }
    
    private func toggleSelection(_ curation: ArticleCuration) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCurations.contains(curation) {
                selectedCurations.remove(curation)
            } else {
                selectedCurations.insert(curation)
            }
        }
        HapticManager.shared.impact(.light)
    }
    
    private func handleDropOnCuration(providers: [NSItemProvider], curation: ArticleCuration) -> Bool {
        guard let provider = providers.first,
              provider.hasItemConformingToTypeIdentifier(DraggedArticle.typeIdentifier) else {
            return false
        }
        
        provider.loadDataRepresentation(forTypeIdentifier: DraggedArticle.typeIdentifier) { data, error in
            guard let data = data,
                  let draggedArticle = try? JSONDecoder().decode(DraggedArticle.self, from: data) else {
                return
            }
            
            Task {
                await addArticleToCuration(draggedArticle, curation)
            }
        }
        
        HapticManager.shared.impact(.medium)
        return true
    }
}

// MARK: - Carousel View

struct CarouselView: View {
    let curations: [ArticleCuration]
    @Binding var curationToEdit: ArticleCuration?
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(curations.enumerated()), id: \.element.id) { index, curation in
                    CurationManagementCarouselCard(
                        curation: curation,
                        geometry: geometry,
                        index: index,
                        currentIndex: currentIndex,
                        totalCount: curations.count
                    )
                    .offset(x: cardOffset(index: index, geometry: geometry)
                    .offset(x: dragOffset.width)
                    .scaleEffect(cardScale(index: index)
                    .opacity(cardOpacity(index: index)
                    .zIndex(Double(curations.count - abs(index - currentIndex))
                    .onTapGesture {
                        if index == currentIndex {
                            curationToEdit = curation
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentIndex = index
                            }
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
                
                // Navigation dots
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<curations.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentIndex ? 1.2 : 1)
                                .animation(DesignSystem.Animation.springSnappy, value: currentIndex)
                        }
                    }
                    .padding(.bottom, DesignSystem.Spacing.large)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.2
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.width < -threshold && currentIndex < curations.count - 1 {
                                currentIndex += 1
                            } else if value.translation.width > threshold && currentIndex > 0 {
                                currentIndex -= 1
                            }
                            dragOffset = .zero
                        }
                        
                        HapticManager.shared.impact(.light)
                    }
            )
        }
        .padding(.vertical, DesignSystem.Spacing.huge)
    }
    
    private func cardOffset(index: Int, geometry: GeometryProxy) -> CGFloat {
        let difference = CGFloat(index - currentIndex)
        let cardWidth = geometry.size.width * 0.8
        let spacing: CGFloat = 20
        
        return difference * (cardWidth + spacing)
    }
    
    private func cardScale(index: Int) -> CGFloat {
        let difference = abs(index - currentIndex)
        return 1 - (CGFloat(difference) * 0.1)
    }
    
    private func cardOpacity(index: Int) -> Double {
        let difference = abs(index - currentIndex)
        return difference == 0 ? 1 : (difference == 1 ? 0.7 : 0.3)
    }
}

// MARK: - Supporting Views

struct CurationGridItem: View {
    let curation: ArticleCuration
    let isSelected: Bool
    let isEditMode: Bool
    let isHovered: Bool
    @State private var animateHover = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image section
            ZStack {
                if let imageUrl = curation.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ShimmerView()
                    }
                    .frame(height: 120)
                    .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "folder.fill")
                                .font(.system(size: 40, weight: .regular, design: .default)
                                .foregroundColor(.white.opacity(0.8)
                        )
                }
                
                // Selection overlay
                if isEditMode {
                    DesignSystem.Colors.darkBackground.opacity(isSelected ? 0.3 : 0)
                        .overlay(
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(DesignSystem.Spacing.small),
                            alignment: .topTrailing
                        )
                }
                
                // Drop indicator
                if isHovered {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(DesignSystem.Colors.primary, lineWidth: 3)
                        .background(DesignSystem.Colors.primary.opacity(0.1))
                        .scaleEffect(animateHover ? 1.05 : 1)
                }
            }
            .cornerRadius(DesignSystem.CornerRadius.medium, corners: [.topLeft, .topRight])
            
            // Content section
            VStack(alignment: .leading, spacing: 6) {
                Text(curation.title)
                    .font(DesignSystem.Typography.body.weight(.medium))
                    .lineLimit(1)
                
                HStack {
                    Label("\(curation.articles.count)", systemImage: "doc.text")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text(RelativeTimeFormatter.relativeTime(from: curation.updatedAt)
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.base)
            .padding(.bottom, DesignSystem.Spacing.base)
        }
        .modernCard()
        .scaleEffect(isSelected || isHovered ? 0.95 : 1)
        .animation(DesignSystem.Animation.springSnappy, value: isSelected)
        .animation(DesignSystem.Animation.springSnappy, value: isHovered)
        .onAppear {
            if isHovered {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    animateHover = true
                }
            }
        }
    }
}

struct CurationListRow: View {
    let curation: ArticleCuration
    let isSelected: Bool
    let isEditMode: Bool
    let isHovered: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection indicator
            if isEditMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    .animation(DesignSystem.Animation.springSnappy, value: isSelected)
            }
            
            // Thumbnail
            if let imageUrl = curation.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerView()
                }
                .frame(width: 60, height: 60)
                .cornerRadius(DesignSystem.CornerRadius.small + 2)
            } else {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small + 2)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "folder.fill")
                            .foregroundColor(.white.opacity(0.8)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(curation.title)
                    .font(DesignSystem.Typography.body.weight(.medium))
                    .lineLimit(1)
                
                if let description = curation.description {
                    Text(description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    Label("\(curation.articles.count) articles", systemImage: "doc.text")
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(RelativeTimeFormatter.relativeTime(from: curation.updatedAt)
                        .font(.ds.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if !isEditMode {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(isHovered ? DesignSystem.Colors.primary : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(DesignSystem.Animation.springSnappy, value: isHovered)
    }
}

struct CurationManagementCarouselCard: View {
    let curation: ArticleCuration
    let geometry: GeometryProxy
    let index: Int
    let currentIndex: Int
    let totalCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            if let imageUrl = curation.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerView()
                }
                .frame(height: geometry.size.height * 0.5)
                .clipped()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 80, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(height: geometry.size.height * 0.5)
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 12) {
                Text(curation.title)
                    .font(.ds.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                if let description = curation.description {
                    Text(description)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                HStack {
                    Label("\(curation.articles.count) articles", systemImage: "doc.text")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text(RelativeTimeFormatter.relativeTime(from: curation.updatedAt)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.large)
            .frame(maxHeight: .infinity)
        }
        .frame(width: geometry.size.width * 0.8)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.xl)
        .shadow(
            color: .black.opacity(index == currentIndex ? 0.2 : 0.1),
            radius: index == currentIndex ? 20 : 10,
            y: 10
        )
    }
}

struct CurationContextMenu: View {
    let curation: ArticleCuration
    @Binding var curationToEdit: ArticleCuration?
    let shareCuration: (ArticleCuration) -> Void
    let deleteCuration: (ArticleCuration) -> Void
    
    var body: some View {
        Button(action: { curationToEdit = curation }) {
            Label("View Details", systemImage: "eye")
        }
        
        Button(action: { 
            shareCuration(curation)
            HapticManager.shared.impact(.light)
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(role: .destructive, action: {
            deleteCuration(curation)
            HapticManager.shared.notification(.warning)
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct CurationEmptyStateView: View {
    let searchText: String
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "folder.badge.plus" : "magnifyingglass")
                .font(.system(size: 60, weight: .regular, design: .default))
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.5))
                .scaleEffect(animateIcon ? 1.1 : 1)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animateIcon = true
                    }
                }
            
            Text(searchText.isEmpty ? "No curations yet" : "No results found")
                .font(.ds.title3)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(searchText.isEmpty ? 
                 "Create your first curation to organize articles" : 
                 "Try adjusting your search terms")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.huge)
    }
}

struct ShimmerView: View {
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(DesignSystem.Colors.textTertiary)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    DesignSystem.Colors.surface.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset * geometry.size.width)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        shimmerOffset = 2
                    }
                }
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    CurationManagementView()
        .environmentObject(AppState())
}