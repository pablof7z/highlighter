<script lang="ts">
    import * as Tooltip from "$lib/components/ui/tooltip";
	import { ndk } from "$stores/ndk";
	import { NDKRelay, NDKRelayStatus } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
    
    export let url: string;
    export let relay: NDKRelay = $ndk.pool.getRelay(url, false);

    let color: string;
    let reload = Date.now();

    const timer = setInterval(() => {
        relay = $ndk.pool.getRelay(url, false);
        reload = Date.now();
    }, 5000);

    onDestroy(() => {
        clearInterval(timer);
    })

    $: if(reload) switch (relay.status) {
        case NDKRelayStatus.DISCONNECTING: color = "bg-red-500"; break;
        case NDKRelayStatus.DISCONNECTED: color = "bg-red-500"; break;
        case NDKRelayStatus.RECONNECTING: color = "bg-yellow-500"; break;
        case NDKRelayStatus.FLAPPING: color = "bg-yellow-500"; break;
        case NDKRelayStatus.CONNECTING: color = "bg-yellow-500"; break;
        case NDKRelayStatus.CONNECTED: color = "bg-green-500"; break;
        case NDKRelayStatus.AUTH_REQUIRED: color = "bg-blue-500"; break;
        case NDKRelayStatus.AUTHENTICATING: color = "bg-blue-500"; break;
    }

</script>

<Tooltip.Root>
    <Tooltip.Trigger>
        <div class="w-3.5 h-1.5 {color}"></div>
    </Tooltip.Trigger>
    <Tooltip.Content>
        {relay.url}: {relay.status}
    </Tooltip.Content>
</Tooltip.Root>