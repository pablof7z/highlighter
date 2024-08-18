<script lang="ts">
	import ToggleDark from "$components/buttons/ToggleDark.svelte";
    import CurrentUser from "$components/CurrentUser.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
    import { Button } from "$components/ui/button";
	import currentUser from "$stores/currentUser";
	import { MagnifyingGlass } from "phosphor-svelte";
	import NewItemButton from "./NewItemButton.svelte";
	import { Input } from "$components/ui/input";
	import { openModal } from "$utils/modal";
	import SearchModal from "$modals/SearchModal.svelte";
	import { groupsList } from "$stores/session";

    const options = [
        { name: "Reads", href: '/' },
        { name: "Publications", href: '/publications' },
        { name: "Highlights", href: '/highlights' },
        // { name: "Feed Marketplace", icon: Plus, buttonProps: { class: 'place-self-end', variant: 'secondary' }, href: '/reads/dvms' },
    ]

    function search() {
        openModal(SearchModal);
    }

    /**
     * Whether the current user is admin of any group
     */
    let ownsGroups = false;

    // TODO: This is checking whether the user has pinned groups, not if it's the admin of any group
    $: ownsGroups = !!($currentUser && $groupsList && $groupsList.items.length > 0);
</script>

<div class="flex flex-row justify-between gap-2 items-center p-3">
    <div class="flex flex-row gap-2 items-center">
        {#if $currentUser}
            <CurrentUser class="w-10" />
        {/if}
        <ToggleDark />
    </div>
    
    <div>
        <HorizontalOptionsList {options} />
    </div>

    <div class="flex flex-row gap-2 items-center">
        <Button on:click={search} variant="secondary">
            <MagnifyingGlass size={24} />
        </Button>
        
        {#if $currentUser}
            {#if !ownsGroups}
                <Button variant="accent" href="/studio">
                    Create Publication
                </Button>
            {:else}
                <Button variant="secondary" href="/studio">
                    Dashboard
                </Button>
            {/if}
            <NewItemButton />
        {:else}
            <Button href="/signup">
                Sign Up
            </Button>
        {/if}
    </div>
</div>