<script lang="ts">
	import { Button } from "$components/ui/button";
	import { layout, pageHeader } from "$stores/layout";
	import { X, CaretLeft, DotsThreeVertical } from "phosphor-svelte";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { options } from "marked";
</script>

{#if $layout.options && $layout.options?.length > 0}
    <div class="flex flex-row gap-2">
        {#if $layout.options?.length === 1}
            <Button
                {...$layout.options[0].props??{}}
                href={$layout.options[0].href}
                on:click={$layout.options[0].fn}
            >
                {$layout.options[0].name}
            </Button>
        {:else}
            <DropdownMenu.Root>
                <DropdownMenu.Trigger>
                    <Button variant="secondary" class="rounded-full w-11 h-11 p-0">
                        <DotsThreeVertical size={24} />
                    </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content>
                    <DropdownMenu.Group>
                        {#each $layout.options as option (option.id??option.name??option.value)}
                            <DropdownMenu.Item href={option.href}>
                                {option.name}
                            </DropdownMenu.Item>
                        {/each}
                    </DropdownMenu.Group>
                </DropdownMenu.Content>
            </DropdownMenu.Root>
        {/if}
    </div>
{/if}
