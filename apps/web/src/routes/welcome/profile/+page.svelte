<script lang="ts">
	import type { UserProfileType } from './../../../../app.d.ts';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { ndk, user } from '@kind0/ui-common';
    import { createEventDispatcher } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent } from '@nostr-dev-kit/ndk';
	import { pageHeader } from '$stores/layout.js';
	import ProfileEditPage from '$components/User/ProfileEditPage.svelte';
	import LoadingScreen from '$components/LoadingScreen.svelte';

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

    async function saveClicked() {
        await save();
        dispatch('saved');
    }

	$pageHeader = {
		title: "Profile",
		left: {
			label: "Back",
			url: "/welcome",
		},
		right: {
			label: saving ? "loading" : "Save",
			fn: saveClicked
		}
	};
</script>

<MainWrapper marginClass="max-w-3xl">
    <LoadingScreen ready={!!$user}>
        <ProfileEditPage />
    </LoadingScreen>
</MainWrapper>

<style lang="postcss">
    h3 {
        @apply text-3xl text-white font-semibold;
    }
</style>