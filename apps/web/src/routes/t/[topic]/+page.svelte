<script lang="ts">
	import { page } from '$app/stores';
	import TopicPage from '$views/TopicPage.svelte';
    let topic: string;

    $: topic = decodeURIComponent($page.params.topic);
</script>

{#if topic}
    {#key topic}
        <TopicPage {topic} />
    {/key}
{/if}