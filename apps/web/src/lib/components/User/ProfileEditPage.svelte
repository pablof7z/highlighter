<script lang="ts">
    import UserProfile from '$components/User/UserProfile.svelte';
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
	import { ndk, user } from '@kind0/ui-common';
    import { debugMode, userProfile } from '$stores/session';
    import { createEventDispatcher } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent } from '@nostr-dev-kit/ndk';
	import type { UserProfileType } from "../../../app";
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
    import { Image } from "phosphor-svelte";
	import GlassyInput from "$components/Forms/GlassyInput.svelte";
	import CategorySelector from '$components/Forms/CategorySelector.svelte';

    export let forceSave = false;

    const dispatch = createEventDispatcher();

    export let saving = false;

    async function save() {
        saving = true;
        try {
            $userProfile.display_name ??= $userProfile.name;
            const profile = new NDKEvent($ndk, {
                kind: 0,
                content: serializeProfile($userProfile)
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

    $: if (forceSave && !saving) {
        saving = true;
        forceSave = false;
        save();
    }
</script>

{#if $userProfile}
<div class="flex flex-col">
    <div class="relative w-full h-[20rem] overflow-hidden rounded-box">
        <ImageUploader bind:url={$userProfile.banner} wrapperClass="overflow-hidden" alwaysUseSlot={true}>
            {#if $userProfile?.banner}
                <img src={$userProfile?.banner} class="w-full h-full object-cover object-top lg:rounded" alt={$userProfile?.name}>
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
                    url={$userProfile?.image}
                    on:uploaded={(e) => { console.log(e, e.detail); $userProfile.image = e.detail }}
                    class="w-24 h-24 mask mask-squircle"
                />
            </div>

            <GlassyInput bind:value={$userProfile.name} placeholder="Name" color="black" class="text-lg text-white font-medium" />
        </div>
    </div>

    <section class="settings">
        <div class="field">
            <div class="title">About you</div>
            <GlassyInput bind:value={$userProfile.about} placeholder="About" class="text-sm" />
        </div>

        <div class="field">
            <div class="title">LN Wallet</div>
            <GlassyInput bind:value={$userProfile.lud16} placeholder="LN Wallet" class="text-sm" />
        </div>

        <div class="field">
            <div class="title">Categories</div>
            <div class="description">
                Select the categories that best describe your content
            </div>

            <CategorySelector bind:categories={$userProfile.categories} show={false} />
        </div>
    </section>
</div>


{/if}

<div class="flex flex-col-reverse sm:flex-row sm:gap-2 max-sm:items-stretch w-full justify-end">
    <button class="button px-10 sm:py-3" on:click={saveClicked}>
        {#if saving}
            <span class="loading loading-sm"></span>
        {:else}
            Save
        {/if}
    </button>
</div>

{#if $debugMode}
    <pre>{JSON.stringify($userProfile, null, 4)}</pre>
{/if}