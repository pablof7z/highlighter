<script lang="ts">
	import { type NDKEvent } from "@nostr-dev-kit/ndk";
	import ItemFooterInner from './ItemFooterInner.svelte';
	import { Toolbar } from "konsta/svelte";
	import { appMobileView } from "$stores/app";

    export let event: NDKEvent;
    export let urlPrefix: string;
</script>

{#if $appMobileView}
    <Toolbar bottom class="hairline-t pt-1 w-full {$$props.containerClass??""} {$$props.class??""}">
        <ItemFooterInner {event} {urlPrefix} />
    </Toolbar>
{:else}
    <div class="mobile-nav w-full {$$props.containerClass??""} {$$props.class??""}">
        <ItemFooterInner {event} {urlPrefix} />
    </div>
{/if}