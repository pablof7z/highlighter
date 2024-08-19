<script lang="ts">
    import { onDestroy, setContext } from 'svelte';
    import { Editor } from 'svelte-tiptap'
    import UploadImage from './extensions/upload-image'
    import Link from '@tiptap/extension-link';
    import { Markdown } from 'tiptap-markdown';
    import StarterKit from '@tiptap/starter-kit';
    import BulletList from '@tiptap/extension-bullet-list';
    import Dropcursor from '@tiptap/extension-dropcursor';
    import Placeholder from '@tiptap/extension-placeholder';
    import {Image as TipTapImage} from "@tiptap/extension-image";
    import Mention from '@tiptap/extension-mention';
	import { writable } from 'svelte/store';
    import suggestion from './Suggestion.js';
	import { activeBlossomServer } from '$stores/session.js';
	import { Uploader } from '$utils/upload.js';
	import { addImageBlob } from './add-image.js';
    
    export let content: string = "";
    export let editor: Editor | undefined = undefined;
    export let placeholder: string = 'Write...';

    const editorStore = writable<Editor | null>(null);
    const editorElement = writable<HTMLDivElement | null>(null);

    setContext('editorElement', editorElement);
    setContext('editorStore', editorStore);

    function getHandlePaste() {
        return (view, event, slice) => {
            const item = event.clipboardData?.items[0]

            if (item?.type.indexOf("image") !== 0) {
                return false;
            }

            const file = item.getAsFile()
            addImageBlob($editorStore, file)
            
            return true
        }
    }

    $: if (!editor && $editorElement) {
        console.log('creating editor', content);
		editor = new Editor({
			element: $editorElement,
			extensions: [
                StarterKit,
                Markdown.configure({
                    tightLists: true,
                    
                }),
                Dropcursor,
                // BulletList,
                // TipTapImage.configure({
                //     allowBase64: true,
                // }),
                // Placeholder.configure({
				// 	placeholder
				// }),
                // UploadImage.configure({
                //     uploadFn: (blob) => {
                //         return new Promise((resolve, reject) => {
                //             const uploader = new Uploader(blob, $activeBlossomServer);
                //             uploader.onUploaded = (url: string) => {
                //                 resolve(url);
                //             };
                //             uploader.onError = (error: Error) => {
                //                 reject(error.message);
                //             };
                //             uploader.start();
                //         });
                //     }
                // }),
                // Link.configure({
                //     openOnClick: false,
                //     autolink: true,
                //     defaultProtocol: 'https',
                // }),
                // Mention.configure({
                //     suggestion: suggestion(),
                // }),
            ],
			content,
			onTransaction: () => {
				// force re-render so `editor.isActive` works as expected
				editor = editor;
			},
            onUpdate: ({ editor }) => {
                content = editor.storage.markdown.getMarkdown();
            },
            editorProps: {
				handlePaste: getHandlePaste(editor)
			},
		});
        editorStore.set(editor);
	}

    onDestroy(() => {
        if (editor) {
            editor.destroy();
        }
    });
</script>

<slot />