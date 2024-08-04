<script lang="ts">
	import { type NDKEvent } from "@nostr-dev-kit/ndk";
	import ItemFooterInner from './ItemFooterInner.svelte';
	import { appMobileView } from "$stores/app";

    export let event: NDKEvent;
    export let urlPrefix: string;
</script>

{#if $appMobileView}
    <div bottom class="bg-opacity-80 mobile-nav bg-secondary px-4 rounded-t-[3rem] w-full {$$props.containerClass??""} {$$props.class??""}">
        <ItemFooterInner {event} {urlPrefix} />
    </div>
{:else}
    <div class="mobile-nav w-full {$$props.containerClass??""} {$$props.class??""}">
        <ItemFooterInner {event} {urlPrefix} />
    </div>
{/if}