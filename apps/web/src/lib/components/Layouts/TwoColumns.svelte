<script lang="ts">
	import { pushState } from "$app/navigation";
	import { page } from "$app/stores";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import MainWrapper from "$components/Page/MainWrapper.svelte";
    import { detailView } from "$stores/layout";
	import { X } from "phosphor-svelte";
	import { fly } from "svelte/transition";

    export let leftColumn = true;

    let hasRightSidebarExpanded = false;

    $: hasRightSidebarExpanded = !!$page.state.detailView;
    
    // $: hasRightSidebarExpanded = !!$page.state.detailView;
    // $: hasRightSidebarExpanded = !!$detailView;

    function closeDetailView() {
        pushState($page.url.href, {});
        hasRightSidebarExpanded = false;
        // pushState('', '');
        // page.update((p) => {
        //     p.state.detailView = undefined;
        // });
    }
</script>

<MainWrapper
    class="!flex-row justify-start flex pb-6 w-full max-w-7xl"
    marginClass="
        mx-auto
    "
    paddingClass=""
    mobilePadded={false}
    headerMarginClass="
        md:max-w-3xl md:mx-auto md:px-4
    "
>
    <!-- Main -->
    <div class="border-x border-base-300
        flex-none w-full lg:w-3/5 xl:w-7/12
        mx-auto
    ">
        <slot />
    </div>

    <!-- Right Sidebar -->
    {#if hasRightSidebarExpanded}
        <div class="
            sticky top-16
            max-h-screen overflow-y-auto overflow-x-clip
            w-full shadow-2xl shadow-black

            max-sm:fixed max-sm:top-0 max-sm:left-0 max-sm:bottom-0 max-sm:right-0
            max-sm:w-full max-sm:z-[50] max-sm:bg-base-100/50
            max-sm:backdrop-blur-[10px] max-sm:overflow-y-auto max-sm:h-[100dvh] max-sm:p-4
            md:w-10 lg:w-2/5 xl:w-5/12
        " transition:fly={{duration: 300, axis: 'x'}}>
            {#if $detailView}
                <button class="fixed right-4 top-22 z-[999]" on:click={closeDetailView}>
                    <X class="w-6 h-6" />
                </button>
                {#key $detailView.props.event?.id}
                    {#if $detailView.component === "Note"}
                        <div class="flex flex-col w-full justify-stretch">
                            <div class="discussion-wrapper w-full flex flex-col">
                                <EventWrapper
                                    event={$detailView.props.event}
                                    expandReplies={true}
                                    expandThread={true}
                                />
                            </div>
                        </div>
                    {:else}
                        <svelte:component this={$detailView.component} {...$detailView.props} />
                    {/if}
                {/key}
            {:else}
                <slot name="right" />
            {/if}
        </div>
    {/if}
</MainWrapper>

<!-- <CreatorFooter {user} tiers={userTiers} userSupporters={userSupporters} /> -->

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28 xl:w-5/12 xl:w-2/12 max-w-[1640px]"></div>