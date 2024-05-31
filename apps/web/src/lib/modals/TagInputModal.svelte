<script lang="ts">
	import TagInput from "$components/Editor/TagInput.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";
    import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let onSave: ((event: NDKEvent) => void) | undefined = undefined;

    function save() {
        if (onSave) onSave(event);
        closeModal();
    }
</script>

<ModalShell class="max-w-sm w-full" color="glassy" title="Tags">
    <TagInput
        bind:event
        autofocus={true}
        on:submit={save}
    />

    <div class="flex flex-row justify-end">
        <button class="button" on:click={save}>
            Save
        </button>
    </div>
</ModalShell>