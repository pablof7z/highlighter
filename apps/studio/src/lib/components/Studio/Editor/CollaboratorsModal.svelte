<script lang="ts">
	import NostrEntitySearch from '@/components/NostrEntitySearch.svelte';
	import { type PostState } from '../state.svelte';
	import * as Dialog from '@/components/ui/dialog/';
	import type { Hexpubkey } from '@nostr-dev-kit/ndk';
	import AvatarWithName from '@/components/user/AvatarWithName.svelte';
	import { Button } from '@/components/ui/button';
	import * as Select from '@/components/ui/select';

    type Props = {
        open: boolean;
        postState: PostState;
	}

	let { open = $bindable(), postState = $bindable() }: Props = $props();

    type Role = 'editor' | 'viewer';
    
    let selected = $state<Record<Hexpubkey, Role>>({});

    function onSelect(encoding: string) {
        console.log(encoding);
        selected[encoding] = 'viewer';
        console.log(Object.keys(selected).length);
    }

    $inspect(Object.keys(selected).length)

    function onAddCollaborators() {
        console.log(selected);
    }
</script>

<Dialog.Root bind:open>
    <Dialog.Content class="h-[50vh] flex flex-col max-w-3xl">
		<Dialog.Title>Collaborators</Dialog.Title>
		<Dialog.Description>
			Add collaborators to this draft.
		</Dialog.Description>

        <div class="flex flex-row gap-2 h-full">
            <div class="flex flex-col gap-2 w-1/3 h-full">
                <NostrEntitySearch onSelect={onSelect} placeholder="Search for a user" />
            </div>

            <div class="flex flex-col gap-2 w-2/3 p-2 rounded-md border border-border">
                {#if Object.keys(selected).length === 0}
                    <div class="flex items-center justify-center h-full">   
                        <p class="text-muted-foreground">No collaborators selected</p>
                    </div>
                {:else}
                    {#each Object.entries(selected) as [pubkey, role], index}
                        <div class="flex flex-row items-center justify-between gap-2">
                            <div class="w-full">
                                <AvatarWithName of={pubkey} avatarSize="small" nameClass="text-muted-foreground text-sm" />
                            </div>

                            <div class="flex-none w-32">
                            <Select.Root type="single" bind:value={selected[pubkey]}>
                                <Select.Trigger>
                                    {selected[pubkey] === 'editor' ? 'Can Edit' : 'Can View'}
                                </Select.Trigger>
                                <Select.Content>
                                    <Select.Item value="editor">Can Edit</Select.Item>
                                    <Select.Item value="viewer">Can View</Select.Item>
                                </Select.Content>
                            </Select.Root>
                            </div>
                        </div>
                    {/each}
                {/if}
            </div>
        </div>

        <Dialog.Footer>
            <Button variant="default" onclick={onAddCollaborators}>
                Add Collaborators
            </Button>
        </Dialog.Footer>
	</Dialog.Content>
</Dialog.Root>
