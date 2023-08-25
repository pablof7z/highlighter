<script lang="ts">
	import { NDKDVMJobResult, NDKDVMJobFeedback, NDKDVMRequest, NDKAppHandlerEvent, type NDKUserProfile, NDKKind, NDKEvent } from "@nostr-dev-kit/ndk";
	import JobResultRow from "./JobResultRow.svelte";
	import { appHandlers } from "$stores/nip89";
	import { findNip89Event } from "$utils/nip89";
	import { Avatar, EventContent, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import ndk from "$stores/ndk";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import JobStatusLabel from "./JobStatusLabel.svelte";
	import PaymentRequiredButton from "./PaymentRequiredButton.svelte";
	import { ElementConnector } from "@kind0/ui-common";
	import EventCard from "./EventCard.svelte";

    export let jobRequest: NDKDVMRequest;
    export let dvmPubkey: string;
    export let events: NDKEventStore<NDKEvent>;
	export let parentElement: HTMLElement;

    let nip89event: NDKAppHandlerEvent | undefined;

    let paymentPending = false;
    let paymentPendingEvent: NDKDVMJobFeedback | undefined;

    $: if ($appHandlers && !nip89event) {
        nip89event = findNip89Event(dvmPubkey, jobRequest.kind!);
        console.log({nip89event})
        if (nip89event) {
            nip89event.fetchProfile().then((p) => {
                profile = p;
                console.log(`here is`, profile);
            });
        }
    }

    // check if the most recent event has an amount tag
    $: paymentPending = $events[0]?.getMatchingTags('amount').length > 0;
    $: paymentPendingEvent = $events.find((event) => event.getMatchingTags('amount').length > 0);

    let profile: NDKUserProfile | undefined;
    let fetchingProfile = false;

	let fetchProfilePromise = new Promise((resolve, reject) => {
        nip89event = findNip89Event(dvmPubkey, jobRequest.kind!);

		if (nip89event) {
			nip89event.fetchProfile().then((p) => {
				profile = p;
				resolve(p);
			});
		} else {
			const user = $ndk.getUser({ hexpubkey: dvmPubkey });
			if (user) {
				user.fetchProfile().then((p) => {
					profile = user.profile;
					resolve(profile);
				});
			}
		}
	});

    $: if (nip89event && !profile && !fetchingProfile) {
        fetchingProfile = true;
        nip89event.fetchProfile().then((p) => {
			console.log('here, setting fetchingProfile to false')
            fetchingProfile = false;
            profile = p;
        });
    }

    let jobResults: NDKDVMJobResult[] = [];
    let mostRecentEvent: NDKEvent | undefined;

    $: jobResults = $events
        .filter((event) => event.kind! >= 6000 && event.kind! < 7000)
        .map((event) => NDKDVMJobResult.from(event));

    $: mostRecentEvent = $events.sort((a, b) => {
        return b.created_at! - a.created_at!;
    })[0];

    let hasJobResult = false;

    $: hasJobResult = jobResults.length > 0;

    let containerClass: string = "";

    $: if (paymentPending && paymentPendingEvent) {
        containerClass = "";
    } else if (!fetchingProfile) {
        containerClass = "col-span-2";
    }

    let hover = false;

</script>

{#await fetchProfilePromise}
    <span class="loading loading-infinity loading-lg"></span>
{:then}
    <ElementConnector from={parentElement} class={containerClass}>
        {#if paymentPending && paymentPendingEvent}
            {#if nip89event}
                <EventCard
                    event={mostRecentEvent}
                >
                    <div class="flex flex-row gap-4 font-normal text-sm" slot="header">
                        <Avatar ndk={$ndk} userProfile={profile} class="w-24 h-24 rounded-lg hidden md:block" />

                        <div class="flex flex-col divide-y divide-base-300 flex-grow">
                            <div class="truncate max-w-xs inline-block pb-1.5">
                                <Name ndk={$ndk} userProfile={profile} class="font-semibold text-lg text-base-100-content" />
                            </div>

                            <div class="pt-3">
                                {profile?.about}
                            </div>
                        </div>
                    </div>

                    <div class="flex flex-col items-center md:flex-row gap-4">
                        <div class="flex flex-col md:flex-row gap-8 flex-grow">
                            <div class="flex flex-col divide-y divide-base-300 flex-grow">
                                {#if mostRecentEvent.content.length > 0}
                                    <div class="pt-4 text-base-100-content text-lg overflow-x-hidden">
                                        <EventContent
                                            ndk={$ndk}
                                            event={paymentPendingEvent}
                                        />
                                    </div>
                                {:else}
                                    &nbsp;
                                {/if}
                            </div>
                        </div>

                        <div class="p-3 w-full md:w-fit self-end">
                            <PaymentRequiredButton
                                event={paymentPendingEvent}
                                class="!uppercase whitespace-nowrap flex-nowrap !text-base w-full"
                            />
                        </div>

                    </div>


                </EventCard>
            {:else}
                no nip89 event found
            {/if}
        {:else if !fetchingProfile}
            <EventCard
                event={mostRecentEvent}
                userProfile={profile}
                on:mouseover={() => { hover = true; }}
                on:mouseleave={() => { hover = false; }}
            >
                <div slot="headerRight" class="whitespace-nowrap">
                    <JobStatusLabel status={mostRecentEvent?.tagValue('status')??""} />
                </div>

                {#if hasJobResult}
                    {#each jobResults as jobResult (jobResult.id)}
                        <JobResultRow event={jobResult} imageClass="max-h-48 rounded-lg" />
                    {/each}
                {:else}
                    <EventContent ndk={$ndk} event={mostRecentEvent} />
                {/if}
            </EventCard>
        {/if}
    </ElementConnector>
{/await}

<style>
	section > * {
		@apply p-3;
	}

    :global(.connector) {
        @apply border-l-8 border-l-base-200;
        @apply border-b-8 border-b-base-200;
    }
</style>