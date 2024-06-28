<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { NDKRelaySet, NDKSubscription, NostrEvent } from "@nostr-dev-kit/ndk";
	import { toast } from "svelte-sonner";
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Button } from "$components/ui/button";
	import { appMobileView } from "$stores/app";
	import { Actions, ActionsGroup, ActionsButton } from "konsta/svelte";
	import { Play, Stop } from "phosphor-svelte";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import LnQrModal from "$modals/LnQrModal.svelte";
	import TtsModal from '$modals/TTSModal.svelte';
    import { loadedMedia, togglePause } from '$stores/media';

    export let article: NDKArticle;
    export let supported: boolean;

    let recordingEvents: NDKEventStore<NDKEvent> | undefined;

    $ndk.fetchEvents({ kinds: [5250 as number], ...article.filter()})
        .then((events) => {
            console.log({events})
            if (events.size === 0) return;
            const eventIds = Array.from(events).map(e => e.id);
            console.log({eventIds})
            recordingEvents = $ndk.storeSubscribe({ "#e": eventIds }, { closeOnEose: true })
        });

    // const dvms = $ndk.storeSubscribe({ kinds: [NDKKind.AppHandler], "#k": ["5250"]});
    // const dvmProfiles = derived(dvms, ($dvms) => {
    //     console.log($dvms)
    //     return $dvms
    //         .map(dvm => {
    //             try {
    //                 const content = JSON.parse(dvm.content) as NDKUserProfile;
    //                 if (content.name && content.display_name)
    //                     return content;
    //             } catch (e) {
    //                 console.error(e, dvm.content);
    //             }
    //         })
    //         .filter(p => !!p);
    // });

    let dvmSub: NDKSubscription | undefined;

    let isLoaded: boolean;

    $: isLoaded = $loadedMedia[0]?.eventId === article.id;

    async function togglePlay() {
        if (isLoaded) {
            togglePause();
            return;
        }
        
        openModal(TtsModal, { event: article })
        return;
        
        const relay = $ndk.pool.getRelay("wss://relay.damus.io")
        const relaySet = new NDKRelaySet(new Set([relay]), $ndk);
        const e = new NDKEvent($ndk, {
            kind: 5250,
        } as NostrEvent)
        e.tags.push(["i", article.id, "event"]);
        e.tags.push(["param", "language", "en"]);
        e.tags.push(["relays", "wss://relay.primal.net", "wss://relay.f7z.io", "wss://nos.lol"])
        if (article.title) e.tags.push(["title", article.title])
        if (article.summary) e.tags.push(["summary", article.summary])
        e.tags.push(["author", article.pubkey])
        await e.sign();

        dvmSub = $ndk.subscribe(e.filter(), {}, relaySet);

        dvmSub.on("event", (e) => {
            console.log(e);

            if (e.kind === 7000) {
                toast.success(e.content);
            }

            const amount = e.getMatchingTags("amount")[0];
            console.log(amount);
            openModal(LnQrModal, { title: "Pay DVM", satAmount: parseInt(amount[1])/1000, pr: amount[2] })
        });
        
        await e.publish();
        
        // if (playing) {
        //     stop();
        // } else if (voice) {
        //     play();
        // } else {
        //     chooseVoice();
        // }
        // playing = !playing;
    }
</script>

<Button variant="secondary" on:click={togglePlay}>
    {#if isLoaded}
        <Stop />
    {:else}
        <Play />
    {/if}
</Button>

{#if $appMobileView}
    <Actions
    >
        <ActionsGroup class="max-h-[50vh] overflow-y-auto scrollbar-hide">
            <!-- {#each $dvmProfiles as dvm}
                <ActionsButton onClick={() => {}}>
                    {#if dvm.image}<Avatar src={dvm.image} />{/if}
                    {dvm.displayName??dvm.name}
                </ActionsButton>
            {/each} -->
        </ActionsGroup>
    </Actions>
{:else}
{/if}