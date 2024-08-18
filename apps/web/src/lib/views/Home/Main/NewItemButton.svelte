<script lang="ts">
    import { Plus } from "phosphor-svelte";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import { openModal } from "$utils/modal";
	import NewPostModal from "$modals/NewPostModal.svelte";
    import CreatorProfileModal from '$modals/CreatorProfileModal';
	import { groupsList } from "$stores/session";
	import { Button } from "$components/ui/button";
	import currentUser from "$stores/currentUser";

    /**
     * Whether the current user is admin of any group
     */
    let ownsGroups = false;

    // TODO: This is checking whether the user has pinned groups, not if it's the admin of any group
    $: ownsGroups = !!($currentUser && $groupsList && $groupsList.items.length > 0);
</script>

<DropdownMenu.Root>
    <DropdownMenu.Trigger>
        <Button>
            <Plus size={20} />
        </Button>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content>
        <DropdownMenu.Group>
            <DropdownMenu.Label>New Post</DropdownMenu.Label>
            <DropdownMenu.Separator />
            <DropdownMenu.Item on:click={() => openModal(NewPostModal)}>Short Note</DropdownMenu.Item>
            <DropdownMenu.Item href="/studio/article">Long-form</DropdownMenu.Item>
            <DropdownMenu.Item href="/studio/video">Video</DropdownMenu.Item>
        </DropdownMenu.Group>
        <DropdownMenu.Group>
            <DropdownMenu.Label>Monetize</DropdownMenu.Label>
            <DropdownMenu.Separator />
            {#if ownsGroups}
                <DropdownMenu.Item on:click={() => openModal(CreatorProfileModal)}>
                    Create new publication
                </DropdownMenu.Item>
            {:else}
                <DropdownMenu.Item on:click={() => openModal(CreatorProfileModal)}>
                    Create a monetizable publication
                </DropdownMenu.Item>
            {/if}
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>