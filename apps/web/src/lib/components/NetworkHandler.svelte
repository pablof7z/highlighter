<script lang="ts">
	import { ndk } from "@kind0/ui-common";
    import { network } from "@sveu/browser";
	import { onMount } from "svelte";
	import type { Readable } from "svelte/motion";

    let supported: Readable<boolean> | undefined;
    let online: Readable<boolean> | undefined;
    let onlineAt: Readable<number | undefined> | undefined;

    onMount(() => {
        const i = network();
        console.log(i);
        supported = i.supported;
        online = i.online;
        onlineAt = i.onlineAt;
    });

    $: if (supported) {
        console.log('defined');
        if ($supported) {
            if ($online) {
                console.log('Online');
            } else {
                console.log('Offline');
            }
        } else {
            console.log('Not supported');
        }
    }

    $: if (!$online) {
        console.log('Going offline');

        for (const relay of $ndk.pool.relays.values()) {
            console.log('Disconnecting from', relay.url);
            relay.disconnect();
        }
    }

    $: if ($online) {
        console.log('Going online');
        $ndk.connect(2000);
        $ndk.on('connect', () => {
            alert('Connected');
        });
        $ndk.on('relay:connect', (r) => {
            alert('Relay connected' + r.url);
        });
        for (const relay of $ndk.pool.relays.values()) {
            console.log('Connecting to', relay.url);
            relay.connect(2000);
        }
    }
</script>

{#if supported && $supported}
    {#if !$online}
        <div class="
            fixed bottom-2 left-20 mobile-nav !bg-red-500/30 border border-red-500 z-50 px-6 py-3
            sm:rounded-box text-white min-w-[10rem] text-center whitespace-nowrap
        ">
            <p>Your device is offline</p>
        </div>
    {/if}
{/if}
