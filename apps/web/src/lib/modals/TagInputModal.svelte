<script lang="ts">
	import TagInput from "$components/Editor/TagInput.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../app";

    export let event: NDKEvent;
    export let onSave: ((event: NDKEvent) => void) | undefined = undefined;

    function save() {
        if (onSave) onSave(event);
        closeModal();
    }

    let actionButtons: NavigationOption[] = [
        { name: "Save", fn: save, buttonProps: {} }
    ]
</script>

<ModalShell class="max-w-sm w-full" title="Tags" {actionButtons}>
    <TagInput
        bind:event
        autofocus={true}
        on:submit={save}
    />
</ModalShell>