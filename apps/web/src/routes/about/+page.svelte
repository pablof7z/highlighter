<script lang="ts">
	import Navbar from "$components/Navbar.svelte";
	import Logo from "$icons/Logo.svelte";

</script>

<svelte:head>
    <title>How Faaans is different</title>
</svelte:head>

<Navbar class="!bg-transparent fixed z-40 !backdrop-blur-[0px]" maxSize="" />

<div class="hero h-screen relative overflow-x-hidden overflow-y-auto" style="background-image: url(/images/landing-bg.jpg);">
	<div class="hero-overlay bg-black bg-opacity-80"></div>
	<div class="h-[517px] fixed left-0 w-full bottom-0 bg-gradient-to-b from-transparent to-black"></div>
	<div class="hero-content text-center text-neutral-content flex-col">
        <div class="w-full">
            <Logo class="w-64 h-64 inline-block" />
            <h1 class="mb-5 text-[calc(24px_+_5vw)] flex flex-col items-center">
                is different
            </h1>
            <p class="mb-5 text-white text-[calc(12px_+_1vw)]">
                Own the relationship with your fans
            </p>
        </div>

        <div class="max-w-prose w-full text-xl text-left flex flex-col gap-8">
            <p>Creators have been getting the short end of the stick for too long. We're here to change that.</p>
            <p>
                In the digital age, creators are often caught in a whirlwind of fragmented attention and effort. Social media platforms like YouTube, Twitter, and Medium demand constant engagement to attract followers. However, the real challenge lies in transitioning this audience to monetization platforms such as OnlyFans, Patreon, or Substack. This shift not only dilutes a creator's focus but also limits their creative freedom and reach.
            </p>
            <p>
                Enter Faaans, a revolutionary platform that redefines the creator-subscriber relationship. Built on the Nostr protocol, Faaans stands out by offering creators true ownership of their audience. Unlike traditional platforms, Faaans isn't just a service; it's an ecosystem where creators are in complete control.
            </p>
            <p>
                Complete Ownership: On Faaans, you're not just using a platform; you're part of a protocol. This means you have the freedom to manage your subscriber relationships directly. If you choose to leave Faaans, your audience goes with you, unshackled from the constraints of a singular platform.
            </p>
            <p>
                Censorship-Resistant: Leveraging the Nostr protocol, Faaans guarantees that your voice remains uncensored. You're not just a user; you're a participant in a decentralized network that values free expression above all.
            </p>
            <p>
                Seamless Integration with Social Media: Faaans changes the game by making your content immediately accessible across all social media clients. Your work isn't confined to a single platform; it resonates through the entire digital ecosystem.
            </p>
            <p>
                Organic Marketing Loops: Every action your paid subscribers take – be it liking, reposting, or commenting – becomes a natural marketing tool. For instance, when a subscriber highlights a section of your paid-only article, this highlight becomes instantly visible to their followers, organically expanding your reach.
            </p>

            <p>
                Enhanced Engagement: Every interaction on Faaans is an opportunity. Each like, repost, or comment doesn't just signify engagement; it's a potential catalyst for virality and audience growth.
            </p>

            <p>
                Faaans isn't just another platform; it's just one piece of a larger puzzle that is pushing the internet from a collection of rent-seeking siloes towards a movement for a new architecture for the internet where people engage with each other without intermediaries.
            </p>

            <p>
                A movement that puts creators first, respects their autonomy, and amplifies their voice across the digital landscape. By choosing Faaans, you're not just selecting a platform for content creation; you're embracing a future where your creative freedom and audience engagement know no bounds. Join Faaans, and experience the future of content creation and distribution – unfiltered, unrestricted, and unbound.
            </p>
        </div>
	</div>
</div>
