<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { DraftItem } from "$stores/drafts";
	import { pluralize } from "$utils";
	import { Thread, ThreadItem as ThreadItemType } from "$utils/thread";
	import { ndk } from "$stores/ndk.js";
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
	import { RowsPlusBottom } from "phosphor-svelte";

    export let checkpoint: DraftItem["checkpoints"];
    export let href: string;

    console.log(checkpoint);

    let thread: Thread;
    let item: ThreadItemType;

    try {
        const payload = checkpoint.data;
        console.log(payload);
        thread = Thread.deserialize(payload, $currentUser!, $ndk);
        item = thread.items[0];
    } catch(e) {
        console.error(e);
    }
</script>

{#if item}
    <a {href} class="flex flex-row items-center gap-4 !bg-transparent my-4 mb-6">
        <div class="grow">
            {#if item.event.content.length === 0}
                <i class="opacity-80">Empty draft...</i>
            {:else}
                <EventContent ndk={$ndk} event={item.event} class="mb-2 text-lg" />
            {/if}
        </div>
        <div class="badge rounded-full bg-foreground/20">
            {thread.items.length}
        </div>
    </a>
{:else}
    <p>Failed to load thread</p>
{/if}
