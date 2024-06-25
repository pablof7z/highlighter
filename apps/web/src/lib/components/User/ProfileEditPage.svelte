<script lang="ts">
	import EditableAvatar from '$components/User/EditableAvatar.svelte';
    import currentUser from '$stores/currentUser';
    import { debugMode, processUserProfile, userProfile } from '$stores/session';
    import { createEventDispatcher, onMount } from 'svelte';
	import { NDKEvent, serializeProfile, type NostrEvent, NDKRelaySet, getRelayListForUser, NDKRelay } from '@nostr-dev-kit/ndk';
    import { Image, Warning } from "phosphor-svelte";
	import CategorySelector from '$components/Forms/CategorySelector.svelte';
	import { ndk } from '$stores/ndk';
	import { newToasterMessage } from '$stores/toaster';
	import { Input } from '$components/ui/input';
	import BlossomUpload from '$components/buttons/BlossomUpload.svelte';
	import { defaultRelays } from '$utils/const';
	import Button from '$components/ui/button/button.svelte';

    export let forceSave = false;

    const dispatch = createEventDispatcher();

    export let saving = false;

    let categories: string[] = [];

    onMount(() => {
        if ($userProfile) categories = $userProfile.categories ?? [];
    })

    const relaySet = NDKRelaySet.fromRelayUrls([
        // "wss://purplepag.es/", "wss://profiles.nos.lol", "wss://relay.damus.io", "wss://relay.primal.net",
        ...defaultRelays
    ], $ndk);
    for (const relay of $ndk.pool.connectedRelays()) {
        relaySet.addRelay(relay);
    }

    getRelayListForUser($currentUser?.pubkey!, $ndk).then((relayList) => {
        if (!relayList) return;
        for (const writeRelay of relayList.writeRelayUrls) {
            const r = new NDKRelay(writeRelay, undefined);
            relaySet.addRelay(r);
        }
    })

    // just to be on the safe-side, try to load this user's profile again
    const fetchingProfile = new Promise<void>((resolve) => {
        const fetching = $ndk.subscribe(
            {kinds: [0], authors:[$currentUser?.pubkey!]},
            // { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY },
            // relaySet
        );

        fetching.on("event", (e) => {
            processUserProfile(e, userProfile)
            categories = $userProfile!.categories ?? [];
            resolve();
            setVars();
        });
        fetching.on("eose", () => {
            resolve();
            setVars();
        })
    });

    function setVars() {
        name = $userProfile?.displayName ?? $userProfile?.name ?? "";
        banner = $userProfile?.banner ?? "";
        picture = $userProfile?.image ?? "";
        about = $userProfile?.about ?? "";
        lud16 = $userProfile?.lud16 ?? "";
    }

    function emptyProfile() {
        if ($userProfile === undefined) return true;
        if (!$userProfile.displayName || $userProfile.displayName.length === 0) return true;

        return false;
    }

    async function save() {
        if (emptyProfile()) {
            if (!confirm("Your current profile could not be found, if you continue your current profile will be overwritten. Continue?")) return;
        }

        saving = true;
        try {
            let newProfile = {
                ...$userProfile,
                displayName: name,
                name: name,
                image: picture,
                banner: banner,
                about: about,
                lud16: lud16,
            };
            if (name !== "") {
                newProfile.displayName = name;
                newProfile.name = name;
            }
            if (picture !== "") newProfile.image = picture;
            if (banner !== "") newProfile.banner = banner;
            if (about !== "") newProfile.about = about;
            if (lud16 !== "") newProfile.lud16 = lud16;

            console.log("UPDATING PROFILE FROM " + JSON.stringify($userProfile) + " TO " + JSON.stringify(newProfile) + " FOR " + $currentUser!.pubkey);
            console.log("RELAYS", Array.from(relaySet.relays).map(r => r.url));

            if (Object.keys(newProfile).length === 0) {
                console.log("Refusing to update profile");
                newToasterMessage("Profile not updated", "error");
                return;
            }

            const profile = new NDKEvent($ndk, {
                kind: 0,
                content: serializeProfile(newProfile)
            } as NostrEvent);
            if (categories.length > 0) {
                for (const category of categories) {
                    profile.tags.push(["c", category]);
                }
            }
            await profile.publish(relaySet);
            dispatch('saved');
        } catch (e) {
            console.error(e);
        } finally {
            saving = false;
        }
    }

    async function saveClicked() {
        await save();
    }

    $: if (forceSave && !saving) {
        saving = true;
        forceSave = false;
        save();
    }

    let name: string = "";
    let banner: string;
    let picture: string;
    let about: string;
    let lud16: string;

    setVars();
</script>

{#await fetchingProfile}
    <div class="loading loading-lg"></div>
{:then}
    {#if name === "" && picture === ""}
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
        <div class="relative w-full h-[20rem] overflow-hidden rounded">
            <BlossomUpload bind:url={banner} class="w-full">
                {#if $userProfile?.banner}
                    <img src={$userProfile?.banner} class="w-full h-full object-cover object-top lg:rounded" alt={$userProfile?.name}>
                    <div class="flex flex-col items-center gap-4 text-base opacity-70 text-foreground z-40">
                        <Image size={42} />
                        Upload a Cover Image
                    </div>
                {:else}
                    <div class="h-[25dvh] w-full input-background rounded flex items-center justify-center">
                        <div class="flex flex-col items-center gap-4 text-base opacity-70 text-foreground">
                            <Image size={42} />
                            Upload a Cover Image
                        </div>
                    </div>
                {/if}
            </BlossomUpload>
        </div>

        <div class="mb-10 -mt-7 z-20">
            <div class="flex flex-row gap-4 items-end">
                <div class="flex-none">
                    <EditableAvatar
                        url={picture}
                        on:uploaded={(e) => { picture = e.detail }}
                        class="w-24 h-24 rounded-full"
                    />
                </div>

                <Input bind:value={name} placeholder="Name" class="text-lg text-foreground font-medium" />
            </div>

        </div>

        <section class="settings">
            <div class="field">
                <div class="title">About you</div>
                <Input bind:value={about} placeholder="About" class="text-sm" />
            </div>

            <div class="field">
                <div class="title">LN Wallet</div>
                <Input bind:value={lud16} placeholder="LN Wallet" class="text-sm" />
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
        <Button size="lg" on:click={saveClicked}>
            {#if saving}
                <span class="loading loading-sm"></span>
            {:else}
                Save
            {/if}
        </Button>
    </div>
{/await}

{#if $debugMode}
    <pre>{JSON.stringify($userProfile, null, 4)}</pre>
{/if}