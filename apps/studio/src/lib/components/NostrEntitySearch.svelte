<script lang="ts">
    import { ndk } from '@/state/ndk';
    import { nip19 } from 'nostr-tools';
    import { currentUser, currentUserFollows } from '@/state/current-user.svelte';
    import { searchUser, type UserSearchResult } from '@/utils/search/user.svelte';
	import type { Hexpubkey, NDKEvent } from '@nostr-dev-kit/ndk';
	import { UserCircle } from 'lucide-svelte';
    import { Input } from '@/components/ui/input';
	import AvatarWithName from './user/AvatarWithName.svelte';
	import * as Event from '@components/Event';

    const follows = $derived.by(currentUserFollows);

    type Props = {
        searchTerm?: string;
        selectedEncoding?: string;
        results?: UserSearchResult[];
        onSelect: (encoding: string) => void;
		onCancel?: () => void;
        placeholder?: string;
    }
    
    let {
        searchTerm = $bindable(''),
        selectedEncoding = $bindable(),
        results = $bindable([]),
        onSelect = $bindable(),
        placeholder = $bindable('Search users or enter a note, nevent, or naddr'),
		onCancel
    } : Props = $props();

    let selectedIndex = $state(-1);
    
	let eventId = $state<string | null>(null);
    let timer = $state<NodeJS.Timeout | null>(null);
    
    async function tryToLoadFromNip19() {
		try {
			const res = nip19.decode(searchTerm);

			// it worked, so we'll take it
			selectedEncoding = searchTerm;

			if (res.type === 'npub') {
				const user = ndk.getUser({ pubkey: res.data });
				results = [
					{
						id: user.pubkey,
						user,
						profile: null,
						followed: follows.has(user.pubkey)
					}
				];
				user.fetchProfile().then((profile) => {
					results = [
						{
							id: user.pubkey,
							user,
							profile: profile ?? null,
							followed: follows.has(user.pubkey)
						}
					];
				});
			} else if (['naddr', 'note', 'nevent'].includes(res.type)) {
				eventId = searchTerm;
			}

			return true;
		} catch {
			event = undefined;
			selectedEncoding = undefined;
		}

		return false;
	}

    $effect(() => {
		tryToLoadFromNip19().then((success) => {
			if (success) return;
			if (timer) clearTimeout(timer);

			timer = setTimeout(() => {
				searchUser(searchTerm, ndk, follows).then((res) => {
					results = res ?? [];
				});
			}, 300);
		});
	});

    function setPubkey(pubkey: Hexpubkey) {
		const user = ndk.getUser({ pubkey });
		selectedEncoding = user.nprofile;
	}

    function callback() {
		if (!selectedEncoding) {
			console.log('no selectedEncoding');
			return;
		}
		onSelect(selectedEncoding);
		onCancel?.();
	}

    function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Backspace' && searchTerm.length === 0) {
			onCancel?.();
			return;
		}

		if (event.key === 'ArrowDown') {
			event.preventDefault();
			selectedIndex = (selectedIndex + 1) % results.length;
			const result = results[selectedIndex];
			if (result?.pubkey) setPubkey(result.pubkey!);
		} else if (event.key === 'ArrowUp') {
			event.preventDefault();
			selectedIndex = (selectedIndex - 1 + results.length) % results.length;
			const result = results[selectedIndex];
			if (result?.pubkey) setPubkey(result.pubkey!);
		} else if (event.key === 'Enter') {
			event.preventDefault();
			if (selectedEncoding) callback();
		} else if (event.key === 'Escape') {
			onCancel?.();
		}
	}

    let itemRefs: HTMLElement[] = $state([]);
	let event = $state<NDKEvent | null>(null);
</script>


<div class="flex flex-col overflow-y-auto h-fit grow gap-2 -m-4 p-4">
    <Input
        type="text"
        bind:value={searchTerm}
        onkeydown={handleKeydown}
        {placeholder}
        autofocus={true}
    />

    <div
        class="border-border overflow-y-auto border rounded-lg"
    >
        {#if eventId}
            <Event.Root {eventId} bind:event={event}>
				<Event.Card {event} />
			</Event.Root>
        {:else}
            {#each results.slice(0, 50) as result, index (result.pubkey)}
                <button
                    bind:this={itemRefs[index]}
                    class="group text-left hover:bg-secondary flex w-full flex-row items-center gap-4 p-2 {index ===
                    selectedIndex
                        ? 'bg-secondary'
                        : ''}"
                    onclick={() => {
                        setPubkey(result.pubkey);
                        callback();
                    }}
                >
                    <AvatarWithName of={result.pubkey} avatarSize="small" nameClass="text-muted-foreground text-xs" />
                    {#if result.followed}
                        <UserCircle class="text-secondary group-hover:text-foreground h-4 w-4" />
                    {/if}
                </button>
            {/each}
        {/if}
    </div>
</div>