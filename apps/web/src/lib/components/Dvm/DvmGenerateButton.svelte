<script lang="ts">
	import Avatar from '$components/User/Avatar.svelte';
import Name from '$components/User/Name.svelte';
import { ndk } from "$stores/ndk.js";
	import { NDKAppHandlerEvent, NDKDVMJobFeedback, NDKDVMJobResult, NDKEvent, NDKKind, NDKUser, type NDKTag, type NostrEvent, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { CaretDown, MagicWand } from "phosphor-svelte";
	import { derived, type Readable } from "svelte/store";
    import { userAppHandlers } from '$stores/session';
    import DvmProfile from "./DvmProfile.svelte";

    export let kind: NDKKind;
    export let inputs: NDKTag[];
    let generating = false;

    let dvm: NDKAppHandlerEvent;
    let dvmProfile: NDKUserProfile;
    const dvmId = $userAppHandlers.get(kind)?.values().next().value;
    const dvmPubkey = dvmId ? dvmId.split(':')?.[1] : undefined;
    if (dvmId) {
        $ndk.fetchEvent(dvmId).then((e) => {
            if (e) {
                dvm = NDKAppHandlerEvent.from(e);
                dvm.fetchProfile().then((p) => {
                    if (p) dvmProfile = p;
                })
            }
        });
    }

    let responses: Readable<NDKEvent[]>;
    let feedbacks: Readable<NDKDVMJobFeedback[]>;
    let results: Readable<NDKDVMJobResult[]>;

    async function start() {
        const req = new NDKEvent($ndk, {
            kind,
            tags: [
                ...inputs.map(input => ["i", ...input])
            ]
        } as NostrEvent);

        if (dvmPubkey) req.tags.push(["p", dvmPubkey]);

        await req.sign();
        responses = $ndk.storeSubscribe({
            ...req.filter()
        }, {groupable: false})
        generating = true;
        await req.publish()

        feedbacks = derived(responses, $responses => {
            return $responses.filter(e => e.kind === NDKKind.DVMJobFeedback)
                .map(e => NDKDVMJobFeedback.from(e))
        })

        results = derived(responses, $responses => {
            return $responses.filter(e => e.kind === kind+1000)
                .map(e => NDKDVMJobResult.from(e))
        })
    }
</script>

{#if !generating}
    <button class="button join-item flex font-normal items-center gap-4 self-start" on:click={start}>
        <MagicWand class="text-black w-6 h-6" />
        <div class="flex flex-col items-start">
            Autogenerate
        </div>
    </button>
{:else if $feedbacks && $results && $feedbacks.length === 0 && $results.length === 0}
    <div class="flex flex-row gap-2">
        <div class="text-neutral-500">
            Generating... <span class="animate-pulse">🔮</span>
        </div>
    </div>
{:else}
{$responses.length}
    {#each $responses as r}
        {JSON.stringify(r.rawEvent(), null, 2)}
    {/each}
    {#if $results}
        {#each $results as result}
        {JSON.stringify(result.rawEvent(), null, 2)}
            <!-- <DvmProfile event={result} let:dvmProfile let:fetching>
                <div class="flex flex-row gap-2">
                    <Avatar userProfile={dvmProfile} {fetching} type="square" size="small"/>
                    <div class="text-neutral-500">
                        {result.content}
                    </div>
                </div>
            </DvmProfile> -->
        {/each}
    {/if}
{/if}