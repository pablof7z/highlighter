<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import type { EventType } from "../../../../app";
	import { ndk } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../app";
	import { BookmarkSimple, ChatCircle, TextAa } from "phosphor-svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { pageNavigationOptions } from "$stores/layout";

    export let event: NDKEvent;
    export let urlPrefix: string;
    export let eventType: EventType;
    export let mxClass = "mx-auto";
    export let innerMxClass = mxClass === "mx-auto" ? "sm:-ml-12" : "";

    const events = $ndk.storeSubscribe(
        { kinds: [1, 12, 9735, 6, 16], ...event.filter() },
    )

    onDestroy(() => {
        events.unsubscribe();
    })

    $pageNavigationOptions = [];

    let options: NavigationOption[] = [];

    $: {
        options = [];
        options.push({ name: "Article", href: urlPrefix, icon: TextAa })
        options.push({ name: "Comments", href: `${urlPrefix}/comments`, icon: ChatCircle })
        options.push({ name: "Highlights", href: `${urlPrefix}/highlights`, icon: HighlightIcon })
        options.push({ name: "Curations", href: `${urlPrefix}/curations`, icon: BookmarkSimple })
    }
</script>

<div class="sticky top-0 sm:top-[var(--layout-header-height)] z-50 mobile-nav {$$props.class??""}">
    <HorizontalOptionsList {options} class="flex gap-4 !text-sm"  />
</div>