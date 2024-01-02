<script lang="ts">
    import { pageDrawerToggle } from "@kind0/ui-common";

    function closeDrawer() {
        pageDrawerToggle.set(false);
    }
</script>

<div class="w-full flex flex-col items-stretch gap-4">
    <div class="flex flex-row items-center justify-between w-full">
        <h1 class="text-white text-2xl font-semibold leading-8">
            Creating good previews
        </h1>
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        When publishing a new note, you can choose to make it available to non-subscribers as a preview. This is a great way to attract new subscribers and give them a taste of what they can expect from your content.
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        Something to be mindful of is that
        <span class="text-white">the preview should be enticing and
        provide value on its own</span>.
        People not familiar with your work will likely see this, and it's your chance to make a good
        first impression.
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        Previews should have enough context to stand on their own among people who are first hearing of you.
    </div>

    <h1 class="text-white text-2xl font-semibold leading-8">
        Publishing previews widely
    </h1>

    <div class="leading-relaxed max-w-prose text-lg">
        When you choose to distribute a preview widely, it will be available to everyone in Nostr, not just your subscribers. This means that people who are not subscribed to you will be able to see your preview in their feed in whatever
        client they use to interact with Nostr.
    </div>

    <div class="leading-relaxed max-w-prose text-lg">
        You should reserve publishing previews beyond your Faaans page to high-quality, valuable content. If you publish too much low-effort previews your followers in other platforms might feel like your free content is not worth keeping up with.
    </div>

    <button class="self-end button px-10 py-3" on:click={closeDrawer}>
        Close
    </button>
</div>