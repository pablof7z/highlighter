import SwiftUI

struct EnhancedTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                        HapticManager.shared.impact(.light)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ds.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
        )
    }
}

struct TabBarItem: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    private var icon: String {
        switch tab {
        case .home:
            return isSelected ? "house.fill" : "house"
        case .discover:
            return isSelected ? "safari.fill" : "safari"
        case .library:
            return isSelected ? "books.vertical.fill" : "books.vertical"
        case .profile:
            return isSelected ? "person.circle.fill" : "person.circle"
        case .import:
            return isSelected ? "square.and.arrow.down.fill" : "square.and.arrow.down"
        }
    }
    
    private var tabTitle: String {
        switch tab {
        case .home: return "Home"
        case .discover: return "Discover"
        case .library: return "Library"
        case .profile: return "Profile"
        case .import: return "Import"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                
                Text(tabTitle)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .ds.primary : .ds.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.ds.primary.opacity(0.1))
                            .matchedGeometryEffect(id: "tabSelection", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}