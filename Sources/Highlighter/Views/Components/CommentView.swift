import SwiftUI
import NDKSwift

struct CommentView: View {
    let comment: Comment
    let authorProfile: NDKUserProfile?
    let isReply: Bool
    let onReply: () -> Void
    let onLike: () -> Void
    let onDelete: (() -> Void)?
    let onAuthorTap: () -> Void
    
    @State private var showOptions = false
    @State private var likeScale: CGFloat = 1.0
    
    init(
        comment: Comment,
        authorProfile: NDKUserProfile? = nil,
        onReply: @escaping () -> Void,
        onLike: @escaping () -> Void,
        onDelete: (() -> Void)? = nil,
        onAuthorTap: @escaping () -> Void
    ) {
        self.comment = comment
        self.authorProfile = authorProfile
        self.isReply = comment.isReply
        self.onReply = onReply
        self.onLike = onLike
        self.onDelete = onDelete
        self.onAuthorTap = onAuthorTap
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: .ds.base) {
            // Reply indicator
            if isReply {
                Rectangle()
                    .fill(DesignSystem.Colors.divider)
                    .frame(width: 2)
                    .padding(.leading, 20)
            }
            
            // Author avatar
            Button(action: onAuthorTap) {
                AuthorAvatar(
                    pubkey: comment.author,
                    profile: authorProfile,
                    size: isReply ? 32 : 40
                )
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: .ds.small) {
                // Header
                HStack(alignment: .center, spacing: .ds.small) {
                    Button(action: onAuthorTap) {
                        Text(displayName)
                            .font(isReply ? .ds.footnoteMedium : .ds.bodyMedium)
                            .foregroundColor(.ds.text)
                    }
                    .buttonStyle(.plain)
                    
                    Text("·")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                    
                    Text(comment.formattedTime)
                        .font(.ds.caption)
                        .foregroundColor(.ds.textTertiary)
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Menu {
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.ds.textTertiary)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
                // Content
                Text(comment.content)
                    .font(isReply ? .ds.callout : .ds.body)
                    .foregroundColor(.ds.text)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Actions
                HStack(spacing: .ds.large) {
                    // Like button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            likeScale = 1.2
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                likeScale = 1.0
                            }
                        }
                        onLike()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(comment.isLiked ? .red : .ds.textTertiary)
                                .scaleEffect(likeScale)
                            
                            if comment.likes > 0 {
                                Text("\(comment.likes)")
                                    .font(.ds.caption)
                                    .foregroundColor(.ds.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // Reply button
                    Button(action: onReply) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrowshape.turn.up.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.ds.textTertiary)
                            
                            Text("Reply")
                                .font(.ds.caption)
                                .foregroundColor(.ds.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.top, .ds.micro)
            }
        }
        .padding(.vertical, .ds.small)
        .padding(.horizontal, .ds.screenPadding)
        .contentShape(Rectangle())
    }
    
    private var displayName: String {
        if let profile = authorProfile {
            return profile.displayName ?? profile.name ?? PubkeyFormatter.formatShort(comment.author)
        }
        return PubkeyFormatter.formatShort(comment.author)
    }
}

// MARK: - Author Avatar

struct AuthorAvatar: View {
    let pubkey: String
    let profile: NDKUserProfile?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let picture = profile?.picture, let url = URL(string: picture) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        placeholderAvatar
                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else {
                placeholderAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(DesignSystem.Colors.border, lineWidth: 0.5)
        )
    }
    
    private var placeholderAvatar: some View {
        AvatarUtilities.placeholderAvatar(
            pubkey: pubkey,
            size: size,
            fontSize: size * 0.45
        )
    }
    
    private var avatarInitial: String {
        if let profile = profile {
            let name = profile.displayName ?? profile.name ?? "?"
            return String(name.prefix(1)).uppercased()
        }
        return AvatarUtilities.generateInitials(from: pubkey)
    }
}

// MARK: - Comments Section


// MARK: - Supporting Views

struct LoadingCommentsView: View {
    @State private var shimmer = false
    
    var body: some View {
        VStack(spacing: .ds.base) {
            ForEach(0..<3) { _ in
                HStack(alignment: .top, spacing: .ds.base) {
                    Circle()
                        .fill(DesignSystem.Colors.surfaceSecondary)
                        .frame(width: 40, height: 40)
                        .opacity(shimmer ? 1 : 0.7)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: shimmer)
                    
                    VStack(alignment: .leading, spacing: .ds.small) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                            .frame(width: 120, height: 14)
                            .opacity(shimmer ? 1 : 0.7)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: shimmer)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignSystem.Colors.surfaceSecondary)
                            .frame(width: 200, height: 12)
                            .opacity(shimmer ? 1 : 0.7)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: shimmer)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, .ds.screenPadding)
                .padding(.vertical, .ds.small)
            }
        }
        .onAppear {
            shimmer = true
        }
    }
}


struct CommentInputField: View {
    @Binding var text: String
    let replyingTo: Comment?
    let isLoading: Bool
    let onCancel: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: .ds.small) {
            if let replyingTo = replyingTo {
                HStack {
                    Text("Replying to @\(PubkeyFormatter.formatShort(replyingTo.author))")
                        .font(.ds.caption)
                        .foregroundColor(.ds.textSecondary)
                    
                    Spacer()
                    
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.ds.textTertiary)
                    }
                }
                .padding(.horizontal, .ds.screenPadding)
                .padding(.top, .ds.small)
            }
            
            HStack(alignment: .bottom, spacing: .ds.base) {
                TextField("Add a comment...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .padding(.ds.base)
                    .background(
                        RoundedRectangle(cornerRadius: .ds.medium)
                            .fill(DesignSystem.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: .ds.medium)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                    )
                
                Button(action: onSubmit) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                text.isEmpty ? Color.ds.textTertiary : Color.ds.primary
                            )
                    }
                }
                .disabled(text.isEmpty || isLoading)
            }
            .padding(.horizontal, .ds.screenPadding)
            .padding(.vertical, .ds.base)
            .background(DesignSystem.Colors.surfaceSecondary)
        }
    }
}


