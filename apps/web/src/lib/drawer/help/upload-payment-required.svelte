<script lang="ts">
	import { Coin, Link, Money } from "phosphor-svelte";

    function closeDrawer() {
        pageDrawerToggle.set(false);
    }
</script>

<div class="w-full flex flex-col items-stretch gap-4">
    <div class="flex flex-row items-center justify-between w-full">
        <h1 class="text-white text-2xl font-semibold leading-8">
            Payment Required
        </h1>
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        The file you are trying to upload is too large to be uploaded for free.
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        Highlighter uses Satellite, a nostr client, for big-file uploads.
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        <a href="https://satellite.earth/cdn" target="_blank" class="button w-full py-4 button-black">
            <Coin class="w-6 h-6 mr-2" />
            Buy storage on Satellite CDN
        </a>
    </div>

    <button class="self-end button px-10 py-3" on:click={closeDrawer}>
        Close
    </button>
</div>