<script lang="ts">
    import { ndk } from "$stores/ndk.js";
	import { NDKKind } from "@nostr-dev-kit/ndk";
	import DvmProfile from "./DvmProfile.svelte";

    const dvms = $ndk.storeSubscribe([
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.DVMReqDiscoveryNostrContent.toString()]}
    ])
</script>

<ul class="flex flex-col gap-2">
    {#each $dvms as dvm (dvm.id)}
        <li>
            <DvmProfile {dvm} />
        </li>
    {/each}
</ul>