<script lang="ts">
    import { getUserHighlights } from "$stores/user-view";

    export let value: string = "Publications";
    export let name: string = "this user"

    const highlights = getUserHighlights();
</script>

<div class="py-4 border-t border-b border-neutral-800 justify-start items-start gap-4 inline-flex w-full mb-6 max-w-[100vw] whitespace-nowrap max-sm:px-3">
    <div class="justify-start items-start gap-4 flex w-full">
        <button
            class="snap-center"
            on:click={() => value = "Publications"}
            class:active={value === "Publications"}
        >Publications</button>
        <div class="tooltip" data-tip="Curations created by {name}">
            <button
                class="snap-center"
                on:click={() => value = "Curations"}
                class:active={value === "Curations"}
            >Curations</button>
        </div>
        {#if $highlights.length > 0}
            <div class="tooltip" data-tip="Highlights made by {name}">
                <button
                    class="snap-center"
                    on:click={() => value = "Highlights"}
                    class:active={value === "Highlights"}
                >Highlights</button>
            </div>
        {/if}
        <div class="tooltip" data-tip="Explore creators {name} supports">
            <button
                class="snap-center"
                on:click={() => value = "Supported Creators"}
                class:active={value === "Supported Creators"}
            >Backstage Passes</button>
        </div>
    </div>
</div>

<style>
    button {
        @apply px-4 py-2 rounded-full;
        @apply bg-zinc-800 bg-opacity-70 justify-start items-center gap-2 flex;
        @apply text-neutral-400 text-sm font-normal;
        @apply transition-all duration-100;
    }

    button:hover {
        @apply text-neutral-200;
    }

    button.active {
        @apply !bg-white !text-black;
    }

    button.backstage {
        @apply bg-accent2 text-white;
    }
</style>