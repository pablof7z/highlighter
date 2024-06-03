<script lang="ts">
    import { Hexpubkey, NDKArticle, NDKHighlight, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { Name, ndk } from "@kind0/ui-common";
	import currentUser from "$stores/currentUser";
	import HighlightBody from "$components/HighlightBody.svelte";
	import { derived } from "svelte/store";

    export let article: NDKArticle;
    export let node: HTMLElement;

    const authors: Hexpubkey[] = [article.pubkey];

    if ($currentUser && $currentUser?.pubkey !== article.pubkey) {
        authors.push($currentUser.pubkey);
    }

    const relaySet = NDKRelaySet.fromRelayUrls(["wss://relay.highlighter.com"], $ndk);
    
    export let highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], authors, ...article.filter() },
        { subId: 'share-highlights', relaySet, closeOnEose: true },
        NDKHighlight
    );

    const selectedHighlight = derived(highlights, ($highlights) => {
        // skip short and long highlights
        $highlights = $highlights.filter(h => (
            h.content.length < 500 && h.content.length > 15
        ));

        // prefer highlights by the current user
        $highlights = $highlights.sort((a, b) => {
            if (a.pubkey === $currentUser?.pubkey) return -1;
            if (b.pubkey === $currentUser?.pubkey) return 1;
            return 0;
        });
        
        return $highlights[0];
    });

    let showHighlight = true;
</script>

<UserProfile user={article.author} let:userProfile>
    <div class="flex flex-row gap-4 relative w-full min-h-[max(30vh,10rem)] overflow-hidden bg-black" bind:this={node}>
        <img src={article.image ?? userProfile?.image} alt={article.title} class="h-full object-cover absolute top-0 left-0 bottom-0 right-0 z-1 w-full opacity-50" />

        <slot />

        <div class="w-full flex flex-col gap-2 z-2 absolute bottom-0 z-2">
            <div class="flex flex-col bg-black/70 p-4">
                {#if showHighlight}
                    <button class="group relative" on:click={() => showHighlight = !showHighlight}>
                        {#if $selectedHighlight}
                            <HighlightBody
                                highlight={$selectedHighlight}
                                skipArticle
                                class="mb-10 italic bg-base-100/50 rounded-box p-6"
                            />
                        {/if}

                        <span class="absolute top-0 right-0 text-xs hidden group-hover:inline">
                            Remove highlight from preview
                        </span>
                    </button>
                {/if}
                
                <h1 class="text-3xl font-semibold mb-1 font-serif max-h-24 overflow-clip">
                    {article.title}
                </h1>

                <div class="text-xs flex flex-row items-end max-h-12 overflow-clip">
                    <Name user={article.author} avatarType="square" avatarSize="small" class="text-accent2" />
                </div>

                {#if article.summary}
                    <div class="text-lg max-h-12  overflow-clip">
                        {article.summary}
                    </div>
                {/if}
            </div>
        </div>
    </div>
</UserProfile>
