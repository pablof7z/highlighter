<script lang="ts">
    import UserProfile from '$components/User/UserProfile.svelte';
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
	import { ndk, user } from '@kind0/ui-common';
    import { createEventDispatcher } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent } from '@nostr-dev-kit/ndk';
	import type { UserProfileType } from "../../../app";
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
    import { Image } from "phosphor-svelte";
	import GlassyInput from "$components/Forms/GlassyInput.svelte";

    const dispatch = createEventDispatcher();

    let userProfile: UserProfileType = {};
    let saving = false;

    async function save() {
        saving = true;
        try {
            userProfile.display_name = userProfile.name;
            const profile = new NDKEvent($ndk, {
                kind: 0,
                content: serializeProfile(userProfile)
            } as NostrEvent);
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
</script>

<div class="flex flex-col">
    <UserProfile user={$user} bind:userProfile let:fetching>
        <div class="relative w-full h-[20rem] overflow-hidden rounded-box">
            <ImageUploader bind:url={userProfile.banner} wrapperClass="overflow-hidden" alwaysUseSlot={true}>
                {#if userProfile?.banner}
                    <img src={userProfile?.banner} class="w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
                    <div class="flex flex-col items-center gap-4 text-base opacity-70 text-white z-40">
                        <Image size={42} />
                        Upload a Cover Image
                    </div>
                {:else}
                    <div class="h-[25dvh] w-full input-background rounded-box flex items-center justify-center">
                        <div class="flex flex-col items-center gap-4 text-base opacity-70 text-white">
                            <Image size={42} />
                            Upload a Cover Image
                        </div>
                    </div>
                {/if}
            </ImageUploader>
        </div>

        <div class="mb-10 -mt-7 z-20">
            <div class="flex flex-row gap-4 items-end">
                <div class="flex-none">
                    <EditableAvatar
                        url={userProfile?.image}
                        on:uploaded={(e) => { console.log(e, e.detail); userProfile.image = e.detail }}
                        class="w-24 h-24 mask mask-squircle"
                    />
                </div>

                <GlassyInput bind:value={userProfile.name} placeholder="Name" color="black" class="text-lg text-white font-medium" />
            </div>
        </div>

        <section class="settings">
            <div class="field">
                <div class="title">About you</div>
                <GlassyInput bind:value={userProfile.about} placeholder="About" class="text-sm" />
            </div>

            <div class="field">
                <div class="title">LN Wallet</div>
                <GlassyInput bind:value={userProfile.lud16} placeholder="LN Wallet" class="text-sm" />
            </div>
        </section>
    </UserProfile>
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
