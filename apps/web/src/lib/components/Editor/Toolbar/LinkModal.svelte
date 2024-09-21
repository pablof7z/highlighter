<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
    import { Editor } from "svelte-tiptap";
	import { NavigationOption } from "../../../../app";
	import { closeModal } from "$utils/modal";
	import { Input } from "$components/ui/input";

    export let editor: Editor;
    export let url: string | undefined = undefined;

    const initialLink = url;

    let actionButtons: NavigationOption[];
    $: {
        actionButtons = [ { name: "Cancel", fn: cancel, buttonProps: { variant: 'secondary' }} ];

        if (url === initialLink) {
            actionButtons.push(({ name: "Remove Link", fn: remove, buttonProps: { variant: 'default' }}))
        } else {
            actionButtons.push(({ name: "Link", fn: save, buttonProps: { variant: 'default', disabled: (!url || url.length === 0) }}))
        }
    }

    function remove() {
        editor.commands.unsetLink();
        closeModal();
    }
    
    function save() {
        if (url)
            editor.commands.setLink({ href: url });
        closeModal();
    }

    function cancel() {
        closeModal();
    }
</script>

<ModalShell
    title="Create a link"
    {actionButtons}
>
    <Input bind:value={url} />
</ModalShell>