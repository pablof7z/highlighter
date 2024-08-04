<script lang="ts">
	import { NDKTag } from '@nostr-dev-kit/ndk';
	import { GroupEntryKey, groupKey, groups, refGroup, refGroups, unrefGroups } from '$stores/groups';
	import { onDestroy } from 'svelte';
	import { writable } from 'svelte/store';

    export let tags: NDKTag[];
    export let skipFooter: boolean = false;

    const refedTags = new Set<NDKTag>();
    const keys = writable(new Set<GroupEntryKey>());

    $: for (const tag of tags) {
        if (!refedTags.has(tag)) {
            const keys = refGroups([tag]);
            for (const key of keys) {
                $keys.add(key);
            }
            refedTags.add(tag);
        }
    }

    onDestroy(() => {
        unrefGroups(Array.from(refedTags));
    });
</script>

{#each Array.from($keys) as key (key)}
    {#if $groups[key]}
        <slot groupEntry={$groups[key]} {key} />
    {/if}
{/each}