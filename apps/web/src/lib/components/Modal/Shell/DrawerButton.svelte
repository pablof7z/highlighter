<script lang="ts">
	import { NavigationOption } from "../../../../app";
    import Button from "$components/ui/button/button.svelte";
	import { cn } from "$utils";

    export let option: NavigationOption;
    export let index: number;
    export let total: number;

    let isLast: boolean;
    $: isLast = total === index -1;

    let variant: string;
    $: if (!option.buttonProps?.variant) {
        if (isLast) {
            variant = "default";
        } else {
            variant = "secondary";
        }
    } else {
        variant = option.buttonProps.variant;
    }
</script>

<Button
    href={option.href}
    {...option.buttonProps??{}}
    {variant}
    size="sm"
    on:click
    class={cn('gap-2', option.buttonProps?.class)}
>
    {#if option.icon}
        <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
    {/if}
    {#if option.name}
        <span class="max-sm:text-base {$$props.class??""}" class:hidden={!option.name}>
            {option.name}
        </span>
    {/if}
</Button>