<script lang="ts">
	import CurationWithCountButton from "$components/buttons/CurationWithCountButton.svelte";
    import CommentsButton from "$components/buttons/CommentsButton.svelte";
	import { mainContentKinds } from "$utils/event";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import HighlightsWithCountButton from "$components/buttons/HighlightsWithCountButton.svelte";
	import type { EventType } from "../../../../app";
	import BoostButton from "$components/buttons/BoostButton.svelte";
	import { ZapsButton, ndk } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import { hideMobileBottomBar, pageNavigationOptions } from "$stores/layout";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { NavigationOption } from "../../../app";
	import { BookmarkSimple, ChatCircle, TextAa } from "phosphor-svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";

    export let event: NDKEvent;
    export let urlPrefix: string;
    export let eventType: EventType;
    export let mxClass = "mx-auto";
    export let innerMxClass = mxClass === "mx-auto" ? "sm:-ml-12" : "";

    const eventKind = event.kind!;

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