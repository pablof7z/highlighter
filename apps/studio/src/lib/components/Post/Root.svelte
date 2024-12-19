<script lang="ts">
	import { ndk } from '@/state/ndk';
    import type { PostState } from './state/index.svelte';
    import { ArticleState } from './state/article.svelte';
	import { ThreadState } from './state/thread.svelte';
	import { House, Loader, Loader2 } from 'lucide-svelte';
	import { Button } from '../ui/button';
	import { fade, slide } from 'svelte/transition';
	import Shell from './Shell/index.svelte';
	import { appState } from '@/state/app.svelte';
	import { beforeNavigate } from '$app/navigation';
	import { toast } from 'svelte-sonner';
	import { NDKEvent } from '@nostr-dev-kit/ndk';

	/**
	 * This component loads the event, if an event id has been provided,
	 */
	const { type, id } = $props();

	let error = $state<string | null>(null);

	if (id === 'new') {
		if (type === 'article') {
			appState.postState ??= new ArticleState();
		} else if (type === 'thread') {
			appState.postState ??= new ThreadState();
		}
	} else {
		console.log('fetching 1', id)
		if (appState.postState && appState.postState.draft?.encode() === id) {
			console.log('already fetched', id)
		} else {
			appState.postState = null;
			const fetchEventWithTimeout = (id, timeout = 10000) => {
				return Promise.race([
					ndk.fetchEvent(id),
					new Promise((_, reject) =>
						setTimeout(() => reject(new Error('Fetch event timed out')), timeout)
					)
				]);
			};

			fetchEventWithTimeout(id).then((e) => {
				if (e instanceof NDKEvent) {
					if (e.hasTag('deleted')) {
						error = 'Event has been deleted';
						return;
					}
					
					if (type === 'article') {
						ArticleState.from(e).then((state) => {
							console.log('setting state', state)
							appState.postState = state
						})
						.catch(toast.error)
					}
				} else {
					error = 'Failed to fetch event';
				}
			})
			.catch((e) => {
				console.error(e);
				error = e.message;
			});
		}
	}
</script>

{#if appState.postState}
	<Shell bind:postState={appState.postState} />
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
