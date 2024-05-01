<script lang="ts">
	import { pushState } from "$app/navigation";
	import { page } from "$app/stores";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { detailView } from "$stores/layout";
	import { X } from "phosphor-svelte";

    let hasRightSidebarExpanded = false;

    $: hasRightSidebarExpanded = !!$detailView;

    function closeDetailView() {
        pushState($page.url.href, '');
        hasRightSidebarExpanded = false;
        $detailView = null;
        // pushState('', '');
        // page.update((p) => {
        //     p.state.detailView = undefined;
        // });
    }
</script>

<aside class="
    sticky sm:top-[var(--layout-header-height)]
    max-h-screen overflow-y-auto overflow-x-clip
    max-w-[800px]
    
    {$$props.class??""}
">
    {#if $detailView}
        <button class="sticky top-0 right-4 top-22 z-[999]" on:click={closeDetailView}>
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
</aside>