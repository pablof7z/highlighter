<script lang="ts">
	import Box from "$components/PageElements/Box.svelte";
	import { getUserSupporters } from "$stores/user-view";
	import { zapInvoiceFromEvent, type Hexpubkey, NDKKind, NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import type { Readable } from "svelte/store";
	import StatItem from "./StatItem.svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { ndk } from "$stores/ndk";
	import currentUser from "$stores/currentUser";
	import { nicelyFormattedMilliSatNumber } from "$utils";

    let disseminationEosed = false;
    const disseminations = $ndk.storeSubscribe(
        { kinds: [ NDKKind.Highlight, NDKKind.GenericRepost], "#p": [$currentUser.pubkey]},
    );
    disseminations.onEose(() => { disseminationEosed = true });

    const zaps = $ndk.subscribe(
        { kinds: [9735], "#p": [$currentUser.pubkey] },
    )

    const views = $ndk.storeSubscribe([
        { kinds: [15], "#p": [$currentUser.pubkey] }
    ])
    let viewsEosed = false;
    views.onEose(() => { viewsEosed = true });

    let myContentView: NDKEventStore<NDKEvent> | undefined;

    let myContentEosed = false;
    let myContentViewEosed = false;
    const myContent = $ndk.storeSubscribe(
        { kinds: [ NDKKind.Article, NDKKind.HorizontalVideo], authors: [$currentUser.pubkey] }
    );
    myContent.onEose(() => {
        myContentEosed = true;
        myContentView = $ndk.storeSubscribe(
            { kinds: [15], "#e": $myContent.map((e) => e.id) },
            { closeOnEose: true }
        );
        myContentView.onEose(() => { myContentViewEosed = true });
    });

    let supporters: Readable<Record<Hexpubkey, string | undefined>>;

    onMount(() => {
        supporters = getUserSupporters();
    });

    onDestroy(() => {
        zaps.stop();
        views.unsubscribe();
        disseminations.unsubscribe();
        myContent.unsubscribe();
    })

    let supporterCount = 0;

    $: {
        if (supporters) {
            supporterCount = Object.keys($supporters).length;
        }
    }

    let subscriberRate: number | undefined = 0;
    $: {
        if (supporterCount && $views?.length > 0) {
            subscriberRate = (supporterCount / $views.length) * 100;
        }
    }

    let earnings: number = 0;
    let zapsEosed = true;

    zaps.on("event", (zap) => {
        const zapReceipt = zapInvoiceFromEvent(zap);
        if (zapReceipt) {
            try {
                earnings += zapReceipt.amount / 1000;
            } catch (e) {
                console.error(e);
            }
        }
    });
    zaps.on("eose", () => { zapsEosed = true });

    let open: string;


</script>

<div class="self-stretch justify-between items-center inline-flex w-full gap-6 overflow-x-auto scrollable-content scrollable scrollbar-hide snap-x">
    <StatItem bind:open label="Subscribers" value={supporterCount} />
    <StatItem bind:open label="Profile Views" value={viewsEosed ? $views.length : undefined} loading={!viewsEosed} />
    <StatItem bind:open label="Disseminations" value={$disseminations.length} loading={!disseminationEosed} class="group">
        <div class="flex-grow">
            <p class="text-base text-neutral-500">
                When your audience interacts with your content, they inherently help you reach a wider audience. We call
                this "dissemination". This number represents the total number of times your content has been disseminated.
            </p>
        </div>
    </StatItem>
    <StatItem bind:open label="My Content" value={$myContent.length} loading={!myContentEosed} />
    {#if $myContentView}
        <StatItem bind:open label="Content Views" value={$myContentView.length} />
    {/if}
    <StatItem bind:open label="Earnings" value={nicelyFormattedMilliSatNumber(earnings)} loading={!zapsEosed} />
    <StatItem bind:open label="Subscribe Rate" value={subscriberRate?.toFixed(2)+"%"} loading={!subscriberRate || !viewsEosed} />
</div>

