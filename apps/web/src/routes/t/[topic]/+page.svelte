<script lang="ts">
	import { page } from '$app/stores';
	import TopicPage from '$views/TopicPage.svelte';
    let topic: string;

    $: topic = $page.params.topic;
</script>

{#if topic}
    <TopicPage {topic} />
{/if}