<script lang="ts">
    import * as Dialog from '@/components/ui/dialog';
    import Body from './Body.svelte';
	import type { PostState } from '../state.svelte';

    interface Props {
        postState: PostState;
        open: boolean;
		selectedSetting?: string;
    }

    let { postState = $bindable(), open = $bindable(), selectedSetting = $bindable() }: Props = $props();
</script>

<Dialog.Root bind:open={open}>
	<Dialog.Content
		class="overflow-hidden max-h-[500px] p-0 md:max-w-3xl"
	>
		<Dialog.Title class="sr-only">Settings</Dialog.Title>
		<Dialog.Description class="sr-only">Customize your settings here.</Dialog.Description>

		<Body bind:postState bind:selectedSetting />
	</Dialog.Content>
</Dialog.Root>