<script lang="ts">
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import type { Level } from "@tiptap/extension-heading";
    import { ChevronUp } from 'lucide-svelte';
    import { Editor } from "svelte-tiptap";

    type Props = {
        editor: Editor;
    }

    const { editor }: Props = $props();

    let heading: string | undefined = $state('body');

    const update = () => {
        heading = editor.isActive('heading', { level: 1 }) ? '1' : undefined; 
        heading ??= editor.isActive('heading', { level: 2 }) ? '2' : undefined; 
        heading ??= editor.isActive('heading', { level: 3 }) ? '3' : undefined;
        heading ??= 'body';
    }
    editor.on("transaction", update);
    editor.on("update", update);
    
    function set(style?: Level) {
        return () => {
            let level: Level;

            if (style) level = style;
            else if (heading) level = parseInt(heading) as Level;
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

            <ChevronUp class="ml-2 rotate-180" />
    </DropdownMenu.Trigger>

    <DropdownMenu.Content class="absolute z-[999999]">
        <DropdownMenu.RadioGroup value={heading} onchange={console.log}>
            <DropdownMenu.RadioItem value="body" onclick={set()}>
                Normal text
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="1" onclick={set(1)}>
                Heading 1
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="2" onclick={set(2)}>
                Heading 2  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="3" onclick={set(3)}>
                Heading 3  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="4" onclick={set(4)}>
                Heading 4  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="5" onclick={set(5)}>
                Heading 5  
            </DropdownMenu.RadioItem>
            <DropdownMenu.RadioItem value="6" onclick={set(6)}>
                Heading 6  
            </DropdownMenu.RadioItem>
        </DropdownMenu.RadioGroup>
    </DropdownMenu.Content>
</DropdownMenu.Root>