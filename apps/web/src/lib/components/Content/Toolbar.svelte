<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { layout } from "$stores/layout";
	import { getEventUrl } from "$utils/url";
	import { NDKHighlight, NDKEvent, NDKArticle, NDKList } from "@nostr-dev-kit/ndk";
	import { Readable } from "svelte/store";
	import { getContext } from "svelte";
	import { NavigationOption } from "../../../app";

    export let event: NDKEvent;
    export let authorUrl: string | undefined = undefined;
    export let navOptions: NavigationOption[] = [];
    
    export let navigation: NavigationOption[] = [];

    export let commentsUrl: string | undefined = "comments";

    const highlights = getContext("highlights") as Readable<NDKHighlight[]>;
    const curations = getContext("curations") as Readable<NDKList[]>;
    const replies = getContext("replies") as Readable<NDKEvent[]>;
    const shares = getContext("shares") as Readable<NDKEvent[]>;
    const zaps = getContext("zaps") as Readable<NDKEvent[]>;

    export let showToolbar = false;
    let pinToolbar = false;

    $: {
        navigation = [
            ...navOptions
        ];

        if ($replies.length > 0) {
            navigation.push({ name: "Comments", badge: $replies.length.toString(), href: getEventUrl(event, authorUrl, commentsUrl) });
        }

        if ($highlights.length > 0) {
            navigation.push({ name: "Highlights", badge: $highlights.length.toString(), href: getEventUrl(event, authorUrl, "highlights") });
        }

        if ($curations.length > 0) {
            navigation.push({ name: "Curations", badge: $curations.length.toString(), href: getEventUrl(event, authorUrl, "curations") });
        }

        if ($shares.length > 0) {
            navigation.push({ name: "Shares", badge: $shares.length.toString(), href: getEventUrl(event, authorUrl, "shares") });
        }

        if ($zaps.length > 0) {
            navigation.push({ name: "Zaps", badge: $zaps.length.toString(), href: getEventUrl(event, authorUrl, "zaps") });
        }

        showToolbar = navigation.length > 0;

        if (pinToolbar && showToolbar) {
            $layout.navigation = navigation;
        } else {
            $layout.navigation = false;
        }
    }
</script>

{#if showToolbar}
    <HorizontalOptionsList
        options={navigation}
        class="responsive-padding"
    />
{/if}