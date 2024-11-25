<script lang="ts">
	import { NDKTag } from '@nostr-dev-kit/ndk';
    import { GroupData, Root} from '$components/Groups';
	import { Writable } from 'svelte/store';

    export let tags: NDKTag[];
    export let skipFooter: boolean = false;

    export let groups: Record<string, Writable<GroupData>> = {};
</script>

{#each tags as tag}
    <Root
        groupId={tag[1]} relays={tag.slice(2)}
        bind:group={groups[tag[1]]}
        let:articles
        let:videos
        let:notes
        let:chat
        let:tiers
    >
        <slot
            group={groups[tag[1]]}
            {articles}
            {videos}
            {notes}
            {chat}
            {tiers}
        />
    </Root>
{/each}
