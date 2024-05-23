<script lang="ts">
	import { appMobileView } from "$stores/app";
    import currentUser from "$stores/currentUser";
	import { inboxItems, inboxList } from "$stores/inbox";
    import { categorizedUserLists, sortedUserLists, userFollows } from "$stores/session";
    import { ndk } from "@kind0/ui-common";
    import { NDKUser } from "@nostr-dev-kit/ndk";
    import { Checkbox } from "konsta/svelte";
    import { Check, Plus, Tray, User, UserPlus } from "phosphor-svelte";

    export let user: NDKUser;
    export let collapsed = false;

    async function follow() {
        await $inboxList.addItem(user);
        $inboxList.publishReplaceable();
        inboxed = true;
    }

    async function unfollow() {
        const index = $inboxList.tags.map(t => t[1]).indexOf(user.pubkey);
        if (index >= 0) {
            const list = await $inboxList.removeItem(index, false);
            list.publishReplaceable();
            inboxed = false;
        }
    }

    let inboxed: boolean;
    $: inboxed = $inboxItems.has(user.pubkey);
</script>

{#if $currentUser?.pubkey !== user.pubkey}
    <div class="dropdown dropdown-hover z-50 dropdown-end">
        {#if !inboxed}
            <button class="flex  transition-all duration-300 {collapsed ? "flex-row" : "flex-col"} items-center gap-1 hover:text-zinc-400" on:click={follow}>
                <Tray class="" size={$appMobileView ? 25 : 20} weight="bold" />
                <span class="text-xs {collapsed ? "max-sm:hidden" : ""}">Inbox</span>
            </button>
        {:else}
            <button class="flex transition-all duration-300 {collapsed ? "flex-row" : "flex-col"} items-center gap-1 text-accent2 hover:grayscale" on:click={unfollow}>
                <Tray class="" size={$appMobileView ? 25 : 20} weight="bold" />
                <span class="text-xs {collapsed ? "max-sm:hidden" : ""}">Inbox</span>
            </button>
        {/if}
        {#if $inboxItems.size === 0}
            <div class="dropdown-content absolute menu flex flex-col items-center w-48 p-4">
                <Tray size={48} class="text-accent2" />

                <h1>Inbox</h1>

                <p>
                    Add the creators you care about the most to your inbox to receive their latest updates.
                </p>
            </div>
        {/if}
    </div>
{/if}
