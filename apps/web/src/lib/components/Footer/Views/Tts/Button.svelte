<script lang="ts">
	import ReaderButton from "$components/Event/Article/ReaderButton.svelte";
	import { OpenFn } from "$components/Footer";
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    export let open: OpenFn;
    export let article: NDKArticle;
</script>

<ReaderButton
    {article}
    variant="outline"
    class="rounded w-[38px] h-[38px] p-0 flex-none"
    onShow={() => open('tts')}
/>