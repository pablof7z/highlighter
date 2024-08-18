import { activeBlossomServer } from "$stores/session";
import { Uploader } from "$utils/upload";
import { Editor } from "svelte-tiptap";
import { get } from "svelte/store";

export function addImageBlob(
    editor: Editor,
    blob: Blob
) {
    const $activeBlossomServer = get(activeBlossomServer);
    const reader = new FileReader();
    reader.readAsDataURL(blob);

    const uploader = new Uploader(blob, $activeBlossomServer);
    reader.onload = e => {
        editor.commands.setImage({src: e.target.result})
    };
    
    uploader.onUploaded = (url: string) => {
        // replace the image with the uploaded URL
        // find the image in the editor and replace the src attribute
        // add image to the document
        const newImageTag = document.createElement("img");
        newImageTag.src = url;
        // add to the document to trigger the onload event
        document.body.appendChild(newImageTag);
        // newImageTag.classList.add('hidden');
        // once it finishes loading, remove the hidden class
        newImageTag.onload = () => {
            // find node
            editor.commands.setImage({src: url})
            newImageTag.remove();
        }
    };
    uploader.start();
}