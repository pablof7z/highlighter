<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import Nip89Form from "./Nip89Form.svelte";
	import { NDKAppHandlerEvent, NDKEvent, NDKPrivateKeySigner, type NDKUserProfile, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { nip19 } from "nostr-tools";
	import ndk from "$stores/ndk";
	import type { Nip90Param } from "$utils/nip90";

    export let nip89event: NDKAppHandlerEvent | undefined = undefined;

    const dispatch = createEventDispatcher();

    let name = '';
    let pubkey = nip89event?.pubkey ?? '';
    let image = '';
    let supportedKind: number;
    let about = '';
    let nip90Params: Record<string, Nip90Param[]> = {};

    let nip89Event: NDKEvent | null;
    let rawEvent: NostrEvent | null;

    if (nip89event) {
        const kTag = nip89event.tagValue("k");

        if (kTag) supportedKind = parseInt(kTag);

        nip89event.fetchProfile().then((profile) => {
            name = profile?.name ?? "";
            image = profile?.image ?? "";
            about = profile?.about ?? "";
        });
    }

    async function formDone() {
        const dvmProfile: NDKUserProfile = {
            name,
            image,
            about,
            nip90Params: nip90Params as any
        }

        // check if there is an event we should overwrite
        nip89Event = await $ndk.fetchEvent({
            kinds: [31990 as number],
            "#k": [supportedKind.toString()],
            authors: [pubkey]
        });

        if (!nip89Event) {
            nip89Event = new NDKEvent($ndk, {
                kind: 31990,
                pubkey,
            } as NostrEvent);
        }

        nip89Event.content = JSON.stringify(dvmProfile);
        nip89Event.created_at = Math.floor(Date.now() / 1000);
        nip89Event.removeTag('k');
        nip89Event.tags.push([ 'k', supportedKind.toString() ]);
        nip89Event.sig = undefined;

        await nip89Event.toNostrEvent();

        nip89Event = nip89Event;
        rawEvent = nip89Event.rawEvent();
    }



    function cancel() {
        dispatch('cancel')
    }

    let dvmPK: string;

    async function sign() {
        let pk = dvmPK;

        if (dvmPK.startsWith("nsec")) {
            pk = nip19.decode(dvmPK)?.data as string;
        }

        const signer = new NDKPrivateKeySigner(pk);
        const user = await signer.user();
        const hexpubkey = user.pubkey;

        if (hexpubkey !== pubkey) {
            alert('The pubkey you entered does not match the one in your private key, pubkey in private key: ' + hexpubkey);
            return;
        }

        await nip89Event!.sign(signer);
        nip89Event = nip89Event;
    }

    async function publish() {
        await nip89Event!.publish();

        dispatch("done");
    }
</script>

<div class="card !rounded-box">
    <div class="card-body gap-8">
        {#if !nip89Event}
            <Nip89Form
                bind:name
                bind:pubkey
                bind:image
                bind:supportedKind
                bind:about
                bind:nip90Params
                on:done={formDone}
                on:cancel={cancel}
            />
        {:else}
            <h3 class="text-2xl text-base-100-content">Sign and publish this event</h3>
            <div class="bg-base-300 text-base-300-content rounded-box p-4 overflow-auto">
                <pre>{JSON.stringify(rawEvent, null, 4)}</pre>
            </div>

            {#if nip89Event.sig}
                <button class="btn btn-primary btn-lg" on:click={publish}>
                    Publish
                </button>
            {/if}

            <div class="flex flex-col items-start gap-2">
                <h3 class="text-2xl text-base-100-content">Enter your DVM private key to sign it here</h3>
                <h4>
                    or copy the event, sign it offline and publish it manually
                </h4>
            </div>

            <div class="flex flex-row gap-4">
                <input class="input input-bordered w-full" bind:value={dvmPK} placeholder="private key in nsec or hex format" />

                <button class="btn btn-neutral" on:click={sign}>
                    Sign
                </button>
            </div>
        {/if}
    </div>
</div>