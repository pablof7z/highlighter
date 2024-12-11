<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import { NDKArticle, NDKEvent, type NDKDraft, type NDKDVMRequest, type NDKTag } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';
	import { currentUser } from '@/state/current-user.svelte';
	import { ndk } from '@/state/ndk';

	interface Props {
		schedule: NDKDVMRequest;
	}
	let { schedule }: Props = $props();

	let events = $state<NDKArticle[]>([]);
	let editUrl = $state<string | null>(null);

	const user = $derived.by(currentUser);
    const pTag = schedule.tagValue('p');
    const pUser = pTag ? ndk.getUser({pubkey: pTag}) : null;

    console.log({pTag})
    console.log(schedule.content)

    schedule.decrypt(pUser!, undefined, 'nip04')
        .then(() => {
            try {
                const content = JSON.parse(schedule.content);
                content.forEach((tag: NDKTag) => {
                    if (tag[0] === 'i') {
                        const event = new NDKEvent(ndk, JSON.parse(tag[1]));
                        const wrapped = wrapEvent(event);
                        console.log(wrapped.rawEvent())
                        events.push(wrapped);
                    }
                })
                
            } catch (e) {
                console.error(e);
            }
        })
</script>

{#if events.length > 0}
    {#each events as event (event.id)}
        <a href={editUrl} class="hover:bg-secondary/20 block w-full">
            <Item
                title={event.title} 
                image={event.image}
                timestamp={event.created_at}
                eventId={schedule.id}
                onDelete={() => schedule.delete()}
            />
        </a>
    {/each}
{:else}
	<div>
		{JSON.stringify(schedule.tags)}
	</div>
{/if}
