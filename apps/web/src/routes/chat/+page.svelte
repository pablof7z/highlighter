<script lang="ts">
	import MainWrapper from "$components/Page/MainWrapper.svelte";
    import { pageHeader } from "$stores/layout";
	import { onDestroy } from "svelte";

    $pageHeader = { title: "Community" };

    onDestroy(() => {
        $pageHeader = null;
    });

    // const relaySet = getDefaultRelaySet();
    // const chatGroups = $ndk.storeSubscribe(
    //     { kinds: [NDKKind.GroupChat], limit: 300 },
    //     { relaySet, groupable: false, closeOnEose: true }
    // )
</script>

    <div class="flex flex-col max-w-prose w-full">
        <h1 class="text-[80px] font-semibold ">
            Community.
        </h1>
        <h2 class="text-3xl">
            Like never before
        </h2>

        <div class="text-xl mt-4 opacity-60 font-light">
            Highlighter, built on Nostr, allows for direct communication between creators and their audience. It's a place where you can share your thoughts, ideas, and opinions with the world.
        </div>
    </div>

<style>
    h1 {
        @apply text-foreground leading-tight text-[80px];
    }

    h2 {
        @apply text-neutral-500 leading-tight;
    }
</style>