<script lang="ts">
	import { fade } from 'svelte/transition';
    import { Button } from './button';
    import { Input } from './input';
	import { X } from 'lucide-svelte';

    type Props = {
        value: string[];
        prefix?: string;
        placeholder?: string;
        children?: any;
    }

    let { 
        value = $bindable<string[]>(),
        prefix = '',
        placeholder = '',
        children
    }: Props = $props();

    let newItem = $state('');

    function addNewItem() {
        if (!showInput) {
            setTimeout(() => inputElement?.focus(), 0);
            showInput = true;
            return;
        }
        
        value.push(newItem);
        newItem = '';
    }

    function blur() {
        if (newItem.length === 0 || newItem === prefix) {
            showInput = false;
        }
    }

    function onKeyDown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            addNewItem();
        }
    }

    let showInput = $state(false);
    let inputElement = $state<HTMLInputElement | null>(null);
</script>

<div class="flex flex-col gap-2 my-4">
    {#each value as _, index}
        <div class="flex flex-row items-center justify-between gap-2 group">
            <div class="relative w-full">
                <Input type="text" bind:value={value[index]} {placeholder} />
                {#if children}
                    <div class="absolute right-4 top-1/2 -translate-y-1/2 z-10">
                        {@render children({ value: value[index] })}
                    </div>
                {/if}
            </div>
            <Button variant="secondary" class="w-24 flex-none" onclick={() => value.splice(index, 1)}>Remove</Button>
        </div>
    {/each}

    <div class="flex flex-row items-center justify-between gap-2">
        {#if showInput}
            <div class="grow" transition:fade={{ duration: 100 }}>
                <div class="relative">
                    <Input
                        bind:ref={inputElement}
                        type="text"
                        bind:value={newItem}
                        onblur={blur}
                        {placeholder}
                        onkeydown={onKeyDown}
                        onfocus={() => {
                            if (newItem.length === 0) newItem = prefix;
                        }}
                    />
                </div>
            </div>
        {:else}
            <div class="grow"></div>
        {/if}
        <Button variant={showInput ? "default" : "outline"} class="w-24 flex-none" onclick={addNewItem}>Add</Button>
    </div>
</div>
