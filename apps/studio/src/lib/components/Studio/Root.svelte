<script lang="ts">
	import { ndk } from '@/state/ndk';
	import Editor from './Editor/index.svelte';
	import { ArticleState, PostState, ThreadState } from './state.svelte';
	import { toast } from 'svelte-sonner';
	import { House, Loader, Loader2 } from 'lucide-svelte';
	import { goto } from '$app/navigation';
	import { Button } from '../ui/button';
	import { fade, slide } from 'svelte/transition';

	/**
	 * This component loads the event, if an event id has been provided,
	 */
	const { type, id } = $props();

	let postState = $state<PostState | null>(null);

	let error = $state<string | null>(null);

	if (id === 'new') {
		if (type === 'article') {
			postState = new ArticleState();
		} else if (type === 'thread') {
			postState = new ThreadState();
		}
	} else {
		const fetchEventWithTimeout = (id, timeout = 10000) => {
			return Promise.race([
				ndk.fetchEvent(id),
				new Promise((_, reject) =>
					setTimeout(() => reject(new Error('Fetch event timed out')), timeout)
				)
			]);
		};

		fetchEventWithTimeout(id).then((e) => {
			if (e) {
				if (type === 'article') {
					ArticleState.from(e).then((state) => (postState = state));
				}
			}
		})
		.catch((e) => {
			console.error(e);
			error = e.message;
		});
	}
</script>

{#if postState}
	<Editor bind:postState />
{:else}
	<div class="h-screen w-screen flex items-center justify-center flex-col" transition:fade>
		{#if !error}
			<div class="flex flex-col items-center gap-2 pt-4" transition:slide>
				<Loader2 class="animate-spin text-muted-foreground" />
			</div>
		{:else}
			<div class="flex flex-col items-center gap-2 pt-4" transition:slide>
				<p class="text-muted-foreground">{error}</p>
				<Button href="/" variant="secondary">
					<House /> Back to home
				</Button>
			</div>
		{/if}
	</div>
{/if}
