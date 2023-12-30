<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
	import { Check } from "phosphor-svelte";
	import { Modals, closeModal } from "svelte-modals";
</script>

<ModalShell class="max-w-md" color="black">
    <div class="p-4 flex flex-col items-start gap-4 text-lg">
        <p>Since Faaans is not a platform but rather a tool to interact with Nostr,
            your content can be seen way beyond Faaans.</p>

        <p>
            When you publish content in Nostr, you can choose how far you want your content to reach,
            which provides an organic opportunity to grow your audience without doing any additional work.
        </p>

        <p class="font-bold text-white">
            Your work speaks for itself.
        </p>

        <button class="button button-black px-6 py-3 mt-8 w-full" on:click={closeModal}>
            <Check class="w-4 h-4" />
            Close
        </button>
    </div>
</ModalShell>