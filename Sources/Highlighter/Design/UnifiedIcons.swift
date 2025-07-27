import SwiftUI

// MARK: - Unified Icon System
// Single source of truth for all icons used in the app

struct UnifiedIcons {
    
    // MARK: - Feature Icons
    struct Features {
        static let highlights = "pencil.tip"
        static let curations = "books.vertical"
        static let articles = "doc.text"
        static let archive = "archivebox"
        static let activity = "bolt.heart"
        static let profile = "person.circle"
        static let settings = "gearshape"
        static let search = "magnifyingglass"
        static let add = "plus.circle.fill"
        static let more = "ellipsis.circle"
    }
    
    // MARK: - Navigation Icons
    struct Navigation {
        static let back = "chevron.left"
        static let forward = "chevron.right"
        static let up = "chevron.up"
        static let down = "chevron.down"
        static let close = "xmark"
    }
    
    // MARK: - Action Icons
    struct Actions {
        static let share = "square.and.arrow.up"
        static let copy = "doc.on.doc"
        static let delete = "trash"
        static let edit = "pencil"
        static let save = "bookmark"
        static let saved = "bookmark.fill"
        static let favorite = "heart"
        static let favorited = "heart.fill"
        static let zap = "bolt"
        static let zapped = "bolt.fill"
        static let reply = "bubble.left"
        static let repost = "arrow.2.squarepath"
    }
    
    // MARK: - Status Icons
    struct Status {
        static let success = "checkmark.circle.fill"
        static let error = "exclamationmark.circle.fill"
        static let warning = "exclamationmark.triangle.fill"
        static let info = "info.circle.fill"
        static let loading = "arrow.clockwise"
        static let verified = "checkmark.seal.fill"
    }
    
    // MARK: - Social Icons
    struct Social {
        static let followers = "person.2"
        static let following = "person.2"
        static let person = "person.circle.fill"
        static let group = "person.3"
        static let addPerson = "person.badge.plus"
        static let removePerson = "person.badge.minus"
    }
    
    // MARK: - Content Icons
    struct Content {
        static let link = "link"
        static let image = "photo"
        static let video = "play.rectangle"
        static let audio = "speaker.wave.2"
        static let quote = "quote.bubble"
        static let tag = "tag"
        static let folder = "folder"
        static let folderAdd = "folder.badge.plus"
    }
    
    // MARK: - Tab Bar Icons
    struct TabBar {
        static let home = "house"
        static let homeSelected = "house.fill"
        static let discover = "safari"
        static let discoverSelected = "safari.fill"
        static let library = "books.vertical"
        static let librarySelected = "books.vertical.fill"
        static let profile = "person.circle"
        static let profileSelected = "person.circle.fill"
    }
}

// MARK: - Icon Helper Functions

extension Image {
    static func icon(_ name: String, size: CGFloat = 16, weight: Font.Weight = .medium) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight)
            .symbolRenderingMode(.hierarchical)
    }
}

// MARK: - Unified Icon View

struct UnifiedIcon: View {
    let name: String
    var size: CGFloat = 16
    var weight: Font.Weight = .medium
    var color: Color = .ds.text
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight)
            .foregroundColor(color)
            .symbolRenderingMode(.hierarchical)
    }
}