<script lang="ts">
	import Name from '$components/User/Name.svelte';
    import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    const pubkey = event.tagValue("p");
</script>

{#if pubkey}

<div class="text-sm text-neutral-300 text-center font-normal w-fit mx-auto rounded-full bg-gradient p-[1px]">
    <div class="bg-base-100/80 rounded-full px-10 py-3">
        <Name {pubkey} /> joined the community!
    </div>
</div>
{/if}