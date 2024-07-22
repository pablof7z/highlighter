<script lang="ts">
    import { Hexpubkey, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
    import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { derived, Readable } from "svelte/store";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { CaretDown, CaretRight, CrownSimple } from "phosphor-svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import currentUser from "$stores/currentUser";

    export let group: NDKSimpleGroup;
    export let metadata: Readable<NDKSimpleGroupMetadata>;
    export let members: Readable<NDKSimpleGroupMemberList>;
    export let admins: Readable<NDKSimpleGroupMemberList>;
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let collapsed = true;
    export let openOnMount: boolean | undefined;

    export let onClose: (() => void) | undefined;

    const memberCount = derived([members, admins], ([$members, $admins]) => {
        if (!$members || !$admins) return;
        const allMembers = $members.memberSet;
        $admins.members.forEach(admin => allMembers.add(admin));
        return allMembers.size;
    })

    const nonAdminMembers = derived([members, admins], ([$members, $admins]) => {
        if (!$members || !$admins) return [];
        const allMembers = $members.memberSet;
        $admins.members.forEach(admin => allMembers.delete(admin));
        return Array.from(allMembers);
    })

    async function join() {
        group.requestToJoin($currentUser.pubkey)
    }
</script>

<Footer.Shell
    bind:collapsed
    {openOnMount}
    let:open
    hideCollapsedView
    on:collapse={() => { if (onClose) onClose() }}
>
    <Button variant="accent" class="w-full" on:click={open}>
        View Info & Join
    </Button>

    <div class="flex flex-col gap-3 items-center justify-stretch w-full" slot="main">
        <section class="w-full flex flex-col gap-2 items-center">
            {#if $metadata.picture}
                <img src={$metadata.picture} class="rounded-full w-24 h-24 object-cover" />
                <img src={$metadata.picture} class="object-cover -z-10 absolute top-0 left-0 w-full h-full opacity-10" />
            {/if}
    
            <h1>{$metadata.name}</h1>
    
            {#if $metadata.about}
                <div class="text-left text-muted-foreground">
                    {$metadata.about}
                </div>
            {/if}
        </section>

        <section>
        </section>

        <Button
            variant="accent"
            class="w-full justify-between"
            on:click={join}
        >
            {#if $metadata.access === "closed" && $tiers.length > 0}
                <div>
                    Join &mdash;
                    Starting at
                    {tierAmountToString($tiers[0].amounts[0])}
                </div>
                <CaretDown size={16} class="ml-1" />
            {:else}
                Join
            {/if}
        </Button>

        <section class="w-full flex flex-col gap-2">
            <div class="flex flex-row justify-between w-full text-sm text-muted-foreground">
                <div>Members</div>

                <span>
                    {$memberCount}
                </span>
            </div>

            <div class="flex flex-col rounded w-full bg-background/50">
                {#if $admins}
                    {#each $admins.members as admin}
                        <div class="flex flex-row justify-between w-full items-center text-sm font-semibold p-2 px-4">
                            <AvatarWithName pubkey={admin} avatarSize="small" />

                            <Badge variant="secondary" class="text-muted-foreground">
                                <CrownSimple size={12} class="text-gold mr-1.5" weight="fill" />
                                Admin
                            </Badge>
                        </div>
                    {/each}
                {/if}

                {#each $nonAdminMembers as pubkey}
                    <div class="flex flex-row justify-between w-full items-center text-sm font-semibold p-2 px-4">
                        <AvatarWithName {pubkey} avatarSize="small" />
                    </div>
                {/each}
            </div>
        </section>
    </div>
</Footer.Shell>

<style lang="postcss">
    section {
        @apply w-full flex flex-col gap-2
    }
</style>