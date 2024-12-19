<script lang="ts">
	import * as Dialog from '@components/ui/dialog';
	import Button from '../ui/button/button.svelte';
	import Input from '../ui/input/input.svelte';
	import { parse } from './parse.svelte';
	import { NDKArticle, NDKDraft } from '@nostr-dev-kit/ndk';
	import { ndk } from '@/state/ndk';
	import { goto } from '$app/navigation';
	import TurndownService from 'turndown';
	import { toast } from 'svelte-sonner';
	import type { ArticleState } from '../Post/state/article.svelte';

	type Props = {
		open: boolean;
		postState?: ArticleState;
	};

	let { open = $bindable(false), postState = $bindable() }: Props = $props();

	let url = $state<string>('');
	let fetching = $state<boolean>(false);
	let error = $state<string | null>(null);

	async function fetchContent() {
		error = null;
		fetching = true;

		const timeoutPromise = new Promise((_, reject) =>
			setTimeout(() => reject(new Error('Request timed out')), 10000)
		);

		try {
			const proxyUrl = `https://api.allorigins.win/get?url=${encodeURIComponent(url)}`;
			const response = await Promise.race([fetch(proxyUrl), timeoutPromise]);

			if (!response.ok) {
				throw new Error('Failed to fetch content');
			}

			const data = await response.json();
			const content = data.contents;

			try {
				console.log(content);
				const parsed = parse(content);
				console.log(parsed);

				if (parsed) {
					const turndownService = new TurndownService();
					const markdownContent = turndownService.turndown(parsed.content);

					const article = new NDKArticle(ndk);
					article.content = markdownContent;
					article.title = parsed.title;
					article.summary = parsed.excerpt;
					article.url = url;

					if (postState) {
						postState.title = parsed.title;
						postState.summary = parsed.excerpt;
						postState.content = markdownContent;
						open = false;
						return;
					}

					// create a draft if we have a response
					const draft = new NDKDraft(ndk);
					draft.event = article;
					await draft.sign();
					await draft.save({});
					goto(`/article/${draft.encode()}`);
				} else {
					toast.error("Unable to fetch any content. Try again later or try a different URL.")
				}
			} catch (e) {
				error = e instanceof Error ? e.message : 'Failed to import content';
			}
		} catch (e) {
			error = e instanceof Error ? e.message : 'Failed to import content';
		} finally {
			fetching = false;
		}
	}
</script>

<Dialog.Root bind:open>
	<Dialog.Content>
		<Dialog.Title>Import your content</Dialog.Title>
		<Dialog.Description>
			Import your content from a variety of sources. This will create a draft for you to review and
			edit before publishing.
		</Dialog.Description>

		<div class="flex flex-col gap-2">
			<Input 
				bind:value={url} 
				placeholder="https://example.com/my-blog.html" 
				disabled={fetching}
				onkeydown={(e) => {
					if (e.key === 'Enter' && !fetching && url) {
						fetchContent();
					}
				}} 
			/>
			{#if error}
				<p class="text-sm text-red-500">{error}</p>
			{/if}
		</div>

		<Dialog.Footer>
			<Button onclick={fetchContent} status={fetching ? 'loading' : 'initial'}>
				Import
			</Button>
		</Dialog.Footer>
	</Dialog.Content>
</Dialog.Root>
