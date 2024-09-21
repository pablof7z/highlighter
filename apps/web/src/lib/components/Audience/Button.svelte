<script lang="ts">
	import { derived, Readable, writable, Writable } from "svelte/store";
	import { Button } from "$components/ui/button";
	import { Star, UsersThree } from "phosphor-svelte";
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import * as Groups from "$components/Groups";
	import { groupsList } from "$stores/session.js";
	import { NDKList } from "@nostr-dev-kit/ndk";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import { openModal } from "$utils/modal.js";
	import NewGroupModal from "$modals/NewGroupModal.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import * as Audience from "$components/Audience/";

    export let state: Writable<Audience.State>;
    export let variant = "outline";

    let groups: Writable<Record<string, Groups.GroupData>> | undefined;

    let allPossibleGroups: Readable<Record<string, Groups.GroupData>> | undefined;

    $: if ($groupsList && !groups) {
        groups = Groups.loadGroupDataFromList(groupsList as Writable<NDKList>);

        allPossibleGroups = derived([groups, state], ([$groups, $state]) => {
            const g = $groups || [];

            if ($state.groups) {
                for (const group of $state.groups) {
                    if (!g[group.id]) {
                        g[group.id] = group;
                    }
                }
            }

            return g;
        });
    }

    const imagesOfGroupsToPublish = derived(state, $state => {
        const images: string[] = [];
        $state.groups?.forEach((group) => {
            console.log(group);
            if (group?.picture) {
                images.push(group.picture);
            }
        });
        return images;
    });

    let selectedGroups: Record<string, boolean> = {};

    if ($state.groups) {
        for (const group of $state.groups) {
            selectedGroups[group.id] = true;
        }
    }

    $: if ($allPossibleGroups) {
        const g: Groups.GroupData[] = [];
        for (const groupId in selectedGroups) {
            console.log(groupId);
            if (selectedGroups[groupId]) {
                const group = $allPossibleGroups[groupId];
                console.log(group);
                if (group) {
                    g.push(group);
                }
            }
        }

        state.update($state => {
            $state.groups = g;
            return $state;
        });
    }
</script>

<DropdownMenu.Root closeOnItemClick={false}>
    <DropdownMenu.Trigger>

        <Button class="flex flex-row gap-2" {variant}>
            {#if $state.scope === 'public'}
                <UsersThree class="" size={20} />
                Everyone
                {#if $imagesOfGroupsToPublish.length > 0}
                    <span class="hidden md:block">
                        +
                    </span>
                {/if}
            {:else}
                <span>
                    <Star class="w-4 h-4 text-gold md:mr-1 inline" size={20} weight="fill" />
                    Subscribers
                </span>
            {/if}
        
            {#if $imagesOfGroupsToPublish.length === 0}
            {:else}
                <div class="flex flex-row items-center rounded-full overflow-clip -space-x-2">
                    {#each $imagesOfGroupsToPublish as image}
                        <img src={image} class="w-6 h-6 rounded-full" />
                    {/each}
                </div>
            {/if}
        </Button>
        
    </DropdownMenu.Trigger>
    
    <DropdownMenu.Content>
        <DropdownMenu.Group>
            <DropdownMenu.Label>Visibility</DropdownMenu.Label>
            <DropdownMenu.RadioGroup value={$state.scope} on:change={console.log}>
                <DropdownMenu.RadioItem value='public' on:click={e => { $state.scope = 'public'; e.stopPropagation() }} class="flex flex-col items-start text-left">
                    Everyone
                    <div class="text-xs text-muted-foreground">
                        Everyone can see this post.
                    </div>
                </DropdownMenu.RadioItem>
                <DropdownMenu.RadioItem value='private' on:click={e => {$state.scope = 'private'; e.stopPropagation()}} class="flex flex-col items-start text-left">
                    <div>
                        <Star class="w-4 h-4 text-gold mr-1 inline" size={20} weight="fill" />
                        Subscribers
                    </div>

                    <div class="text-xs text-muted-foreground">
                        Only subscribers will see this post.
                    </div>
                </DropdownMenu.RadioItem>
            </DropdownMenu.RadioGroup>

            {#if $groupsList && $allPossibleGroups}
                {#if Object.keys($allPossibleGroups).length > 0}
                    <div class:hidden={$state.scope !== 'private'}>
                        <DropdownMenu.Separator />

                        <DropdownMenu.Label>Publications</DropdownMenu.Label>
                        
                        {#each Object.entries($allPossibleGroups) as [groupId, group] (groupId)}
                            {#if group.metadata}
                                <DropdownMenu.CheckboxItem bind:checked={selectedGroups[groupId]} class="flex flex-row justify-between items-center w-full">
                                    <div class="flex flex-row items-center gap-1">
                                        <Groups.Avatar {group} size="sm" />
                                        <Groups.Name {group} />
                                    </div>

                                    {#if group.access === 'open'}
                                        <Badge>Open</Badge>
                                    {:else}
                                        <Badge>Exclusive</Badge>
                                    {/if}
                                </DropdownMenu.CheckboxItem>
                            {/if}
                        {/each} 
                    </div>
                {/if}
            {:else if $state.scope === 'private'}
                <DropdownMenu.Label>
                    Publications
                </DropdownMenu.Label>

                <DropdownMenu.Label class="bg-secondary rounded border p-4 m-4">
                    <BlankState cta="Create a publication" on:click={() => openModal(NewGroupModal)}>
                        You are not a member of any publications.
                    </BlankState>
                </DropdownMenu.Label>
                
            {/if}
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>