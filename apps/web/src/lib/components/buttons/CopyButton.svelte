<script lang="ts">
	import Input from "$components/ui/input/input.svelte";
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
    <div class="flex flex-row items-center gap-2 whitespace-nowrap relative">
        <Input readonly value={copied ? "Copied!" : strData} class="text-lg p-6 pr-12" />
        
        <div class="absolute right-0 top-0 bottom-0 flex flex-row items-center gap-2 p-6 pr-6">
            {#if copied}
                <Check class={cn('w-4 max-sm:w-8 h-4 max-sm:h-8', $$props.iconClass)} />
            {:else }
                <Copy class={cn('w-4 max-sm:w-8 h-4 max-sm:h-8', $$props.iconClass)} />
            {/if}
        </div>

        {#if label}
            {copied ? 'Copied' : label}
        {/if}
    </div>

    {#if $$slots.default}
        <slot />
    {/if}
</button>