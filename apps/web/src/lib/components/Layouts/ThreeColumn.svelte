<script lang="ts">
	import { pushState } from "$app/navigation";
	import { page } from "$app/stores";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
import MainWrapper from "$components/Page/MainWrapper.svelte";
	import HomeNavigation from "$components/PageElements/Navigation/HomeNavigation.svelte";
    import { detailView } from "$stores/layout";
	import { X } from "phosphor-svelte";

    export let leftColumn = true;

    let hasRightSidebarExpanded = false;

    $: hasRightSidebarExpanded = !!$page.state.detailView;
    // $: hasRightSidebarExpanded = !!$detailView;

    function closeDetailView() {
        pushState($page.url.href, '');
        hasRightSidebarExpanded = false;
        // pushState('', '');
        // page.update((p) => {
        //     p.state.detailView = undefined;
        // });
    }
</script>

<MainWrapper
    class="
        !flex-row justify-center flex pb-6 w-full
        {hasRightSidebarExpanded ? "" : "max-w-6xl"}
    "
    marginClass="
        mx-auto
    "
    paddingClass=""
    mobilePadded={false}
    headerMarginClass="
        md:max-w-3xl md:mx-auto md:px-4
    "
>
    <!-- Left sidebar -->
    <div class="
        h-full hidden md:block sticky top-0 pt-10
        lg:py-4 pr-4
        flex-none
        max-w-[260px]
        {hasRightSidebarExpanded ?
            "md:w-10 lg:w-1/5 xl:w-2/12" :
            "md:w-10 lg:w-1/5 xl:w-1/5 "
        }
    ">
        {#if $$slots.left}
            <slot name="left" />
        {:else if leftColumn}
            <HomeNavigation />
        {:else}
            <div class="grow h-full"></div>
        {/if}
    </div>

    <!-- Main -->
    <div class="border-x border-base-300
        flex-none w-full
        max-w-[800px]
        {hasRightSidebarExpanded ?
            "lg:w-3/4 xl:w-5/12" :
            "md:w-full lg:w-3/4 xl:w-3/5"
        }
    ">
        <slot />
    </div>

    <!-- Right Sidebar -->
    <div class="
        sticky top-16
        max-h-screen overflow-y-auto overflow-x-clip
        w-full
        max-w-[800px]

        max-sm:fixed max-sm:top-0 max-sm:left-0 max-sm:bottom-0 max-sm:right-0
        max-sm:w-full max-sm:z-[50] max-sm:bg-base-100/50
        max-sm:backdrop-blur-[10px] max-sm:overflow-y-auto max-sm:h-[100dvh] max-sm:p-4
        {hasRightSidebarExpanded ?
            "xl:block xl:2/5" :
            "max-sm:hidden"
        }
    ">
        {#if hasRightSidebarExpanded && $detailView}
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
</MainWrapper>

<!-- <CreatorFooter {user} tiers={userTiers} userSupporters={userSupporters} /> -->

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28 xl:w-5/12 xl:w-2/12 max-w-[1640px]"></div>