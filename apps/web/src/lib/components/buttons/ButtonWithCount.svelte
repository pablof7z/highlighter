<script lang="ts">
	import Button from "$components/ui/button/button.svelte";
	import { pluralize } from "$utils";
	import { Builder } from "bits-ui";

    export let count: number | string | undefined = undefined;
    export let href: string | undefined = undefined;
    export let label: string | undefined = undefined;
    export let active: boolean = false;
    export let badge = false;
    export let builders: Builder[] = [];

    let showCount = false;

    $: showCount = count !== undefined && (typeof count === 'number' && count > 0 || typeof count === 'string' && count !== '');
</script>

{#if href}
    <a {href} class={$$props.class??""} class:active>
        <slot />
        {#if badge}
            {#if label}
                {label}
            {/if}
            {#if showCount}
                <span class="badge">{count}</span>
            {/if}
        {:else if showCount}
            <span>{count}</span>
            {#if label && typeof count === 'number'}
                <span>{pluralize(count, label)}</span>
            {/if}
        {/if}
    </a>
{:else}
    <Button
        {builders}
        variant="ghost"
        class="bg-opacity-50 text-xs text-muted-foreground font-regular p-2 {$$props.class??""}"
        on:click
        on:mouseenter
        on:mouseleave
    >
        <slot />
        {#if badge}
            {#if label}
                {label}
            {/if}
            {#if showCount}
                <span class="badge bg-foreground/20 text-foreground">{count}</span>
            {/if}
        {:else if showCount}
            <span>{count}</span>
            {#if label && typeof count === 'number'}
                <span>{pluralize(count, label)}</span>
            {/if}
        {/if}
        {#if $$slots.after}
            <slot name="after" />
        {/if}
    </Button>
{/if}

<style lang="postcss">
    a, button {
        @apply flex flex-row items-center gap-2;
    }

    a.active, button.active {
        @apply text-foreground;
    }
</style>