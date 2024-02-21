<script lang="ts">
    import { drafts } from "$stores/drafts";
	import { user } from "@kind0/ui-common";
	import { Trash } from "phosphor-svelte";
	import DraftItem from "$components/Creator/DraftItem.svelte";
	import DraftListVersionItem from "$components/Creator/DraftListVersionItem.svelte";

    function trash(id: string) {
        $drafts = $drafts.filter(d => d.id !== id);
    }
</script>

{#if $user}
    <ul class="w-full">
        {#key $drafts}
            {#each $drafts as draft (draft.id)}
                <div class="max-h-[25vh] overflow-hidden">
                    <DraftItem item={draft} />
                </div>
                <div class="flex flex-row justify-between">
                    <button on:click={() => trash(draft.id)}>
                        <Trash class="w-6 h-6" />
                    </button>

                    <div class="dropdown dropdown-end">
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <!-- svelte-ignore a11y-label-has-associated-control -->
                        <label class="button button-black" tabindex="0">
                            Versions
                        </label>
                        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                        <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box">
                            {#each JSON.parse(draft.checkpoints) as checkpoint}
                                <DraftListVersionItem {draft} {checkpoint} />
                            {/each}
                        </ul>
                    </div>
                </div>
            {/each}
        {/key}
    </ul>
{/if}

<style>
    ul {
        @apply flex flex-col;
    }
</style>