import Foundation

/// Provides realistic preview data for SwiftUI previews
enum PreviewData {
    // MARK: - Articles
    static let articleURLs = [
        "https://example.com/article/decentralized-networks",
        "https://example.com/article/bitcoin-lightning",
        "https://example.com/article/digital-publishing",
        "https://example.com/article/ai-content-creation",
        "https://example.com/article/privacy-social-media",
        "https://example.com/article/reading-experiences",
        "https://example.com/article/information-retention"
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
    
    // Profile pictures are now generated dynamically using initials
    // See AsyncProfileImage for implementation
    
    // Article images are now generated using gradient placeholders
    // See ArticleImageView for implementation
    
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
    
}