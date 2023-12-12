<script lang="ts">
	import { possibleTerms, type Term } from "$utils/term";
	import { newToasterMessage } from "@kind0/ui-common";
    import { TagSimple, X } from 'phosphor-svelte';
    import { createEventDispatcher } from "svelte";

    export let terms: Term[] = [];

    const dispatch = createEventDispatcher();

    function sortTerms() {
        terms = terms.sort((a, b) => {
            return possibleTerms.indexOf(a) - possibleTerms.indexOf(b);
        });
    }

    sortTerms();

    function addTerm(term: Term) {
        terms = [...terms, term];

        // sort terms in the order of the possible terms
        sortTerms();
        dispatch("change", terms);
    }

    function removeTerm(term: Term) {
        if (terms.length > 1)
            terms = terms.filter(t => t !== term);
        else {
            newToasterMessage("You need to at least one term", "error");
        }
        dispatch("change", terms);
    }
</script>

{#each terms as term}
    <button
        class="px-2.5 py-1 rounded-lg justify-center items-center flex bg-zinc-100"
    >
        <div class="text-center text-black text-[15px] font-medium">{term}</div>
        <button class="btn btn-circle btn-ghost btn-xs ml-2" on:click={() => removeTerm(term)}>
            <X color="black" class="text-sm" />
        </button>
    </button>
{/each}

<div class="dropdown">
    <button tabindex="0" class="button">+</button>
    <ul tabindex="0" class="dropdown-content menu !bg-white z-50">
        {#each possibleTerms as term}
            {#if !terms.includes(term)}
                <li><button class="text-black" on:click={() => addTerm(term)}>
                    {term}
                </button></li>
            {/if}
        {/each}
    </ul>
</div>