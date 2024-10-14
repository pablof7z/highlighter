<script lang="ts">
    import Highlight from '$components/Highlight.svelte';
	import ReplyAvatars from "$components/Feed/ReplyAvatars.svelte";
	import { NDKHighlight } from '@nostr-dev-kit/ndk';

    export let highlightId: string;
    export let text: string;
    export let pubkeys: string[];
    export let highlight: NDKHighlight;

    text = text.replace(/\[mark data-highlight-id="[^"]+"\]/g, '').replace(/\[\/mark\]/g, '');

    let opened = false;
    
    function clicked() {
        opened = !opened;
    }
</script>

{#if opened}
    <div class="font-sans">
        <Highlight
            {highlight}
            skipArticle
            on:close={clicked}
        />
    </div>
{:else}
    <mark data-highlight-id={highlightId}>
        <div class="inline absolute right-0 translate-x-[2rem]">
            <ReplyAvatars users={pubkeys} size="small" />
        </div>
        <slot />
    </mark>
{/if}