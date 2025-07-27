import Foundation

/// Provides realistic preview data for SwiftUI previews
enum PreviewData {
    // MARK: - Articles
    static let articleURLs = [
        "https://arstechnica.com/gadgets/2024/03/hands-on-with-the-vision-pro/",
        "https://www.theverge.com/2024/2/28/ai-search-revolution-perplexity/",
        "https://www.wired.com/story/bitcoin-lightning-network-micropayments/",
        "https://stratechery.com/2024/the-ai-platform-shift/",
        "https://www.newyorker.com/magazine/2024/03/04/the-age-of-ai-writing/",
        "https://www.technologyreview.com/2024/03/01/quantum-computing-breakthrough/",
        "https://www.fastcompany.com/90987654/future-of-remote-work-2024/"
    ]
    
    static let articleTitles = [
        "The Evolution of Decentralized Networks: A Deep Dive",
        "Understanding Bitcoin's Lightning Network",
        "The Future of Digital Publishing",
        "How AI is Transforming Content Creation",
        "Privacy in the Age of Social Media",
        "Building Better Reading Experiences",
        "The Science of Information Retention"
    ]
    
    static let articleSummaries = [
        "An in-depth exploration of how decentralized networks are reshaping the internet, examining both technical innovations and social implications.",
        "Lightning Network enables instant Bitcoin transactions with minimal fees, opening new possibilities for micropayments and everyday commerce.",
        "Digital publishing is undergoing a renaissance as new platforms emerge that prioritize reader experience and creator monetization.",
        "Artificial intelligence tools are augmenting human creativity, helping writers overcome blocks and explore new narrative possibilities.",
        "As data collection becomes ubiquitous, individuals and organizations grapple with balancing convenience and privacy protection.",
        "Modern reading apps leverage cognitive science to improve comprehension and retention through better typography and interaction design.",
        "Research reveals how our brains process and store information, leading to new techniques for effective learning and memory."
    ]
    
    // MARK: - Highlights
    static let highlightTexts = [
        "The most profound technologies are those that disappear. They weave themselves into the fabric of everyday life until they are indistinguishable from it.",
        "In a decentralized system, trust is not eliminated but rather distributed across the network, creating resilience through redundancy.",
        "The future of money is not just digital—it's programmable, permissionless, and fundamentally reimagines value exchange.",
        "Reading is not passive consumption but active construction of meaning, where reader and text collaborate to create understanding.",
        "Privacy is not about hiding wrongdoing; it's about maintaining the autonomy to selectively reveal oneself to the world.",
        "The best interface is no interface—technology should empower without demanding constant attention or interaction.",
        "Knowledge work is not about time spent but value created; the industrial model of productivity doesn't apply to creative endeavors."
    ]
    
    static let highlightContexts = [
        "From 'The Invisible Computer' discussing ubiquitous computing",
        "Analyzing Byzantine Fault Tolerance in distributed systems",
        "Exploring the implications of programmable money",
        "On the phenomenology of reading and interpretation",
        "Privacy as a fundamental human right in digital spaces",
        "Design principles for ambient computing environments",
        "Rethinking productivity in the knowledge economy"
    ]
    
    // MARK: - Authors
    static let authorNames = [
        "Alexandra Chen",
        "Marcus Thompson",
        "Dr. Sarah Williams",
        "James Rodriguez",
        "Emma Nakamura",
        "Prof. David Kumar",
        "Lisa Anderson"
    ]
    
    static let authorBios = [
        "Technology writer and researcher focusing on decentralized systems and cryptography.",
        "Senior editor at Tech Quarterly, covering emerging technologies and their societal impact.",
        "Neuroscientist studying how digital media affects cognition and learning.",
        "Financial technology expert and author of 'The Future of Money'.",
        "Privacy advocate and cybersecurity researcher at Stanford University.",
        "Interaction designer pioneering ambient computing interfaces.",
        "Organizational psychologist reimagining work in the digital age."
    ]
    
    static let profilePictures = [
        "https://i.pravatar.cc/150?u=alexandra",
        "https://i.pravatar.cc/150?u=marcus",
        "https://i.pravatar.cc/150?u=sarah",
        "https://i.pravatar.cc/150?u=james",
        "https://i.pravatar.cc/150?u=emma",
        "https://i.pravatar.cc/150?u=david",
        "https://i.pravatar.cc/150?u=lisa"
    ]
    
    // MARK: - Images
    static let articleImages = [
        "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1563986768494-4dee2763ff3f?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1512428559087-560fa5ceab42?w=800&h=600&fit=crop",
        "https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?w=800&h=600&fit=crop"
    ]
    
    // MARK: - Curations
    static let curationNames = [
        "essential-readings",
        "bitcoin-lightning",
        "privacy-first",
        "ai-creativity",
        "future-of-work",
        "digital-wellness",
        "decentralized-web"
    ]
    
    static let curationTitles = [
        "Essential Readings on Digital Philosophy",
        "Understanding Bitcoin's Lightning Network",
        "Privacy-First Technology Guide",
        "AI and Human Creativity",
        "The Future of Remote Work",
        "Digital Wellness and Mindful Tech",
        "Building the Decentralized Web"
    ]
    
    static let curationDescriptions = [
        "A curated collection of foundational texts exploring how technology shapes human experience and society.",
        "Deep dives into Lightning Network technology, from basic concepts to advanced implementations.",
        "Resources for maintaining privacy and security in an increasingly connected world.",
        "Exploring the intersection of artificial intelligence and human creative expression.",
        "Insights on remote work, distributed teams, and the evolution of workplace culture.",
        "Strategies for maintaining balance and wellbeing in our relationship with technology.",
        "Technical and philosophical perspectives on building a more open and resilient internet."
    ]
    
    // MARK: - Helper Methods
    static func randomArticleURL() -> String {
        articleURLs.randomElement() ?? articleURLs[0]
    }
    
    static func randomHighlight() -> String {
        highlightTexts.randomElement() ?? highlightTexts[0]
    }
    
    static func randomAuthorName() -> String {
        authorNames.randomElement() ?? authorNames[0]
    }
    
    static func randomProfilePicture() -> String {
        profilePictures.randomElement() ?? profilePictures[0]
    }
    
    static func randomArticleImage() -> String {
        articleImages.randomElement() ?? articleImages[0]
    }
}