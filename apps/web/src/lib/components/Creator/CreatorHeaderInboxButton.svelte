<script lang="ts">
	import HighlightUserModal from './../../modals/Helper/HighlightUserModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { appMobileView } from "$stores/app";
    import currentUser from "$stores/currentUser";
	import { inboxItems, inboxList } from "$stores/inbox";
	import { seenHighlightUserHelperModal } from "$stores/settings";
	import { openModal } from "$utils/modal";
    import { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
    export let collapsed = false;

    function hover() {
        if (true || $inboxItems.size === 0 && !$seenHighlightUserHelperModal) {
            $seenHighlightUserHelperModal = true;
            openModal(HighlightUserModal, { user });
        }
    }

    function click() {
        if ($inboxItems.size === 0) {
            openModal(HighlightUserModal, { user });
        } else {
            follow();
        }
    }

    async function follow() {
        await $inboxList.addItem(user);
        $inboxList.publishReplaceable();
        highlighted = true;
    }

    async function unfollow() {
        const index = $inboxList.tags.map(t => t[1]).indexOf(user.pubkey);
        if (index >= 0) {
            const list = await $inboxList.removeItem(index, false);
            list.publishReplaceable();
            highlighted = false;
        }
    }

    let highlighted: boolean;
    $: highlighted = $inboxItems.has(user.pubkey);
</script>

{#if $currentUser?.pubkey !== user.pubkey}
    {#if !highlighted}
        <button
            class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col justify-between"} items-center gap-2 hover:text-zinc-400"
            on:click={click}
            on:mouseenter={hover}
        >
            <HighlightIcon class="transition-all duration-300 {collapsed ? "w-5 h-5" : "w-9 h-9 py-[6px]"}" />
            <span class="{collapsed ? "max-sm:hidden text-sm" : "text-base"}">Highlight</span>
        </button>
    {:else}
        <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col justify-between"} items-center gap-2 text-accent hover:grayscale" on:click={unfollow}>
            <HighlightIcon class="transition-all duration-300 {collapsed ? "w-5 h-5" : "w-6 h-6"}" />
            <span class="{collapsed ? "max-sm:hidden text-sm" : "text-base"}">Highlight</span>
        </button>
    {/if}
{/if}
