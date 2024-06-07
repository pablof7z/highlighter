<script lang="ts">
	import { cn } from "$utils";

    import { Check, Copy } from 'phosphor-svelte';

    export let data: string | object;
    export let label: string | undefined = undefined;

    let strData: string;
    let copied = false;

    if (data instanceof Object)
        strData = JSON.stringify(data, null, 2);
    else
        strData = data;

    function copy() {
        navigator.clipboard.writeText(strData);
        copied = true;

        setTimeout(() => { copied = false; }, 1500);
    }
</script>

<button
    class={$$props.class || ``}
    on:click={copy}
>
    <div class="flex flex-row items-center gap-2 whitespace-nowrap">
        {#if copied}
            <Check class={cn('w-4 h-4', $$props.iconClass)} />
        {:else }
            <Copy class={cn('w-4 h-4', $$props.iconClass)} />
        {/if}

        {#if label}
            {copied ? 'Copied' : label}
        {/if}
    </div>

    {#if $$slots.default}
        <slot />
    {/if}
</button>