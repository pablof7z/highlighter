<script lang="ts">
	import { CaretDown } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import { Editor } from "svelte-tiptap";

    export let editor: Editor;
    
    let heading: string | undefined = 'body';

    const update = () => {
        heading = editor.isActive('heading', { level: 1 }) ? '1' : undefined; 
        heading ??= editor.isActive('heading', { level: 2 }) ? '2' : undefined; 
        heading ??= editor.isActive('heading', { level: 3 }) ? '3' : undefined;
        heading ??= 'body';
    }
    editor.on("transaction", update);
    editor.on("update", update);
    
    function set(style?: number) {
        return () => {
            let level: number;

            if (style) level = style;
            else if (heading) level = parseInt(heading);
            else level = 1;
            
            editor.chain().focus().toggleHeading({ level }).run()
        }
    }
</script>

<DropdownMenu.Root>
    <DropdownMenu.Trigger class="!w-auto whitespace-nowrap text-sm">
            {#if !heading || heading === 'body'}
                Normal text
            {:else}
                Heading {heading}
            {/if}

            <CaretDown class="ml-2" />
    </DropdownMenu.Trigger>

    <DropdownMenu.Content class="absolute z-[999999]">
        <DropdownMenu.RadioGroup value={heading} on:change={console.log}>
            <DropdownMenu.RadioItem value="body" on:click={set()}>
                Normal text
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="1" on:click={set(1)}>
                Heading 1
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="2" on:click={set(2)}>
                Heading 2  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="3" on:click={set(3)}>
                Heading 3  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="4" on:click={set(4)}>
                Heading 4  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="5" on:click={set(5)}>
                Heading 5  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="6" on:click={set(6)}>
                Heading 6  
            </DropdownMenu.RadioItem>
        </DropdownMenu.RadioGroup>
    </DropdownMenu.Content>
</DropdownMenu.Root>