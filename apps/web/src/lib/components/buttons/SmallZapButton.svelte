<script lang="ts">
	import AnimatedToggleButton from "$components/PageElements/AnimatedToggleButton.svelte";
	import { openModal } from "$utils/modal";
    import { Lightning } from "phosphor-svelte";
    import ZapModal from "$modals/ZapModal.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import currentUser from "$stores/currentUser";
	import { ndk } from "@kind0/ui-common";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy } from "svelte";

    export let event: NDKEvent;

    let active: boolean;
    let zappedByUser: NDKEventStore<NDKEvent> | undefined;
    
    $: if (!zappedByUser && $currentUser) {
        zappedByUser = $ndk.storeSubscribe(
            { kinds: [9735], ...event.filter(), "#P": [$currentUser.pubkey]}
        );
    }

    $: if ($zappedByUser) {
        active = $zappedByUser.length > 0;
    }

    onDestroy(() => {
        zappedByUser?.unsubscribe();
    })
</script>

<AnimatedToggleButton
    {active}
    icon={Lightning}
    buttonClass="hover:bg-yellow-400/20"
    bgClass="bg-yellow-500"
    iconClass={active ? "text-yellow-500" : "text-yellow-400/30 group-hover:text-yellow-500"}
    on:click={() => openModal(ZapModal, { event })}
/>