# Highlighter - Where Smart People Learn, Share & Grow

<div align="center">
  <img src="Resources/highlighter-icon.png" alt="Highlighter Logo" width="200"/>
  
  [![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)](https://developer.apple.com/ios/)
  [![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
  [![NDKSwift](https://img.shields.io/badge/NDKSwift-0.2.0-blue)](https://github.com/pablof7z/NDKSwift)
  [![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
</div>

## Overview

Highlighter is a revolutionary iOS application that transforms passive content consumption into active enlightenment. Built on the [Nostr protocol](https://nostr.com), it creates a social layer for intellectual content where users can highlight, curate, and share valuable insights from any source - articles, books, PDFs, videos, and more.

## Vision

Foster a global swarm of knowledge where value flows to those who illuminate the best ideas. Highlighter combines the best aspects of Reddit's intellectual communities, Kindle's highlighting features, and Notion's organizational capabilities - all within a decentralized, censorship-resistant architecture.

## Features

### 📖 Highlight Creation (NIP-84)
- **Universal Highlighting**: Create highlights from any text source - web articles, books, PDFs, EPUBs
- **Multimedia Support**: Highlight audio timestamps and video frames
- **Rich Context**: Add personal notes and insights to your highlights
- **Privacy Options**: Keep highlights private or broadcast to the community
- **Full Attribution**: Automatic tracking of original authors and sources

### 🧠 Swarm Intelligence
- **Visual Overlays**: See what the community finds valuable with heatmap visualizations
- **Popular Passages**: Discover the most highlighted content across sources
- **Community Insights**: View who highlighted what and why
- **Collective Learning**: Transform individual reading into shared intelligence

### 🔍 Smart Discovery
- **Hybrid Feed**: Innovative vertical and horizontal scrolling for optimal content consumption
- **Curated Content**: Highlights, articles, and discussions from people you follow
- **Trending Topics**: Surface valuable content through community engagement
- **Transparent Algorithm**: User-controlled content discovery with no hidden manipulation

### ⚡ Value-Enabled Ecosystem
- **Bitcoin Lightning Integration**: Direct micropayments ("zaps") to content creators
- **Smart Payment Splits**: Automatic distribution (e.g., 50% author, 30% highlighter, 20% curator)
- **Merit-Based Economy**: Quality insights are directly rewarded
- **Non-Custodial Wallet**: Full control over your funds

### 📚 Content Curation (NIP-51)
- **Themed Collections**: Create curated reading lists on any topic
- **Rich Metadata**: Beautiful covers, descriptions, and organization
- **Community Sharing**: Discover curated lists from thought leaders
- **Follow Packs**: Instantly follow curated sets of interesting people

### 🎨 Premium User Experience
- **Pixel-Perfect Design**: Obsessively polished interface with fluid animations
- **Haptic Feedback**: Delightful tactile responses throughout
- **Modern Card UI**: Beautiful card-based design with glassmorphic effects
- **Progressive Loading**: Never wait - content streams in as it arrives
- **Dark Mode**: Elegant dark theme optimized for reading

### 🔧 Advanced Features
- **Import/Export**: Sync highlights from Kindle and other platforms
- **Text-to-Speech**: Listen to content with optional sat-streaming
- **Offline Mode**: Access cached content without internet
- **Cross-Media**: Support for text, audio, and video content
- **AI Analysis**: Smart insights and connections between highlights

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/pablof7z/Highlighter.git
cd Highlighter
```

2. Install XcodeGen if you haven't already:
```bash
brew install xcodegen
```

3. Generate the Xcode project:
```bash
./refresh-project.sh
```

4. Open the project in Xcode:
```bash
open Highlighter.xcodeproj
```

5. Build and run the project on your device or simulator

### TestFlight

Coming soon! We'll be releasing Highlighter on TestFlight for beta testing.

## Development

### Building

```bash
# Refresh project after file changes
./refresh-project.sh

# Build with clean output
./build.sh

# Build for specific device
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro" ./build.sh
```

### Deploying to TestFlight

```bash
./deploy.sh
```

## Architecture

Highlighter is built using cutting-edge iOS technologies:

- **SwiftUI** for declarative UI
- **NDKSwift** for Nostr protocol integration
- **Core Data** for offline caching
- **Lightning SDK** for Bitcoin payments
- **Combine** for reactive programming
- **AVFoundation** for multimedia handling

## Use Cases

- **Researchers**: Share key findings from academic papers
- **Book Clubs**: Highlight and discuss passages together
- **Students**: Create collaborative study materials
- **Professionals**: Curate industry insights and trends
- **Writers**: Collect inspiration and references
- **Lifelong Learners**: Build a personal knowledge base

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] Browser extension for web highlighting
- [ ] iPad and Mac Catalyst support
- [ ] AI-powered highlight suggestions
- [ ] Collaborative annotation features
- [ ] Integration with popular reading apps
- [ ] Export to Obsidian/Notion/Roam
- [ ] Audio/video highlighting tools

## NIPs Implemented

- **NIP-01**: Basic protocol flow
- **NIP-84**: Highlights
- **NIP-51**: Lists and collections
- **NIP-57**: Lightning zaps
- **NIP-22**: Comment threads
- **NIP-92**: Media attachments

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [NDKSwift](https://github.com/pablof7z/NDKSwift)
- Uses the [Nostr Protocol](https://nostr.com)
- Lightning payments via [Breez SDK](https://breez.technology)
- Inspired by the best knowledge management tools

## Contact

- Nostr: `npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft`
- GitHub: [@pablof7z](https://github.com/pablof7z)

---

<div align="center">
  Made with 💡 for the future of collective intelligence
</div>