<script lang="ts">
	import { inview } from 'svelte-inview';
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { layout } from "$stores/layout";
	import { getEventUrl } from "$utils/url";
	import { NDKHighlight, NDKEvent, NDKArticle, NDKList } from "@nostr-dev-kit/ndk";
	import { Readable } from "svelte/store";
	import { createEventDispatcher, getContext } from "svelte";
	import { NavigationOption } from "../../../app";
	import { Lightning, Plus, StackPlus } from "phosphor-svelte";

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

    const dispatch = createEventDispatcher();

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
            navigation.push({
                name: "Curations", badge: $curations.length.toString(), href: getEventUrl(event, authorUrl, "curations"),
                button: {
                    icon: StackPlus,
                    fn: () => dispatch("curate")
                }
            });
        }

        if ($shares.length > 0) {
            navigation.push({ name: "Shares", badge: $shares.length.toString(), href: getEventUrl(event, authorUrl, "shares") });
        }

        if ($zaps.length > 0) {
            navigation.push({ name: "Zaps", badge: $zaps.length.toString(), href: getEventUrl(event, authorUrl, "zaps"),
                // button: {
                //     icon: Lightning,
                //     fn: () => dispatch("zap"),
                //     iconProps: { weight: 'fill' }
                // }
            });
        }

        showToolbar = navigation.length > 0;

        if (pinToolbar && showToolbar) {
            $layout.navigation = navigation;
        } else {
            $layout.navigation = false;
        }
    }

    function inviewChange(e: CustomEvent<{ inview: boolean }>) {
        pinToolbar = !e.detail.inview;
    }
</script>

{#if showToolbar}
    <div use:inview on:inview_change={inviewChange}>
        <HorizontalOptionsList
            options={navigation}
            class="responsive-padding"
        />
    </div>
{/if}