<script lang="ts">
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import { Image } from 'lucide-svelte';
	import { Editor } from 'svelte-tiptap';

	export let editor: Editor;
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Image size={18} />
	</DropdownMenu.Trigger>
	<DropdownMenu.Content class="!w-24 !min-w-[10rem]">
		<DropdownMenu.Group>
			<DropdownMenu.Item onclick={() => editor.chain().focus().addImage().run()}>
				<Image size={18} class="mr-2" />
				Add Image
			</DropdownMenu.Item>
		</DropdownMenu.Group>
	</DropdownMenu.Content>
</DropdownMenu.Root>
