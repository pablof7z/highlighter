<script lang="ts">
	import CategorySelector from './../../../../lib/components/Forms/CategorySelector.svelte';
	import Checkbox from '$components/Forms/Checkbox.svelte';
	import type { UserProfileType } from './../../../../app.d.ts';
    import UserProfile from '$components/User/UserProfile.svelte';
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
    import Input from '$components/Forms/Input.svelte';
	import { user } from '@kind0/ui-common';
    import { createEventDispatcher } from 'svelte';
    import { ArrowRight } from 'phosphor-svelte';

    const dispatch = createEventDispatcher();

    let name: string;
    let about: string;
    let userProfile: UserProfileType;
    let saveAsAlternativeProfile = false;
    let editingCategories: string[] = [];

    $: name = userProfile?.name ?? '';
    $: about = userProfile?.about ?? '';

    function skip() {
        dispatch('saved');
    }

    function saveClicked() {
        dispatch('saved');
    }
</script>

<div class="flex flex-col divide-y divide-base-300">
    <UserProfile user={$user} bind:userProfile let:fetching>
        <div class="mb-10">
            <div class="flex flex-row gap-2 items-center">
                <div class="flex-none">
                    <EditableAvatar user={$user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black flex-none" />
                </div>

                <div class="flex flex-col w-full items-stretch">
                    <Input bind:value={name} placeholder="Name" color="black" class="text-2xl rounded-b-none !border-b-0" />
                    <Input bind:value={about} placeholder="About" color="black" class="text-sm rounded-t-none" />
                </div>
            </div>
        </div>
    </UserProfile>

    <div class="py-10 flex flex-col gap-2">
        <h3>Categories</h3>
        <h4>Choose the categories that best describe your content</h4>

        <CategorySelector bind:categories={editingCategories} skipTitle={true} />
    </div>
</div>

<div class="flex flex-row justify-between items-stretch">
    <Checkbox bind:value={saveAsAlternativeProfile}>
        Save as alternative profile
    </Checkbox>

    <div class="flex flex-row gap-2">
        <button class="button button-primary px-10 py-4" on:click={skip}>
            Skip for now
        </button>

        <button class="button px-10 py-4" on:click={saveClicked}>
            Continue
            <ArrowRight class="w-6 h-6 ml-2" />
        </button>
    </div>
</div>

<style>
    h3 {
        @apply text-3xl text-white font-semibold;
    }
</style>