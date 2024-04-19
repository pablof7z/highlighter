<script lang="ts">
	import { pushState } from "$app/navigation";
	import { page } from "$app/stores";
	import Note from "$components/Feed/Note.svelte";
import MainWrapper from "$components/Page/MainWrapper.svelte";
	import HomeNavigation from "$components/PageElements/Navigation/HomeNavigation.svelte";
    import { threeColumnLayoutRightSidebar } from "$stores/layout";
	import { X } from "phosphor-svelte";

    let hasRightSidebarExpanded = false;

    $: hasRightSidebarExpanded = !!$page.state.detailView;
    // $: hasRightSidebarExpanded = !!$threeColumnLayoutRightSidebar;

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
    marginClass="
        mx-auto
        {hasRightSidebarExpanded ? "max-w-[1640px]" : "max-w-6xl"}
    "
    paddingClass="md:px-4"
    mobilePadded={false}
    headerMarginClass="
        md:max-w-3xl md:mx-auto md:px-4
    "
>
    <div class="flex flex-row w-full relative h-full grow">
        <!-- Left sidebar -->
        <div class="
            h-full hidden md:block sticky top-0 pt-10
            lg:py-4 pr-4
            flex-none
            {hasRightSidebarExpanded ?
                "md:w-10 lg:w-1/5 xl:w-2/12" :
                "md:w-10 lg:w-1/5 xl:w-1/5 "
            }
        ">
            {#if $$slots.left}
                <slot name="left" />
            {:else}
                <HomeNavigation />
            {/if}
        </div>

        <!-- Main -->
        <div class="border-x border-base-300
            flex-none
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
            w-full max-w-[50rem] shadow-2xl shadow-black
            {hasRightSidebarExpanded ?
                "xl:block xl:5/12" :
                "hidden "
            }
        ">
            {#if $threeColumnLayoutRightSidebar}
                <button class="fixed right-4 top-22 z-[999]" on:click={closeDetailView}>
                    <X class="w-6 h-6" />
                </button>
                {#key $threeColumnLayoutRightSidebar.props.event?.id}
                    {#if $threeColumnLayoutRightSidebar.component === "Note"}
                        <div class="flex flex-col w-full justify-stretch">
                            <div class="discussion-wrapper w-full flex flex-col">
                                <Note
                                    event={$threeColumnLayoutRightSidebar.props.event}
                                    expandReplies={true}
                                    expandThread={true}
                                />
                            </div>
                        </div>
                    {:else}
                        <svelte:component this={$threeColumnLayoutRightSidebar.component} {...$threeColumnLayoutRightSidebar.props} />
                    {/if}
                {/key}
            {:else}
                <slot name="right" />
            {/if}
        </div>
    </div>
</MainWrapper>

<!-- <CreatorFooter {user} tiers={userTiers} userSupporters={userSupporters} /> -->

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28 xl:w-5/12 xl:w-2/12 max-w-[1640px]"></div>