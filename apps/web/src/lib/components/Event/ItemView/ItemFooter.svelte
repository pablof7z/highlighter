<script lang="ts">
	import { mainContentKinds } from '$utils/event';
	import ShareModal from '$modals/ShareModal.svelte';
	import { NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk.js";
	import { onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../app";
	import { CardsThree, ChatCircle, BookOpen, BookmarkSimple, Recycle, Repeat, Export, Lightning, Watch, YoutubeLogo } from "phosphor-svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { appMobileView } from "$stores/app";
	import { openModal } from "$utils/modal";
	import BookmarkButton from '$components/buttons/BookmarkButton.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import { userGenericCuration } from '$stores/session';
	import ZapModal from '$modals/ZapModal.svelte';
	import ToggleDark from '$components/buttons/ToggleDark.svelte';

    export let event: NDKEvent;
    export let urlPrefix: string;

    const events = $ndk.storeSubscribe(
        { kinds: [1, 12, 9735, 6, 16], ...event.filter() },
    )

    let options: NavigationOption[] = [];

    $: {
        options = [];

        options.push({ component: { component: ToggleDark }});
        
        if (event.kind === NDKKind.Article)
            options.push({ name: $appMobileView ? "Read" : undefined, value: 'article', href: urlPrefix, icon: BookOpen })
        else if (event.kind === NDKKind.HorizontalVideo)
            options.push({ name: $appMobileView ? "Watch" : undefined, value: 'video', href: urlPrefix, icon: YoutubeLogo })

        options.push({ name: $appMobileView ? "Comments" : undefined, value: 'comments', href: `${urlPrefix}/comments`, icon: ChatCircle })

        if (event.kind === NDKKind.Article)
            options.push({ name: $appMobileView ? "Highlights" : undefined, value: 'highlights', href: `${urlPrefix}/highlights`, icon: HighlightIcon })

        if (mainContentKinds.includes(event.kind!))
            options.push({ name: $appMobileView ? "Curations" : undefined, value: 'curations', href: `${urlPrefix}/curations`, icon: CardsThree })
    }

    let container: HTMLDivElement;
    let toolbarEl: HTMLElement | null;
    let mounted = false;

    onMount(() => mounted = true);

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

<div bind:this={container} class="mobile-nav {$$props.containerClass??""} {$$props.class??""}">
    <div class="
        flex justify-between items-stretch
        {$appMobileView ? "flex-col-reverse" : "flex-row"}
    ">
        <HorizontalOptionsList {options} class="mobile-nav responsive-padding flex gap-1 !text-sm py-2" />

        <div class="flex flex-row gap-0 items-stretch max-sm:justify-between max-sm:grayscale-20">
            <BookmarkButton
                active={bookmarked}
                on:click={() => toggleBookmarkedEvent(event)}
            />

            <button class="btn btn-circle btn-ghost hover:bg-green-400/20 group">
                <Repeat class="w-6 h-6 text-green-400/30 group-hover:text-green-500 max-sm:text-green-500" />
            </button>

            <button
                class="btn btn-circle btn-ghost hover:bg-yellow-400/20 group"
                on:click={() => openModal(ShareModal, { event })}
            >
                <Export class="w-6 h-6 text-yellow-400/30 group-hover:text-yellow-500 max-sm:text-yellow-500" />
            </button>

            <button
                class="btn btn-circle btn-ghost hover:bg-orange-400/20 group"
                on:click={() => openModal(ZapModal, { event })}
            >
                <Lightning class="w-6 h-6 text-orange-400/30 group-hover:text-orange-500 max-sm:text-orange-500" />
            </button>
        </div>
    </div>
</div>