<script lang="ts">
	import { drafts } from "$stores/drafts";
	import { Trash } from "phosphor-svelte";
	import DraftItem from "./DraftItem.svelte";
	import Tab from "$components/Tab.svelte";
	import DraftListVersionItem from "./DraftListVersionItem.svelte";

    function trash(id: string) {
        $drafts = $drafts.filter(d => d.id !== id);
    }
</script>

<div class="flex flex-row items-start hidden">
    <Tab title="Manually Saved" value={"true"} />
    <Tab title="All Saved" value={"false"} />
</div>

<div class="flex flex-col gap-6">
    {#key $drafts}
        {#each $drafts as draft (draft.id)}
            <DraftItem item={draft} />
            <div class="flex flex-row justify-between">
                <button on:click={() => trash(draft.id)}>
                    <Trash class="w-6 h-6" />
                </button>

                <div class="dropdown dropdown-end">
                    <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
                    <!-- svelte-ignore a11y-label-has-associated-control -->
                    <label class="button-black" tabindex="0">
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
</div>