<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";

    export let onSaveDraft: () => void;
    export let togglePreview: () => void;
</script>

<HorizontalOptionsList options={[
    { name: "Preview", value: "view-preview", fn: togglePreview },
    { name: "Save Draft", value: "save-draft", fn: onSaveDraft }
]} />