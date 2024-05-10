<script lang="ts">
	import CreatorBanner from "$components/Creator/CreatorBanner.svelte";
	import { featuredCreatorPubkeys, featuredCreatorsPerCategory } from "$utils/const";
	import { flip } from "svelte/animate";
	import { fly } from "svelte/transition";
    import { crossfade } from 'svelte/transition';
    import { quintOut } from 'svelte/easing';

    export let category: string | undefined = undefined;

    const [send, receive] = crossfade({
	duration: (d) => Math.sqrt(d * 200),

	fallback(node, params) {
		const style = getComputedStyle(node);
		const transform = style.transform === 'none' ? '' : style.transform;

		return {
			duration: 600,
			easing: quintOut,
			css: (t) => `
				transform: ${transform} scale(${t});
				opacity: ${t}
			`
		};
	}
});

    let creatorPubkeys = featuredCreatorPubkeys;

    $: if (category) {
        const newList = featuredCreatorsPerCategory[category] ?? featuredCreatorPubkeys
        let newListWithExistingItemsInSamePosition = [];

        // empty list with same length as creatorPubkeys
        for (let i = 0; i < creatorPubkeys.length; i++) {
            newListWithExistingItemsInSamePosition.push(null);
        }

        // add the pubkeys we already have to the new empty list
        for (let i = 0; i < creatorPubkeys.length; i++) {
            const pubkey = creatorPubkeys[i];
            if (newList.includes(pubkey)) {
                newListWithExistingItemsInSamePosition[i] = pubkey;
            }
        }

        // add the rest of the pubkeys to the new list in the empty spots checking that we don't add duplicates
        for (const pubkey of newList) {
            const exists = creatorPubkeys.includes(pubkey);

            if (exists) continue;

            const index = newListWithExistingItemsInSamePosition.indexOf(null);

            if (index === -1) {
                newListWithExistingItemsInSamePosition.push(pubkey);
            } else {
                newListWithExistingItemsInSamePosition[index] = pubkey;
            }
        }

        // remove null values from the list
        creatorPubkeys = newListWithExistingItemsInSamePosition.filter((pubkey) => pubkey !== null) as string[];
    }
</script>

<ul class="flex flex-row gap-4">
    {#each creatorPubkeys as pubkey, i (pubkey)}
        <li
            in:receive={{ key: pubkey }}
            out:send={{ key: pubkey }}
            animate:flip={{ duration: 300, delay: 100 * i }}
            class="w-64">
            <CreatorBanner {pubkey} />
        </li>
    {/each}
</ul>