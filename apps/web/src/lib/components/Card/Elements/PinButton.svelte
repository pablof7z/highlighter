<script lang="ts">
    import { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { PushPin } from "phosphor-svelte";
	import { Readable } from "svelte/store";
	import { getContext } from 'svelte';
	import { ndk } from "$stores/ndk";

    export let event: NDKEvent;
    export let align = "right-2";

    const userPinList = getContext('userPinList') as Readable<NDKList | undefined>;

    let isPinned: boolean | undefined = undefined;

    $: if ($userPinList?.items) {
        isPinned = !!$userPinList.items.find(t => t[1] === event.tagId()) 
    }

    async function pin(e: MouseEvent) {
        let pinList = $userPinList;
        if (pinList === undefined) {
            pinList = new NDKList($ndk);
            pinList.kind = NDKKind.PinList;
        }
        
        if (isPinned) {
            pinList.removeItemByValue(event.tagId())
        } else {
            pinList.addItem(event.tagReference());
        }
        pinList.publishReplaceable();
    }
</script>

<button
    class="
        absolute top-2 {align} z-10 rounded-full bg-background/80  flex flex-row items-center gap-2 text-sm transition-all duration-100
        px-4 py-2 lg:opacity-0 group-hover:opacity-100
    "
    on:click|preventDefault|stopImmediatePropagation={pin}
>
    <PushPin size={16} />
    {#if isPinned}
        Unpin
    {:else}
        Pin
    {/if}
</button>