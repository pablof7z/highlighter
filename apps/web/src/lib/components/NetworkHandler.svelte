<script lang="ts">
	import { ndk } from "$stores/ndk.js";
    import { network } from "@sveu/browser";
	import { onMount } from "svelte";
	import type { Readable } from "svelte/motion";

    let supported: Readable<boolean> | undefined;
    let online: Readable<boolean> | undefined;
    let onlineAt: Readable<number | undefined> | undefined;

    onMount(() => {
        const i = network();
        supported = i.supported;
        online = i.online;
        onlineAt = i.onlineAt;
    });

    $: if (!$online) {
        for (const relay of $ndk.pool.relays.values()) {
            relay.disconnect();
        }
    }

    $: if ($online) {
        $ndk.connect(2000);
        for (const relay of $ndk.pool.relays.values()) {
            relay.connect(2000);
        }
    }
</script>

{#if supported && $supported}
    {#if !$online}
        <div class="
            fixed bottom-2 left-20 mobile-nav !bg-red-500/30 border border-red-500 z-50 px-6 py-3
            sm:rounded text-foreground min-w-[10rem] text-center whitespace-nowrap
        ">
            <p>Your device is offline</p>
        </div>
    {/if}
{/if}
