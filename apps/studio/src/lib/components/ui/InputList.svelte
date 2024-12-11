<script lang="ts">
	import { fade } from 'svelte/transition';
    import { Button } from './button';
    import { Input } from './input';

    let { 
        value = $bindable<string[]>(),
        prefix = '',
        placeholder = ''
    } = $props();

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
        <div class="flex flex-row items-center justify-between gap-2">
            <Input type="text" bind:value={value[index]} {placeholder} />
            <Button variant="secondary" class="w-24 flex-none" onclick={() => value.splice(index, 1)}>Remove</Button>
        </div>
    {/each}

    <div class="flex flex-row items-center justify-between gap-2">
        {#if showInput}
            <div class="grow" transition:fade={{ duration: 100 }}>
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
        {:else}
            <div class="grow"></div>
        {/if}
        <Button variant={showInput ? "default" : "outline"} class="w-24 flex-none" onclick={addNewItem}>Add</Button>
    </div>
</div>
