<script lang="ts">
	import ShareModal from '$modals/ShareModal.svelte';
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import type { EventType } from "../../../../app";
	import { ndk } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../app";
	import { CardsThree, ChatCircle, BookOpen, BookmarkSimple, Recycle, Repeat, Export } from "phosphor-svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { pageNavigationOptions } from "$stores/layout";
	import ItemNavigationCurations from "./ItemNavigationCurations.svelte";
	import { appMobileView } from "$stores/app";
	import { openModal } from "$utils/modal";
	import BookmarkButton from '$components/buttons/BookmarkButton.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import { userGenericCuration } from '$stores/session';

    export let event: NDKEvent;
    export let urlPrefix: string;
    export let eventType: EventType;
    export let mxClass = "mx-auto";
    export let innerMxClass = mxClass === "mx-auto" ? "sm:-ml-12" : "";

    const events = $ndk.storeSubscribe(
        { kinds: [1, 12, 9735, 6, 16], ...event.filter() },
    )

    $pageNavigationOptions = [];

    let options: NavigationOption[] = [];

    $: {
        options = [];
        options.push({ name: "Read", href: urlPrefix, icon: BookOpen })
        options.push({ name: "Comments", href: `${urlPrefix}/comments`, icon: ChatCircle })
        options.push({ name: "Highlights", href: `${urlPrefix}/highlights`, icon: HighlightIcon })
        options.push({
            name: "Curations", 
            href: `${urlPrefix}/curations`,
            icon: CardsThree,
            component: {
                component: ItemNavigationCurations,
                unstyled: true,
                props: { event, href: `${urlPrefix}/curations` }
            }
        })
    }

    let container: HTMLDivElement;
    let toolbarEl: HTMLElement | null;
    let mounted = false;

    onMount(() => mounted = true);

    console.trace('item footer')

    function recomputeTop() {
        if (toolbarEl) {
            container.style.top = `${toolbarEl.clientHeight}px`;
        }
    }

    $: if ($appMobileView && !toolbarEl && mounted) {
        // get #toolbar
        toolbarEl = document.getElementById("navbar");

        recomputeTop();

        window.addEventListener("resize", recomputeTop);
    }

    onDestroy(() => {
        events.unsubscribe();
        if (toolbarEl) {
            window.removeEventListener("resize", recomputeTop);
        }
    })

    let bookmarked;
    $: bookmarked = $userGenericCuration.has(event.tagId());
</script>

<div bind:this={container} class="sticky sm:top-[var(--layout-header-height)] z-50 mobile-nav {$$props.class??""}">
    <div class="flex flex-row justify-between items-stretch">
        <HorizontalOptionsList {options} class="flex gap-1 !text-sm"  />

        <div class="flex flex-row gap-0 items-stretch">
            <BookmarkButton
                active={bookmarked}
                on:click={() => toggleBookmarkedEvent(event)}
            />

            <button class="btn btn-circle btn-ghost hover:bg-green-400/20 group">
                <Repeat class="w-6 h-6 text-green-400/30 group-hover:text-green-500" />
            </button>

            <button
                class="btn btn-circle btn-ghost hover:bg-yellow-400/20 group"
                on:click={() => openModal(ShareModal, { event })}
            >
                <Export class="w-6 h-6 text-yellow-400/30 group-hover:text-yellow-500" />
            </button>
        </div>
    </div>
</div>