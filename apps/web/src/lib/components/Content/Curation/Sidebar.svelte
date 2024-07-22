<script lang="ts">
import { ndk } from "$stores/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import * as List from "$components/List";
	import { NDKList } from "@nostr-dev-kit/ndk";

    export let list: NDKList;
</script>

<div class="flex flex-col gap-4">
    {#if list.image}
        <img src={list.image} alt={list.title} class="object-cover w-full max-h-[20rem]" />
    {/if}

    <div class="px-2 flex flex-col gap-2 border-b border-border pb-4">
        <h1>{list.title}</h1>
        {#if list.description}
            <h3>
                <EventContent ndk={$ndk} content={list.description} event={list} />
            </h3>
        {/if}
    </div>

    <List.Root {list} let:item>
        <div class="px-2 flex flex-col gap-2 border-b border-border pb-4">
            <List.Item {item} />
        </div>
    </List.Root>
</div>

<style>
    h3 {
        @apply text-lg;
    }
</style>