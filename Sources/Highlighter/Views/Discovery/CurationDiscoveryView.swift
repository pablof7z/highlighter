import SwiftUI
import NDKSwift

struct CurationDiscoveryView: View {
    let searchText: String
    @EnvironmentObject var appState: AppState
    @State private var curations: [ArticleCuration] = []
    
    var filteredCurations: [ArticleCuration] {
        if searchText.isEmpty {
            return curations
        }
        return curations.filter { curation in
            curation.title.localizedCaseInsensitiveContains(searchText) ||
            curation.description?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCurations) { curation in
                    CurationCard(curation: curation)
                }
            }
            .padding()
        }
        .task {
            await loadCurations()
        }
    }
    
    private func loadCurations() async {
        guard let ndk = appState.ndk else { return }
        
        let curationSource = await ndk.outbox.observe(
            filter: NDKFilter(kinds: [30004], limit: 50),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in curationSource.events {
            if let curation = try? ArticleCuration(from: event) {
                await MainActor.run {
                    if !curations.contains(where: { $0.id == curation.id }) {
                        curations.append(curation)
                        curations.sort { $0.createdAt > $1.createdAt }
                    }
                }
            }
        }
    }
}

// MARK: - Curation Card

struct CurationCard: View {
    let curation: ArticleCuration
    @State private var curator: NDKUserProfile?
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover image or gradient
            if let imageURL = curation.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    gradientPlaceholder
                }
                .cornerRadius(8)
            } else {
                gradientPlaceholder
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(curation.title)
                    .font(.ds.headline)
                    .foregroundColor(.ds.text)
                    .lineLimit(2)
                
                // Description
                if let description = curation.description {
                    Text(description)
                        .font(.ds.body)
                        .foregroundColor(.ds.textSecondary)
                        .lineLimit(2)
                }
                
                // Stats and curator
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.ds.primaryDark.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if let picture = curator?.picture, let url = URL(string: picture) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.ds.primaryDark)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.ds.primaryDark)
                                }
                            }
                        
                        Text(curator?.displayName ?? formatPubkey(curation.author))
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Label("\(curation.articles.count)", systemImage: "doc.text")
                            .font(.ds.caption)
                            .foregroundColor(.ds.textSecondary)
                    }
                }
            }
            .padding()
        }
        .modernCard(noPadding: true)
        .task {
            await loadCurator()
        }
    }
    
    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [
                Color.ds.primary.opacity(0.2),
                Color.ds.secondary.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 150)
        .overlay {
            Image(systemName: "folder.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private func formatPubkey(_ pubkey: String) -> String {
        String(pubkey.prefix(8)) + "..."
    }
    
    private func loadCurator() async {
        guard let ndk = appState.ndk else { return }
        
        let profileDataSource = await ndk.outbox.observe(
            filter: NDKFilter(
                authors: [curation.author],
                kinds: [0]
            ),
            maxAge: 3600,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in profileDataSource.events {
            if let fetchedProfile = JSONCoding.safeDecode(NDKUserProfile.self, from: event.content) {
                await MainActor.run {
                    self.curator = fetchedProfile
                }
                break
            }
        }
    }
}