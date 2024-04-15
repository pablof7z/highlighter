<script lang="ts">
	import { RelativeTime, bunkerNDK, ndk } from "@kind0/ui-common";
	import { type Hexpubkey, NDKUser, type NDKUserProfile, NDKEvent, NDKPrivateKeySigner, NDKNostrRpc, type NDKRpcResponse } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
    import { createEventDispatcher } from "svelte";
    import createDebug from "debug";

    const debug = createDebug("HL:nsecbunker");

    export let provider: NDKEvent;

    export let username: string | undefined;
    export let selected = false;
    export let domain: string | undefined = undefined;

    export let valid: boolean | undefined = undefined;
    export let pubkey = provider.pubkey;

    let lastSeenAt: number = 0;

    const dispatch = createEventDispatcher();

    let profile: NDKUserProfile;

    let pinged: boolean | undefined;

    async function ping() {
        await $bunkerNDK.connect();
        const signer = NDKPrivateKeySigner.generate();
        const localUser = await signer.user();
        const rpc = new NDKNostrRpc($bunkerNDK, signer, debug);

        await rpc.subscribe({
            kinds: [24133 as number, 24134 as number],
            "#p": [localUser.pubkey],
        });

        return new Promise((resolve) => {
            debug("pinging", pubkey);
            rpc.sendRequest(pubkey, "ping", undefined, undefined, (res: NDKRpcResponse) => {
                pinged = true;
                resolve(true);
            });
        });
    }

    async function validateNsecbunkerProvider(pubkey: Hexpubkey) {
        try {
            profile = JSON.parse(provider.content);
            profile.image ??= profile.picture;
            const nip05 = profile?.nip05;
            const [ username, d ] = nip05?.split("@") ?? [];
            domain = d;

            // If the username is not "_", it's not a valid root nsecbunker
            if (username !== "_") return false;

            // Validate the nip05 points to this pubkey
            if (!await validateNip05(pubkey, domain)) {
                console.log('invalid nip05');
                return false;
            }

            // Validate it has emitted an event in the past 1 hour
            const e = await $ndk.fetchEvents({
                authors: [pubkey], since: Math.floor(Date.now() / 1000) - (3600*240), limit: 1
            }, { groupable: true, groupableDelay: 100 });

            // get the most recent created_at returned
            for (const event of e) {
                if (event.created_at! > (lastSeenAt ?? 0)) {
                    lastSeenAt = event.created_at!;
                }
            }

            if (!await ping()) return false;

            if (e.size === 0) return false;

            return true;
        } catch { return false }
    }

    async function validateNip05(pubkey: Hexpubkey, domain: string) {
        debug("validating nip05", pubkey, domain)
        const user = await NDKUser.fromNip05(domain, $ndk);
        debug("user", user);

        return !!(user && user.pubkey === pubkey);
    }

    onMount(() => {
        validateNsecbunkerProvider(pubkey).then(res => valid = res);
    })

    function clicked() {
        dispatch("click", { pubkey, domain });
    }
</script>

<p>{pubkey.slice(0,8)} {valid}</p>

{#if valid && profile}
    <li class:active={selected} class="overflow-x-clip">
        <button
            class="border-b flex border-white/10 items-center text-left gap-4 px-4 py-3 w-full"
            on:click={clicked}
        >
            <img src={profile.image??"https://cdn.satellite.earth/fb0e24f6cd8f581c8873e834656163dd497dce47dab8b878d73caf4aae3def89.png"} class="w-12 h-12 p-0 object-cover rounded flex-none overflow-clip bg-base-300" alt="" />

            <div class="flex flex-col gap-1 whitespace-nowrap items-start grow">
                <span class="mr-2 font-normal text-white">
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