<script lang="ts">
    import { pageDrawerToggle } from "@kind0/ui-common";

    function closeDrawer() {
        pageDrawerToggle.set(false);
    }
</script>

<div class="w-full flex flex-col items-stretch gap-4">
    <div class="flex flex-row items-center justify-between w-full">
        <h1 class="text-white text-2xl font-semibold leading-8">
            Configuring a post's reach
        </h1>
    </div>

    <p>
        Since Faaans is not a platform but rather a tool to interact with Nostr,
        your content can be seen way beyond Faaans in a myriad of different platforms.
    </p>

    <p>
        When you publish content in Nostr, you can choose how far you want your content to reach,
        which provides an opportunity to organically grow your audience without doing any additional work.
    </p>

    <p class="font-bold text-white">
        Your work speaks for itself.
    </p>

    <button class="self-end max-sm:w-full button px-10 py-3" on:click={closeDrawer}>
        Close
    </button>
</div>

<style lang="postcss">
    p {
        @apply leading-relaxed max-w-prose text-lg
    }
</style>