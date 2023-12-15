<script lang="ts">
	import { isYoutube, youtubeIdFromUrl } from "$utils/media";
    import 'vidstack/player/styles/default/theme.css';
    import 'vidstack/player/styles/default/layouts/video.css';
    import 'vidstack/player';
    import 'vidstack/player/layouts';
    import 'vidstack/player/ui';
	import type { MediaProviderElement } from "vidstack/elements";
	import { onMount } from "svelte";

    export let url: string;
    export let title: string | undefined = undefined;

    let src= url;

    if (isYoutube(url)) {
        src = `youtube/${youtubeIdFromUrl(url)}`;
    }

    let isLoading = false;

    function handleLoadStart() {
        isLoading = true;
    }

    function handleLoadedData() {
        isLoading = false;
    }
</script>

<media-player
    {title}
    {src}
>
    <media-provider></media-provider>
    <media-video-layout></media-video-layout>
</media-player>