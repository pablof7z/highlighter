<script lang="ts">
	import type { NDKArticle, NDKUser } from "@nostr-dev-kit/ndk";
	import CaretRight from "phosphor-svelte/lib/CaretRight";
    import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { openModal } from "svelte-modals";
	import type { Readable } from "svelte/store";

    export let user: NDKUser;
    export let tiers: Readable<NDKArticle[]>;

    function openSupportModal() {
        openModal(BecomeSupporterModal, { user, tiers });
    }
</script>

<button
    on:click={openSupportModal}
    class="
        button flex flex-row items-center !gap-0
    "
>
    {#if tiers && $tiers.length > 0}
        Go Backstage
    {:else}
        Support
    {/if}
    <CaretRight class="w-5 h-5 inline" />
</button>

<style lang="postcss">
    button {
        @apply font-normal;
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488ee 0%, #7092A0ee 100%);
        @apply transition-all duration-300;
    }

    button:hover {
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488ff 0%, #7092A0ff 100%);
    }
</style>