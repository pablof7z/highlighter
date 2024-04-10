<script lang="ts">
	import { categories } from './../../utils/categories.ts';
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
    import currentUser from '$stores/currentUser';
	import { RelativeTime, ndk, user } from '@kind0/ui-common';
    import { debugMode, processUserProfile, userProfile } from '$stores/session';
    import { createEventDispatcher, onMount } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent, NDKRelaySet, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
	import ImageUploader from "$components/Forms/ImageUploader.svelte";
    import { ArrowElbowRight, Image, Info, Warning } from "phosphor-svelte";
	import GlassyInput from "$components/Forms/GlassyInput.svelte";
	import CategorySelector from '$components/Forms/CategorySelector.svelte';

    export let forceSave = false;

    const dispatch = createEventDispatcher();

    export let saving = false;

    let categories: string[] = [];

    onMount(() => {
        if ($userProfile) categories = $userProfile.categories ?? [];
    })

    const relaySet = NDKRelaySet.fromRelayUrls([
        "wss://purplepag.es/", "wss://profiles.nos.lol", "wss://relay.damus.io", "wss://relay.primal.net"
    ], $ndk);
    for (const relay of $ndk.pool.connectedRelays()) {
        relaySet.addRelay(relay);
    }

    // just to be on the safe-side, try to load this user's profile again
    const fetchingProfile = new Promise<void>((resolve) => {
        const fetching = $ndk.subscribe(
            {kinds: [0], authors:[$currentUser?.pubkey]},
            { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY, closeOnEose: true },
            relaySet
        );

        fetching.on("event", (e) => {
            processUserProfile(e, userProfile)
            categories = $userProfile!.categories ?? [];
            resolve();
        });
        fetching.on("eose", () => {
            resolve();
        })
    });

    function emptyProfile() {
        if ($userProfile === undefined) return true;
        if (!$userProfile.name || $userProfile.name.length === 0) return true;

        return false;
    }

    async function save() {
        if (emptyProfile()) {
            if (!confirm("Your current profile could not be found, if you continue your current profile will be overwritten. Continue?")) return;
        }

        saving = true;
        try {
            $userProfile.display_name ??= $userProfile.name;
            const profile = new NDKEvent($ndk, {
                kind: 0,
                content: serializeProfile($userProfile)
            } as NostrEvent);
            if (categories.length > 0) {
                for (const category of categories) {
                    profile.tags.push(["c", category]);
                }
            }
            await profile.publish(relaySet);
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

{#await fetchingProfile}
    <div class="loading loading-lg"></div>
{:then}
    {#if !$userProfile || $userProfile.name?.toString().length === 0 && !$userProfile.picture}
        <div class="alert alert-neutral text-warning border border-warning font-light">
            <Warning class="w-8 h-8" />
            <div class="flex flex-col gap-2">
                <p>
                    <b class="font-bold">We couldn't find your current profile.</b>
                </p>

                If you currently have a nostr profile make
                sure you connect to a relay that has it before proceeding.
            </div>
        </div>
    {/if}

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

                <CategorySelector bind:categories show={false} />
            </div>
        </section>
    </div>

    <div class="flex flex-col-reverse sm:flex-row sm:gap-2 max-sm:items-stretch w-full justify-end">
        <button class="button px-10 sm:py-3" on:click={saveClicked}>
            {#if saving}
                <span class="loading loading-sm"></span>
            {:else}
                Save
            {/if}
        </button>
    </div>
{/await}

{#if $debugMode}
    <pre>{JSON.stringify($userProfile, null, 4)}</pre>
{/if}