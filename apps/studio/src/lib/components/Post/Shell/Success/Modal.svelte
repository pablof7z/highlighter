<script lang="ts">
	import * as Dialog from '@/components/ui/dialog';
	import type { PostState } from '../../state.svelte';
	import { Button } from '@/components/ui/button';
	import SettingsModal from '../../Settings/Modal.svelte';
	import { publish } from '../../state.svelte';
	import { ArrowRightIcon, Clock, Loader2, MessageCircleWarning, Plane } from 'lucide-svelte';
	import Name from '@/components/user/Name.svelte';
	import CoverImage from '../buttons/CoverImage.svelte';
	import { fade, slide } from 'svelte/transition';

	interface Props {
		postState: PostState;
		open: boolean;
		onSuccess: () => void;
	}

	let {
		postState = $bindable(),
		open = $bindable(),
		onSuccess
	}: Props = $props();

	let showSettings = $state(false);
	let error = $state(null);

	function _publish() {
		acting = true;
		error = null;
		publish(postState)
			.then(() => {
				open = false;
				onSuccess?.();
			})
			.catch((e) => {
				error = e;
			})
			.finally(() => {
				acting = false;
			});
	}

	let allGood = $state(false);

	// Whether we are performing the action
	let acting = $state(false);

	const publishButtonEnabled = $derived(allGood && !acting);

    const readingTime = $derived(Math.ceil(postState.content.split(' ').length / 200));
</script>

<Dialog.Root bind:open>
    <Dialog.Content class="max-w-md">
		<h1 class="text-2xl font-medium text-center mt-6">
			Your article is live. Well done.
		</h1>

		<div class="text-base text-muted-foreground text-center">
			You've done the work. Now it's time to reap the rewards. Share it. Far and wide.
		</div>

		
        <!-- <div class="w-[260px] h-[320px] relative rounded-2xl overflow-clip">
            <img src={postState.image} class="absolute top-0 left-0 h-[320px] object-cover" />

            <div class="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-background/0 to-background" transition:fade></div>
            
            <div class="absolute bottom-0 left-0 w-full h-1/2 p-4 flex flex-col justify-end gap-4">
                <h1 class="text-lg font-medium text-white">
                    {postState.title}
                </h1>

				<div class="flex flex-row gap-2 items-center text-muted-foreground text-xs">	
					{readingTime}m read
				</div>
            </div>
        </div> -->

        <Dialog.Footer>
            {#if error}
                <div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg grow" transition:fade>
                    <div class="flex flex-row  items-center gap-2 grow">
                        <MessageCircleWarning class="h-4 w-4" />
                        {error}
                    </div>
                </div>
            {/if}
            
            <Button variant="ghost" onclick={() => (showSettings = true)}>Advanced</Button>
            <Button
                variant="default"
                onclick={_publish}
                disabled={!publishButtonEnabled}
                loading={acting}
            >
                Publish
            </Button>
        </Dialog.Footer>
    </Dialog.Content>
</Dialog.Root>
