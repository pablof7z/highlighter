import SwiftUI
import NDKSwift

struct ArticleListView: View {
    @EnvironmentObject var appState: AppState
    @State private var articles: [Article] = []
    @State private var featuredArticles: [Article] = []
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    if articles.isEmpty {
                        emptyState
                    } else {
                        // Featured Articles Section
                        if !featuredArticles.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                                Text("Featured")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DesignSystem.Spacing.medium) {
                                        ForEach(featuredArticles.prefix(3)) { article in
                                            ArticleFeaturedCard(article: article)
                                                .onTapGesture {
                                                    selectedArticle = article
                                                    HapticManager.shared.impact(.light)
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Regular Articles Section
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                            if !featuredArticles.isEmpty {
                                Text("Recent Articles")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.text)
                                    .padding(.horizontal)
                            }
                            
                            LazyVStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(articles.filter { article in
                                    !featuredArticles.contains(where: { $0.id == article.id })
                                }) { article in
                                    ArticleRowCard(article: article)
                                        .onTapGesture {
                                            selectedArticle = article
                                            HapticManager.shared.impact(.light)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Articles")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadArticles()
            }
            .sheet(item: $selectedArticle) { article in
                ArticleView(article: article)
            }
        }
        .task {
            await loadArticles()
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("No articles yet")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Long-form articles will appear here")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private func loadArticles() async {
        let ndk = appState.ndk
        
        let articleSource = ndk.subscribe(
            filter: NDKFilter(kinds: [30023]),
            maxAge: 300,
            cachePolicy: .cacheWithNetwork
        )
        
        for await event in articleSource.events {
            if let article = try? Article(from: event) {
                await MainActor.run {
                    if !articles.contains(where: { $0.id == article.id }) {
                        articles.append(article)
                        articles.sort { $0.createdAt > $1.createdAt }
                        
                        // Select featured articles (first 3 with images)
                        featuredArticles = articles
                            .filter { $0.image != nil }
                            .prefix(3)
                            .map { $0 }
                    }
                }
            }
        }
    }
}

#Preview {
    ArticleListView()
        .environmentObject(AppState())
}