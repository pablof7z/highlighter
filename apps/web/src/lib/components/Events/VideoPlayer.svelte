<script lang="ts">
	import { isYoutube, youtubeIdFromUrl } from "$utils/media";

    export let url: string;
</script>

{#if isYoutube(url)}
    <iframe
        class="w-full h-full object-cover rounded-xl top-0 left-0"
        src="https://www.youtube.com/embed/{youtubeIdFromUrl(url)}"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
    />
{:else}
    <video src={url} class="w-full h-full object-cover rounded-xl top-0 left-0"
        controls={true}
    />
{/if}