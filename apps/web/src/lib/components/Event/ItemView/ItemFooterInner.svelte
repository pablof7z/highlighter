<script lang="ts">
	import { articleKinds } from './../../../utils/event.ts';
	import { mainContentKinds } from '$utils/event';
	import ShareModal from '$modals/ShareModal.svelte';
	import { NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk.js";
	import { onDestroy, onMount } from "svelte";
	import { NavigationOption } from "../../../app";
	import { CardsThree, ChatCircle, BookOpen, Repeat, Export, Lightning, Watch, YoutubeLogo } from "phosphor-svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { appMobileView } from "$stores/app";
	import { openModal } from "$utils/modal";
	import BookmarkButton from '$components/buttons/BookmarkButton.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import { userGenericCuration } from '$stores/session';
	import ZapModal from '$modals/ZapModal.svelte';
	import AnimatedToggleButton from '$components/PageElements/AnimatedToggleButton.svelte';
	import ReaderButton from '../Article/ReaderButton.svelte';

    export let event: NDKEvent;
    export let urlPrefix: string;

    const events = $ndk.storeSubscribe(
        { kinds: [1, 12, 9735, 6, 16], ...event.filter() },
    )

    let options: NavigationOption[] = [];

    $: {
        options = [];

        if (articleKinds.includes(event.kind)) {
            options.push({ name: undefined, value: 'article', href: urlPrefix, icon: BookOpen })
            options.push({ component: { component: ReaderButton, props: { article: event } } })
        }
        else if (event.kind === NDKKind.HorizontalVideo)
            options.push({ name: undefined, value: 'video', href: urlPrefix, icon: YoutubeLogo })

        options.push({ name: undefined, value: 'comments', href: `${urlPrefix}/comments`, icon: ChatCircle })

        if (event.kind === NDKKind.Article)
            options.push({ name: undefined, value: 'highlights', href: `${urlPrefix}/highlights`, icon: HighlightIcon })

        // if (mainContentKinds.includes(event.kind!))
        //     options.push({ name: undefined, value: 'curations', href: `${urlPrefix}/curations`, icon: CardsThree })
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

<div bind:this={container} class="
    flex justify-between items-stretch flex-row
    w-full
">
    <HorizontalOptionsList {options} class="responsive-padding flex gap-1 !text-sm py-2" />

    {#if $appMobileView}
        <AnimatedToggleButton
            icon={Lightning}
            buttonClass="flex-none hover:bg-orange-400/20"
            bgClass="bg-orange-500"
            iconClass={"text-orange-400/30 group-hover:text-orange-500 max-sm:text-orange-500"}
            on:click={() => openModal(ZapModal, { event })}
        />
    {:else}
        <div class="flex flex-row gap-0 items-stretch max-sm:justify-between max-sm:grayscale-20">
            <BookmarkButton
                active={bookmarked}
                on:click={() => toggleBookmarkedEvent(event)}
            />

            <AnimatedToggleButton
                icon={Repeat}
                buttonClass="flex-none hover:bg-green-400/20"
                bgClass="bg-green-500"
                iconClass={"text-green-400/30 group-hover:text-green-500 max-sm:text-green-500"}
                on:click
            />

            <AnimatedToggleButton
                icon={Export}
                buttonClass="flex-none hover:bg-yellow-400/20"
                bgClass="bg-yellow-500"
                iconClass={"text-yellow-400/30 group-hover:text-yellow-500 max-sm:text-yellow-500"}
                on:click={() => openModal(ShareModal, { event })}
            />

            <AnimatedToggleButton
                icon={Lightning}
                buttonClass="flex-none hover:bg-orange-400/20"
                bgClass="bg-orange-500"
                iconClass={"text-orange-400/30 group-hover:text-orange-500 max-sm:text-orange-500"}
                on:click={() => openModal(ZapModal, { event })}
            />
        </div>
    {/if}
</div>