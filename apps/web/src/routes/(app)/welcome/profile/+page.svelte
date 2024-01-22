<script lang="ts">
	import type { UserProfileType } from './../../../../app.d.ts';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import CategorySelector from '$components/Forms/CategorySelector.svelte';
    import UserProfile from '$components/User/UserProfile.svelte';
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
    import Input from '$components/Forms/Input.svelte';
	import { ndk, user } from '@kind0/ui-common';
    import { createEventDispatcher } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent } from '@nostr-dev-kit/ndk';
	import PageTitle from '$components/Page/PageTitle.svelte';

    const dispatch = createEventDispatcher();

    let userProfile: UserProfileType = {};
    let editingCategories: string[] = [];
    let saving = false;

    async function save() {
        saving = true;
        try {
            userProfile.display_name = userProfile.name;
            const profile = new NDKEvent($ndk, {
                kind: 0,
                content: serializeProfile(userProfile)
            } as NostrEvent);
            // if (kind37777Event) profile.tags.push(["d", kind37777Event.tagValue("d")!]);
            for (const category of editingCategories) {
                profile.tags.push(["t", category]);
            }
            await profile.publish();
        } catch (e) {
            console.error(e);
        } finally {
            saving = false;
        }
    }

    function skip() {
        dispatch('saved');
    }

    async function saveClicked() {
        await save();
        dispatch('saved');
    }
</script>

<PageTitle
	title="Profile"
	back="/welcome"
	marginClass="max-w-3xl"
	class="p-6"
>
	<button class="button flex flex-row items-center gap-2 px-6" slot="right" on:click={saveClicked}>
		{#if saving}
			<span class="loading loading-sm"></span>
		{:else}
			Save
		{/if}
	</button>
</PageTitle>

<MainWrapper marginClass="max-w-3xl">
	<div class="flex flex-col divide-y divide-base-300">
		<UserProfile user={$user} bind:userProfile let:fetching>
			<div class="mb-10">
				<div class="flex flex-row gap-2 items-center">
					<div class="flex-none">
						<EditableAvatar user={$user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black flex-none" />
					</div>

					<div class="flex flex-col w-full items-stretch">
						<Input bind:value={userProfile.name} placeholder="Name" color="black" class="text-2xl rounded-b-none !border-b-0" />
						<Input bind:value={userProfile.about} placeholder="About" color="black" class="text-sm rounded-t-none" />
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

	<div class="flex flex-col-reverse sm:flex-row sm:gap-2 max-sm:items-stretch w-full justify-end">
		<!-- <button class="max-sm:hidden button button-primary px-10 py-4" on:click={skip}>
			Skip for now
		</button> -->

		<button class="button px-10 sm:py-3" on:click={saveClicked}>
			{#if saving}
				<span class="loading loading-sm"></span>
			{:else}
				Save
			{/if}
		</button>
	</div>
</MainWrapper>

<style lang="postcss">
    h3 {
        @apply text-3xl text-white font-semibold;
    }
</style>