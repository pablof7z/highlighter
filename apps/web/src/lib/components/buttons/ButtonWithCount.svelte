<script lang="ts">
	import { pluralize } from "$utils";

    export let count: number;
    export let href: string | undefined = undefined;
    export let label: string | undefined = undefined;
    export let active: boolean = false;
</script>

{#if href}
    <a {href} class:active>
        <slot />
        {#if count > 0}
            <span>{count}</span>
            {#if label}
                <span>{pluralize(count, label)}</span>
            {/if}
        {/if}
    </a>
{:else}
    <button on:click class:active>
        <slot />
        {#if count > 0}
            <span>{count}</span>
            {#if label}
                <span>{pluralize(count, label)}</span>
            {/if}
        {/if}
    </button>
{/if}

<style lang="postcss">
    a, button {
        @apply flex flex-row items-center gap-2;
    }

    a.active, button.active {
        @apply text-white;
    }
</style>