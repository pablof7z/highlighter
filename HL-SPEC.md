# Highlighter iOS App - Extended Product Specification & Implementation Plan

## Product Specification (Expanded)

### 1. Overview and Value Proposition

Highlighter is a premium iOS application for intellectual discovery and knowledge sharing, built on the Nostr protocol with NIP-84 (kind:9802) for highlights and NIP-51 for advanced curation and social features. It empowers users to become smarter in their downtime by curating a dynamic mix of insightful content, from highlights and quotes to community discussions, personalized recommendations, article curations, and shared follow packs. The app draws from decentralized sources, ensuring censorship resistance and user ownership, while integrating Bitcoin Lightning zaps for value flows. Every interaction is designed with pixel-perfect precision to wow users, delivering an extremely polished UI that feels luxurious and intuitive from the first tap.

**Target Audience**: Intellectuals, lifelong learners, researchers, writers, and professionals aged 18-45 who value depth over distraction. Think: Reddit's r/books users, Kindle enthusiasts, or Notion power-users seeking a social layer.

**Unique Selling Points**:
- **Decentralized and censorship-resistant via Nostr**: No central authority controls content; users own their data and identities.
- **Hybrid home screen**: A modern blend of vertical and horizontal scrolling for a functional mix of content types, rendered with flawless animations and responsive layouts to captivate and delight.
- **Swarm intelligence**: Public highlights overlay on original content, showing what the community finds valuable (e.g., "swarm highlights" visualizing popular passages) in a visually stunning, interactive display.
- **Value-enabled**: Seamless zaps (micro-payments in sats) for appreciating highlights, with automatic splits to authors, curators, and highlighters, accompanied by elegant haptic feedback and ripple effects.
- **Cross-media support**: Highlights from text, audio (timestamps), video (frame references), and more, all presented with high-fidelity thumbnails and smooth playback.
- **Article Curations**: Effortless creation and sharing of themed collections (NIP-51 kind:30004) with titles, descriptions, and images, making organization feel magical and polished.
- **Follow Packs**: Shareable sets of profiles (NIP-51 kind:39089) with names, titles, and images, integrated into onboarding for instant community building in a seamless, wow-inducing flow.

**Mission Statement**: Highlighter is where smart people flock to learn, share, and grow. It turns passive consumption into active enlightenment, fostering a global swarm of knowledge where value flows to those who illuminate the best ideas, all within an app that pursues pixel perfection to wow users at every turn.

### 2. Ethos, Feel, and Aesthetics

**Ethos**:
- **Intellectual Empowerment**: Prioritize depth, curiosity, and community-driven curation over virality. Encourage users to "highlight the highlights" of human knowledge, inspired by concepts like purple text (Nostr's open information flow) and orange highlights (Bitcoin's value-enabled interactions).
- **Decentralization and Ownership**: Built on Nostr, users control their private keys, data, and feeds. No ads, no data mining—pure, user-sovereign experience.
- **Value for Value**: Integrate Lightning Network for zaps, promoting a merit-based economy where quality content and insights are rewarded directly.
- **Inclusivity with Excellence**: Open to all, but curated for quality. Foster respectful discourse, with tools to filter noise and amplify signal.
- **Sustainability**: Eco-friendly (low-energy Nostr relays), privacy-first, and focused on long-term user retention through genuine value.

**Feel**:
- **Modern and functional**—intuitive navigation with seamless transitions between vertical and horizontal elements. Scrolling is responsive and purposeful, with haptics for delight (e.g., subtle vibration on section switches). Users feel productive, not addicted, emerging with new insights, all wrapped in an extremely polished UI that chases pixel perfection to wow at every interaction.
- **Serene and focused**: No overwhelming notifications; users feel in control, emerging refreshed and enlightened, thanks to meticulously crafted animations and layouts.

**Aesthetics**:
- **Color Palette**: Primary: Deep purple (#6A1B9A) for Nostr-inspired elements (e.g., highlights, buttons). Accent: Warm orange (#FF9500) for value flows (zaps, rewards). Neutrals: Soft grays (#F5F5F5 background), black text for readability, with optional dark mode (midnight blue accents)—all rendered with razor-sharp clarity.
- **Typography**: Elegant sans-serif (e.g., Inter or SF Pro) for body text, with serif (e.g., Georgia) for highlighted quotes to evoke classic literature. Large, readable fonts with generous line spacing, optimized for pixel-perfect legibility across devices.
- **UI Style**: Minimalist, card-based design with rounded corners and subtle shadows. Highlights appear as glowing orange-bordered cards in the feed. Animations: Fluid swipes, fade-ins for context overlays, and a "ripple" effect when sharing or zapping. Enhanced for hybrid layouts—cards with variable heights/widths for mixed content, all executed with an extremely polished finish to wow users.
- **Icons and Imagery**: Clean line icons (e.g., a highlighter pen for creating, a lightbulb for discoveries). No stock photos; user-generated thumbnails from highlighted media (blurred for non-images), displayed with high-resolution precision.
- **Overall Vibe**: Sleek like Notion's dashboard meets Spotify's personalized feeds—clean, modular, and adaptable to user preferences (e.g., customizable section order), but elevated by chasing pixel perfection in every detail to create a truly wowing experience.

### 3. Core Features

#### 3.1 Highlight Creation (NIP-84)
- **Text Selection**: Intuitive text selection from any source (imported articles, books via EPUB/PDF, web URLs, or in-app browser)
- **Rich Context**: Add context (surrounding text via `context` tag), attribution (`p` tags for authors), and source (`r` for URLs, `e`/`a` for Nostr events)
- **Personal Notes**: Optional comment tag for quote highlights
- **Privacy Options**: Private (local-only) or public (broadcast to relays)
- **Media Support**: Timestamp audio/video highlights with thumbnails—all presented in a sleek, pixel-perfect editor interface

#### 3.2 Content Types
- **Highlights/Quotes**: NIP-84 events (kind:9802)—text snippets with context, attributions
- **Articles Liked/Zapped by Others**: Aggregated from follows' zaps/likes on sources
- **Old Articles We Liked**: Personalized history—user's past zaps, saves, or interactions resurfaced
- **Kind:1 Discussions**: Nostr notes (kind:1) tagged #bookstr, filtered for book-related threads

#### 3.3 Discovery Feed
- **Hybrid Layout**: Vertical main scroll with embedded horizontal carousels for variety, animated with buttery-smooth transitions
- **Transparent Algorithm**: User-controlled—prioritize follows, zaps, and tags; mix serendipity with personalization
- **Card Design**: Highlight text in bold orange, source/author below, engagement metrics
- **Smart Filters**: By topic, source type, or user, accessible via a polished, intuitive sidebar

#### 3.4 Swarm Highlights Overlay
- **Community Intelligence**: When viewing full content, overlay public highlights from the community
- **Visual Heatmaps**: Orange underlines with popularity heatmaps (darker for more zaps/highlights)
- **Interactive Elements**: Tap to see who highlighted, their notes, and zap them, with haptic feedback

#### 3.5 Social Interactions
- **Zapping**: Send sats directly to highlighters/authors with auto-splits via Lightning Prisms
- **Discussions**: Create threaded discussions on highlights using Nostr replies
- **Following**: Follow users for their highlight feeds; create/share collections
- **Follow Packs**: Support NIP-51 kind 39089—named sets of profiles with name, title, and image

#### 3.6 Article Curations (NIP-51 kind:30004)
- **Easy Creation**: Drag-and-drop or one-tap addition from feeds
- **Rich Metadata**: Title, description, and cover image for each curation
- **Profile Integration**: Displayed prominently in profiles and discoverable in feeds
- **Sharing**: Beautiful preview cards when sharing curations

#### 3.7 Value Flows
- **Lightning Integration**: Non-custodial wallet via Nostr Wallet Connect
- **Smart Splits**: Auto-split zaps (e.g., 50% author, 30% highlighter, 20% curator)
- **Premium Features**: Optional in-app purchases for advanced tools

#### 3.8 Additional Tools
- **Text-to-Speech**: Read highlights aloud with optional sat-streaming
- **Import/Export**: Seamless from Kindle, web clippers, or PDFs
- **Offline Mode**: Cache feeds/highlights for reading without internet

### 4. Technical Architecture

#### 4.1 Project Structure
```
Examples/Apps/Highlighter/
├── Highlighter.xcodeproj/
├── Sources/
│   └── Highlighter/
│       ├── App/
│       │   ├── HighlighterApp.swift
│       │   └── Info.plist
│       ├── Models/
│       │   ├── HighlightEvent.swift
│       │   ├── ArticleCuration.swift
│       │   ├── FollowPack.swift
│       │   └── AppState.swift
│       ├── Views/
│       │   ├── ContentView.swift
│       │   ├── Home/
│       │   │   ├── HomeView.swift
│       │   │   ├── HybridFeedView.swift
│       │   │   └── SectionCarousel.swift
│       │   ├── Highlights/
│       │   │   ├── HighlightCreator.swift
│       │   │   ├── HighlightCard.swift
│       │   │   └── SwarmOverlay.swift
│       │   ├── Profile/
│       │   │   ├── ProfileView.swift
│       │   │   ├── ArticlesView.swift
│       │   │   └── CurationsView.swift
│       │   ├── Discovery/
│       │   │   ├── SearchView.swift
│       │   │   └── DiscoverView.swift
│       │   ├── Library/
│       │   │   └── LibraryView.swift
│       │   └── Components/
│       │       ├── ZapButton.swift
│       │       ├── HighlightEditor.swift
│       │       └── SharedStyles.swift
│       ├── Services/
│       │   ├── NostrService.swift
│       │   ├── HighlightService.swift
│       │   ├── LightningService.swift
│       │   └── ContentImporter.swift
│       └── Utils/
│           ├── Extensions.swift
│           └── Constants.swift
├── Resources/
│   └── Assets.xcassets/
└── project.yml
```

#### 4.2 Core Technologies
- **UI Framework**: SwiftUI for native iOS feel with pixel-perfect components
- **Nostr Integration**: NDKSwift for all Nostr operations
- **Lightning**: Breez SDK or similar for non-custodial wallet
- **Storage**: Core Data for offline caching
- **Media**: AVFoundation for audio/video timestamps

#### 4.3 Nostr Event Types
- **kind:9802**: Highlights (NIP-84)
- **kind:1**: Text notes for discussions (#bookstr)
- **kind:30004**: Article curations (NIP-51)
- **kind:39089**: Follow packs (NIP-51)
- **kind:9735**: Zap receipts
- **kind:10002**: Relay list

### 5. Implementation Plan

#### Phase 1: Foundation (Week 1-2)
1. **Project Setup**
   - Create Xcode project structure
   - Configure project.yml for xcodegen
   - Set up NDKSwift integration
   - Configure build system for iOS-only target

2. **Core Models**
   - Implement HighlightEvent model (NIP-84)
   - Create ArticleCuration model (NIP-51 kind:30004)
   - Design FollowPack model (NIP-51 kind:39089)
   - Set up AppState with @Observable

3. **Basic UI Shell**
   - Tab navigation structure
   - Basic view placeholders
   - Theme and styling system
   - Pixel-perfect component library

#### Phase 2: Nostr Integration (Week 3-4)
1. **Authentication**
   - Key generation/import
   - Secure storage with Keychain
   - Profile creation flow

2. **Event Handling**
   - Highlight creation and broadcasting
   - Event fetching and caching
   - Relay management

3. **Social Features**
   - Following system
   - Reply threading
   - Basic zapping

#### Phase 3: Core Features (Week 5-6)
1. **Highlight Creation**
   - Text selection interface
   - Context capture
   - Media timestamp support
   - Pixel-perfect editor UI

2. **Discovery Feed**
   - Hybrid vertical/horizontal layout
   - Card components with animations
   - Pull-to-refresh
   - Infinite scroll

3. **Swarm Overlays**
   - Highlight aggregation
   - Heatmap visualization
   - Interactive popups

#### Phase 4: Advanced Features (Week 7-8)
1. **Article Curations**
   - Creation interface
   - Management tools
   - Sharing mechanisms

2. **Follow Packs**
   - Import/export UI
   - Onboarding integration
   - Discovery features

3. **Lightning Integration**
   - Wallet setup
   - Zap flows
   - Split payments

#### Phase 5: Polish & Launch (Week 9-10)
1. **UI Refinement**
   - Animation tuning
   - Haptic feedback
   - Performance optimization

2. **Testing**
   - Unit tests for core logic
   - UI tests for critical flows
   - Beta testing program

3. **App Store Preparation**
   - Screenshots and preview
   - App Store description
   - Compliance review

### 6. Success Metrics

- **User Engagement**: Daily active users, time spent in app
- **Content Creation**: Highlights created per user per week
- **Social Activity**: Zaps sent, discussions started
- **Retention**: 7-day and 30-day retention rates
- **Value Flow**: Total sats transacted through the platform

### 7. Future Roadmap

**v1.1**: Audio/video highlight improvements, AI-powered discovery
**v1.2**: Web content import, browser extension
**v2.0**: iPad optimization, collaborative curations
**Long-term**: AR highlighting, voice interfaces, cross-platform sync

## Implementation Notes

### Key Design Principles
1. **Pixel Perfection**: Every UI element must be precisely aligned and animated
2. **User Delight**: Subtle animations and haptics that wow without overwhelming
3. **Performance First**: Smooth 60fps scrolling even with complex layouts
4. **Accessibility**: Full VoiceOver support and Dynamic Type compliance

### Technical Considerations
1. Use NDKSwift directly without unnecessary wrappers
2. Implement proper error handling for offline scenarios
3. Optimize relay queries to minimize bandwidth
4. Cache aggressively for instant UI responses

### Testing Strategy
1. Unit tests for all Nostr event creation/parsing
2. UI tests for critical user flows
3. Performance profiling for scroll performance
4. Beta testing with bookstr community

This specification will guide the development of Highlighter as a premium iOS application that showcases the best of Nostr's decentralized knowledge-sharing capabilities while delivering an extremely polished user experience that consistently wows users.