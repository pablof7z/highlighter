<script lang="ts">
	import { type Hexpubkey, NDKUser, type NDKUserProfile, NDKEvent, NDKPrivateKeySigner, NDKNostrRpc, type NDKRpcResponse } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
    import { createEventDispatcher } from "svelte";
    import createDebug from "debug";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import { bunkerNDK, ndk } from "$stores/ndk";

    const debug = createDebug("HL:nsecbunker");

    export let provider: NDKEvent;

    export let username: string | undefined;
    export let selected = false;
    export let domain: string | undefined = undefined;

    export let valid: true | string = 'not checked';
    export let pubkey = provider.pubkey;

    export let rpc: NDKNostrRpc;

    let lastSeenAt: number = 0;

    const dispatch = createEventDispatcher();

    let profile: NDKUserProfile;

    let pinged: boolean | undefined;

    async function ping() {
        return new Promise((resolve) => {
            rpc.sendRequest(pubkey, "ping", undefined, undefined, (res: NDKRpcResponse) => {
                pinged = true;
                resolve(true);
            });
        });
    }

    async function validateNsecbunkerProvider(pubkey: Hexpubkey): Promise<true | string> {
        try {
            profile = JSON.parse(provider.content);
            profile.image ??= profile.picture;
            const nip05 = profile?.nip05;
            const [ username, d ] = nip05?.split("@") ?? [];
            domain = d;


            // If the username is not "_", it's not a valid root nsecbunker
            if (username !== "_") return `username is ${username}`;

            // Validate the nip05 points to this pubkey
            if (!await validateNip05(pubkey, domain)) {
                return 'nip05 does not point to this pubkey';
            }

            const findRecentEventPromise = new Promise<void>((resolve) => {
                $bunkerNDK.fetchEvent(
                    { authors: [pubkey], since: Math.floor(Date.now() / 1000) - 43200, limit: 1 },
                    { groupable: false },
                ).then(e => {
                    if (e) {
                        resolve();
                    }
                })
            });

            await Promise.race([
                new Promise<void|string>((resolve, reject) => setTimeout(() => reject("timeout"), 5000)),
                findRecentEventPromise,
                ping()
            ]).then(() => {
                valid = true
            }).catch((e: any) => {
                console.error(e);
                valid = e
            });

            return valid;
        } catch (e: any) {
            console.trace(e);
            return e.message??e.toString();
        }
    }

    async function validateNip05(pubkey: Hexpubkey, domain: string) {
        const user = await NDKUser.fromNip05(domain, $ndk, true);

        return !!(user && user.pubkey === pubkey);
    }

    onMount(async () => {
        valid = await validateNsecbunkerProvider(pubkey);
    })

    function clicked() {
        dispatch("click", { pubkey, domain });
    }
</script>

{#if valid === true && profile}
    <li class:active={selected} class="overflow-x-clip">
        <button
            class="border-b flex border-white/10 items-center text-left gap-4 px-4 py-3 w-full"
            on:click={clicked}
        >
            <img src={profile.image??"https://cdn.satellite.earth/fb0e24f6cd8f581c8873e834656163dd497dce47dab8b878d73caf4aae3def89.png"} class="w-12 h-12 p-0 object-cover rounded flex-none overflow-clip bg-foreground/20" alt="" />

            <div class="flex flex-col gap-1 whitespace-nowrap items-start grow">
                <span class="mr-2 font-normal text-foreground">
                    {#if username}<span class="!font-normal opacity-40">{username}@</span>{/if}{domain}
                </span>
                <!-- if lastseen is older than 2 days show the date -->
                {#if pinged === false}
                    <span class="text-xs text-error">
                        Offline
                        {#if lastSeenAt}
                            <span class="text-xs opacity-50">
                                &mdash; Last seen <RelativeTime timestamp={lastSeenAt*1000} />
                            </span>
                        {/if}
                    </span>
                {/if}
                <!-- <div class="text-xs w-full truncate text-ellipsis opacity-50">{profile.about ?? ""}</div> -->
            </div>
        </button>
    </li>
{/if}