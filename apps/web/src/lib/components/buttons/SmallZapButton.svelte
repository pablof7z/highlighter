<script lang="ts">
	import AnimatedToggleButton from "$components/PageElements/AnimatedToggleButton.svelte";
	import { openModal } from "$utils/modal";
    import { Lightning } from "phosphor-svelte";
    import ZapModal from "$modals/ZapModal.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk.js";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy } from "svelte";
	import { zap } from "$utils/zap";
	import { toast } from "svelte-sonner";

    export let event: NDKEvent;

    let active: boolean;
    let allZaps: NDKEventStore<NDKEvent> | undefined;
    
    $: if (!allZaps && $currentUser) {
        allZaps = $ndk.storeSubscribe(
            { kinds: [9735], ...event.filter()},
            { subId: 'small-zap', groupableDelayType: 'at-least', groupableDelay: 400 },
        );
    }

    $: if ($allZaps) {
        active = $allZaps
            .filter((zap) => zap.tagValue("P") === $currentUser!.pubkey)
            .length > 0;
    }

    onDestroy(() => {
        allZaps?.unsubscribe();
    })

    async function defaultZap() {
        try {
            await zap(1000, event, "🌰")
        } catch (e) {
            toast.error(e.message)
        }
    }
</script>

<AnimatedToggleButton
    {active}
    icon={Lightning}
    buttonClass="hover:bg-yellow-400/20"
    bgClass="bg-yellow-500"
    iconClass={active ? "text-yellow-500" : "text-yellow-400/30 group-hover:text-yellow-500"}
    on:click={() => openModal(ZapModal, { event })}
    on:longpress={() => openModal(ZapModal, { event })}
/>