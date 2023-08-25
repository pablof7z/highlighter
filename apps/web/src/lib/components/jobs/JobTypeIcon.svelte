<script lang="ts">
	import Nostr from "$icons/Nostr.svelte";
	import { Image, TextAa, Translate } from "phosphor-svelte";

    export let kind: number;
</script>

<div class="flex flex-row items-center gap-2">
    <div class="flex items-center justify-center rounded-md w-6 h-6 bg-base-300 text-base-content">
        {#if kind === 5000}
            <TextAa size="1.5rem" class="job-type-icons" />
        {:else if kind === 5002}
            <Translate size="1.5rem"  class="job-type-icons"  />
        {:else if kind === 5300}
            <Nostr size="1.5rem"  className="job-type-icons"  />
        {:else if kind === 5100}
            <Image size="1.5rem"  class="job-type-icons"  />
        {:else}
        {/if}
    </div>
</div>

<style lang="postcss">
    :global(.job-type-icons){
        @apply w-5 h-5
    }
</style>