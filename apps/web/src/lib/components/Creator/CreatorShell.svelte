<script lang="ts">
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import { userTiers, getUserSupporters } from "$stores/user-view";
	import { Avatar, Name, ndk, user as currentUser } from "@kind0/ui-common";
	import { NDKEvent, type NostrEvent, serializeProfile, NDKUser } from "@nostr-dev-kit/ndk";
	import UserProfile from "$components/User/UserProfile.svelte";
	import EditableAvatar from "$components/User/EditableAvatar.svelte";
    import type { UserProfileType } from "../../../app";
	import { Pen } from "phosphor-svelte";
	import CategorySelector from "$components/Forms/CategorySelector.svelte";


    export let user: NDKUser;

    const defaultBanner = 'https://tonygiorgio.com/content/images/2023/03/cypherpunk-ostrach--copy--2.png';

    let userProfile: UserProfileType;
    let kind37777Event: NDKEvent | undefined;
    let canEdit = false;
    let editing = false;
    let editingCategories: string[] = [];

    $: if (user && user?.pubkey === $currentUser?.pubkey) canEdit = true;

    function edit() {
        editingCategories = userProfile.categories || [];
        editing = true;
    }

    async function save() {
        userProfile.display_name = userProfile.name;
        const profile = new NDKEvent($ndk, {
            kind: 37777,
            content: serializeProfile(userProfile)
        } as NostrEvent);
        if (kind37777Event) profile.tags.push(["d", kind37777Event.tagValue("d")!]);
        for (const category of editingCategories) {
            profile.tags.push(["t", category]);
        }
        await profile.publish();
        editing = false;
    }
</script>

<div class="max-w-5xl mx-auto">
    <UserProfile {user} bind:userProfile bind:kind37777Event let:fetching>
        <div class="relative w-full overflow-hidden max-sm:pb-[20vh] pb-[25%]">
            <img src={userProfile?.banner??defaultBanner} class="absolute w-full h-full object-cover object-top lg: rounded" alt={userProfile?.name}>
        </div>
        <!-- Profile Header -->
        <div class="
            flex
            max-sm:flex-col max-sm:w-full max-sm:items-start max-sm:gap-4
            items-end justify-between p-6 relative -top-16
        ">
            <div class="flex items-end">
                {#if canEdit}
                    <EditableAvatar user={user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black" />
                {:else}
                    <Avatar user={user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black" />
                {/if}

                <div class="ml-4">
                    <div class="name text-xl font-semibold text-base-100-content">
                        {#if editing && userProfile}
                            <div class="flex flex-row items-center gap-2">
                                <Pen class="w-4 h-4" />
                                <input bind:value={userProfile.name} class="border-none !bg-transparent !p-0 text-lg  border-b-2 border-white" />
                            </div>
                        {:else}
                            <Name {userProfile} {fetching} />
                        {/if}
                    </div>
                    <p class="text-sm truncate max-w-md">
                        {#if editing && userProfile}
                            <div class="flex flex-row items-center gap-2">
                                <Pen class="w-4 h-4" />
                                <input bind:value={userProfile.about} class="border-none !bg-transparent !p-0 text-sm border-b-2 border-white" />
                            </div>
                        {:else}
                            {#if fetching && !userProfile?.about}
                                <div class="skeleton h-15 w-48">&nbsp;</div>
                            {:else if userProfile?.about}
                                {userProfile?.about}
                            {:else}
                                &nbsp;
                            {/if}
                        {/if}
                    </p>
                </div>
            </div>

            {#if !canEdit}
                {#if $userTiers}
                    <CurrentSupporters
                        supporters={getUserSupporters()}
                        tiers={$userTiers}
                        {user}
                    />
                {/if}
            {:else}
                {#if editing}
                    <div class="flex flex-row items-center gap-8">
                        <button class="button" on:click={save}>Save</button>
                        <button class="" on:click={() => editing = false}>Cancel</button>
                    </div>
                {:else}
                    <button class="button" on:click={edit}>Edit</button>
                {/if}
            {/if}
        </div>

        {#if editing}
            <CategorySelector bind:categories={editingCategories} />
        {/if}
    </UserProfile>

    <slot />
</div>

<style lang="postcss">
    .name {
        @apply max-w-sm truncate;
    }
</style>