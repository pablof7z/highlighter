<script lang="ts">
	import { CaretDown, CaretLeft, Notches, PaperPlane, Timer } from "phosphor-svelte";
    import { selectedTiers, type, view } from "$stores/post-editor";
	import TiersLabel from "$components/Forms/TiersLabel.svelte";
</script>

<div class="flex flex-row justify-between w-full items-center">
    {#if $view !== "edit"}
        <button class="button button-black" on:click={() => $view = 'edit'}>
            <CaretLeft size={24} />
            Back
        </button>
    {:else}
        <div class="flex flex-row gap-4 w-full flex-nowrap truncate items-stretch">
            <button class="button" on:click={() => $view = "distribution"}>
                <span class="whitespace-nowrap truncate">
                    <TiersLabel tiers={$selectedTiers} />
                </span>
                <CaretDown size={24} class="ml-1 max-sm:hidden" />
            </button>
            {#if $type === "article"}
                <button on:click={() => $view = "meta"} class="button button-black">
                    <Notches size={24} />
                    <span class="max-sm:hidden">
                        Attributes
                    </span>
                </button>
            {/if}

        </div>

        <div class="flex flex-row gap-4">
            <button
                class="button button-black !rounded-full"
                on:click={() => $view = "schedule"}
            >
                <Timer size={24} />
                <span class="max-sm:hidden">
                    Schedule
                </span>
            </button>

            <button class="button btn-circle" on:click={() => $view = "publish"}>
                <PaperPlane size={24} />
            </button>
        </div>
    {/if}
</div>