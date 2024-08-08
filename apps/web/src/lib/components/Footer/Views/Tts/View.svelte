<script lang="ts">
	import Tts from "$components/Actions/TTS/TTS.svelte";
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    export let article: NDKArticle;
</script>

<Tts
    event={article}
/>