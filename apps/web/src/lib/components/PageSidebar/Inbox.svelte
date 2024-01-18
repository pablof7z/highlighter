<script lang="ts">
	import PageSidebar from "$components/PageSidebar.svelte";
	import SuperFollowList from "../../../routes/(app)/inbox/SuperFollowList.svelte";
    import { mode } from "$stores/inbox-view";

    let open = true;
</script>

<PageSidebar title="Inbox" bind:open>
    <div slot="headerRight" class="justify-start items-center flex">
        <div role="tablist" class="tabs tabs-boxed bg-transparent">
            <button
                role="tab"
                class="tab"
                class:tab-active={$mode === 'all'}
                on:click={() => $mode = 'all'}
            >All</button>
            <button
                role="tab"
                class="tab"
                class:tab-active={$mode === 'paid'}
                on:click={() => $mode = 'paid'}
            >Paid</button>
        </div>
    </div>

    <SuperFollowList bind:mode={$mode} bind:open />
</PageSidebar>

<style lang="postcss">
    .tab {
        @apply text-[15px] text-opacity-60 leading-5 font-semibold;
    }

    .tab-active {
        @apply !text-accent2;
    }
</style>