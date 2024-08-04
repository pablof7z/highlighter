<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { NDKRelaySet, NDKSubscription, NostrEvent } from "@nostr-dev-kit/ndk";
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import { Button } from "$components/ui/button";
	import { appMobileView } from "$stores/app";
	import { Actions, ActionsGroup, ActionsButton } from "konsta/svelte";
	import { Play, Stop } from "phosphor-svelte";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import TtsModal from '$modals/TTSModal.svelte';
    import { loadedMedia, togglePause } from '$stores/media';

    export let article: NDKArticle;
    /**
     * When this function is set, it will be called back instead
     * of showing the TTS modal.
     */
    export let onShow: (() => void) | undefined = undefined;

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
        
        if (onShow) {
            onShow();
        } else {
            openModal(TtsModal, { event: article })
        }
    }
</script>

<Button {...{variant: "secondary", ...$$props}} on:click={togglePlay}>
    {#if isLoaded}
        <Stop />
    {:else}
        <Play class="sm:w-5 w-3.5 sm:h-5 h-3.5" weight="fill" />
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