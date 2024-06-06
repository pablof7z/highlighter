<script lang="ts">
	import { pluralize } from "$utils";

    export let count: number;
    export let href: string | undefined = undefined;
    export let label: string | undefined = undefined;
    export let active: boolean = false;
    export let badge = false;
</script>

{#if href}
    <a {href} class={$$props.class??""} class:active>
        <slot />
        {#if badge}
            {#if label}
                {label}
            {/if}
            {#if count > 0}
                <span class="badge">{count}</span>
            {/if}
        {:else if count > 0}
            <span>{count}</span>
            {#if label}
                <span>{pluralize(count, label)}</span>
            {/if}
        {/if}
    </a>
{:else}
    <button class={$$props.class??""} class:active on:click>
        <slot />
        {#if badge}
            {#if label}
                {label}
            {/if}
            {#if count > 0}
                <span class="badge bg-foreground/20 text-foreground">{count}</span>
            {/if}
        {:else if count > 0}
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
        @apply text-foreground;
    }
</style>