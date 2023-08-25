<script lang="ts">
	import { jobRequestKinds, kindToText } from "$utils";
	import EventCard from "./EventCard.svelte";
	import { nip19 } from "nostr-tools";
	import ndk from "$stores/ndk";
	import { onDestroy } from "svelte";
	import { derived, type Readable, type Writable } from "svelte/store";
	import { type NDKDVMRequest, type NDKTag, type NDKEvent, NDKDVMJobResult, NDKKind, NDKDVMJobFeedback } from "@nostr-dev-kit/ndk";
	import { Avatar, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import JobTypeIcon from "./JobTypeIcon.svelte";
	import JobDvmEventsCard from "./JobDvmEventsCard.svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { ElementConnector } from "@kind0/ui-common";
	import AddJobButton from "./AddJobButton.svelte";

	export let jobRequest: NDKDVMRequest;
	export let compact = false;

	const kind = jobRequest.kind!;

	let inputs: NDKTag[] = [];

	inputs = jobRequest.getMatchingTags('i');

	let currentElement: HTMLElement | undefined = undefined;

	function encodeInput(input: NDKTag) {
		try {
			const id = input[1];
			let encodedId;

			if (id.match(/:/)) {
				const [kind, pubkey, identifier] = id.split(/:/);
				encodedId = nip19.naddrEncode({
					kind: parseInt(kind),
					pubkey,
					identifier
				});
			} else {
				encodedId = nip19.noteEncode(id);
			}

			return encodedId;
		} catch (e) {
			return '';
		}
	}

    const results = $ndk.storeSubscribe(
        {
            kinds: [7, 5, 7000 as number, jobRequest.kind!+1000],
            ...jobRequest.filter(),
        },
        { closeOnEose: false, groupableDelay: 1000 },
    );

    const dependentJobs = $ndk.storeSubscribe({
        kinds: jobRequestKinds,
        "#i": [ jobRequest.tagId()]
    }, { closeOnEose: false, groupableDelay: 1000 });

	onDestroy(() => {
		results.unsubscribe();
		dependentJobs.unsubscribe();
	});

	let dvms: Record<string, NDKEventStore<NDKEvent>> = {};

	$: for (const result of $results) {
		const key = result.pubkey;
		if (!dvms[key]) {
			dvms[key] = derived(results, (results) => results.filter((e) => e.pubkey === key));
		}
	}

	let addJobHover = false;
	let cardHover = false;
    let extraJobInfoText: string = "";

    $: if (jobRequest.kind === 5003) {
        const langTag = jobRequest.getMatchingTags("param")
            .find((t: NDKTag) => ['lang', 'language'].includes(t[1]));

        if (langTag) extraJobInfoText = `to ${langTag[2]}`;
    }
</script>

<EventCard
	event={jobRequest}
	href={`/jobs/${jobRequest.encode()}`}
	on:mouseover={() => (cardHover = true)}
	on:mouseout={() => (cardHover = false)}
>
	<div class="flex w-full flex-row gap-4" slot="header">
		<div class="flex w-full flex-row gap-2 text-sm font-normal">
			<Avatar ndk={$ndk} pubkey={jobRequest.pubkey} class="h-8 w-8 rounded-full whitespace-nowrap" />
			<div class="
				flex w-full flex-row justify-between gap-2 xl:flex-row xl:items-center xl:justify-start
			">
				<span class="md:inline-block max-w-xs whitespace-nowrap truncate hidden" style="overflow-wrap: anywhere;">
					<Name ndk={$ndk} pubkey={jobRequest.pubkey} class="font-semibold text-base-100-content" />
				</span>
				<span class="hidden md:inline-block">requested</span>
				<a href={`/jobs/${jobRequest.encode()}`} class="flex flex-row items-center gap-1">
					<JobTypeIcon {kind} />
					<span class="text-base-100-content">
						{kindToText(kind)}
					</span>
				</a>
                {extraJobInfoText}
			</div>
		</div>
	</div>

	<div class="flex flex-col gap-2 whitespace-normal">
		{#each inputs as input}
			<div class="flex flex-row items-baseline gap-2">
				<h3 class="font-semibold">
					<span class="text-lg">INPUT</span>
					{#if input[2]}
						<span class="font-normal opacity-50">({input[2]})</span>
					{/if}
				</h3>
				{#if input[2] === 'job'}
					<div class="flex flex-row gap-2">
						<span class="hidden md:inline">output of</span>
						<a href="/jobs/{encodeInput(input)}" class="text-accent">
							#{input[1]?.slice(0, 8)}
						</a>
						(job chaining)
					</div>
				{:else if input[2] === 'event'}
					#{input[1]?.slice(0, 8)}
				{:else}
					<p style="overflow-wrap: anywhere;">
						{input[1]}
					</p>
				{/if}
			</div>
		{/each}
	</div>

	<div
		class="relative
			flex flex-row items-center gap-8
		" bind:this={currentElement}
	>
		<AddJobButton
			{jobRequest}
			{dependentJobs}
		/>

		{#if Object.keys(dvms).length > 0}
			{Object.keys(dvms).length} DVMs replied
		{:else if jobRequest.created_at > Math.floor(Date.now() / 1000) - 300}
			<span class="loading"></span>
		{:else}
			No DVMs replied
		{/if}
	</div>
</EventCard>

{#if Object.keys(dvms).length > 0}
	<div class="indented flex flex-col gap-4">
		<div class="section-title text-base-100-content">
			{Object.keys(dvms).length} {Object.keys(dvms).length === 1 ? 'DVM' : 'DVMs'}
			replied
		</div>
		{#each Object.entries(dvms) as [dvmPubkey, events]}
			<JobDvmEventsCard {jobRequest} {dvmPubkey} {events} parentElement={currentElement} />
		{/each}
	</div>
{/if}

{#if $dependentJobs.length > 0}
	<div class="indented flex flex-col gap-4 divide-y divide-base-300 bg-base-100">
		<div class="section-title text-base-100-content">
			{Object.keys($dependentJobs).length}
			chained
			{Object.keys($dependentJobs).length === 1 ? 'job' : 'jobs'}
		</div>

		{#each $dependentJobs as event}
			{#if event}
				<ElementConnector from={currentElement}>
					<svelte:self jobRequest={event} {compact} />
				</ElementConnector>
			{:else}
				no event?
			{/if}
		{/each}
	</div>
{/if}

<style>
	.indented {
		@apply ml-10;
	}

	.section-title {
		@apply text-base-100-content font-semibold text-2xl pl-4;
	}
</style>