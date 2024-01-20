<script lang="ts">
    import { getUserHighlights } from "$stores/user-view";

    export let value: string = "Publications";
    export let name: string = "this user"

    const highlights = getUserHighlights();
</script>

<div class="py-4 border-t border-b border-neutral-800 justify-start items-start gap-4 inline-flex w-full mb-6">
    <div class="justify-start items-start gap-4 flex w-full">
        <button
            on:click={() => value = "Publications"}
            class:active={value === "Publications"}
        >Publications</button>
        <div class="tooltip" data-tip="Curations created by {name}">
            <button
                on:click={() => value = "Curations"}
                class:active={value === "Curations"}
            >Curations</button>
        </div>
        {#if $highlights.length > 0}
            <div class="tooltip" data-tip="Highlights made by {name}">
                <button
                    on:click={() => value = "Highlights"}
                    class:active={value === "Highlights"}
                >Highlights</button>
            </div>
        {/if}
        <div class="tooltip" data-tip="Explore creators {name} supports">
            <button
                on:click={() => value = "Supported Creators"}
                class:active={value === "Supported Creators"}
            >Supported Creators</button>
        </div>
        <div class="flex-grow"></div>
        <div class="tooltip" data-tip="Got premium access? Hangout with the community that surrounds {name}">
            <button
                on:click={() => value = "Backstage"}
                class:active={value === "Backstage"}
            class="backstage">Backstage</button>
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