<script lang="ts">
	import { categories } from "$utils/categories";

    let interestList = new Set<string>();

	function toggleInterest(interest: string) {
        if (interestList.has(interest)) {
            interestList.delete(interest);
        } else {
            interestList.add(interest);
        }

        interestList = interestList;
	}
</script>

<div class="flex flex-row gap-4 flex-wrap justify-center">
{#each Array.from(categories) as category}
    <button
        class="
            button text-lg
            whitespace-nowrap
        "
        class:bg-accent2={interestList.has(category)}
        class:text-white={interestList.has(category)}
        on:click={() => toggleInterest(category)}
    >
        {category}
    </button>
{/each}
</div>

<style lang="postcss">
    button {}
</style>