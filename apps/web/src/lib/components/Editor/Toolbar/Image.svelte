<script lang="ts">
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import { Image } from 'phosphor-svelte';
	import { Editor } from "svelte-tiptap";

    export let editor: Editor;

    let fileSelector: HTMLInputElement;

    function addImage() {
        fileSelector.click();
    }

    function handleImageUpload(event) {
        const file = event.target.files[0];
        let reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = e => {
            editor.chain().focus().setImage({ src: e.target.result }).run();

            // upload the image and when the upload finishes replace the image with the uploaded URL
            uploadImage(file)
                .then(url => {
                    editor.chain().focus().setImage({ src: url }).run();
                });
        };
    }

</script>

<DropdownMenu.Root>
    <DropdownMenu.Trigger>
            <Image size={18} />
    </DropdownMenu.Trigger>
    <DropdownMenu.Content>
        <DropdownMenu.Group>
            <DropdownMenu.Item on:click={() => editor.chain().focus().addImage().run()}>
                <Image size={18} class="mr-2" />
                Add Image
            </DropdownMenu.Item>
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>
