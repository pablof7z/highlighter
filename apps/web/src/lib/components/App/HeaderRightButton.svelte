<script lang="ts">
	import { Button } from "$components/ui/button";
	import { layout } from "$stores/layout";
	import { DotsThreeVertical } from "phosphor-svelte";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { NavigationOption } from "../../../app";

    let firstOption: NavigationOption | undefined;
    $: firstOption = $layout.options?.[0];
</script>

{#if $layout.options}
    {#if $layout.options.length === 1}
        <Button
            href={$layout.options[0].href}
            on:click={$layout.options[0].fn}
            {...$layout.options[0].buttonProps??{}}
            size="sm"
        >
            {$layout.options[0].name}
        </Button>
    {:else if $layout.options.length > 1}
        <div class="flex flex-row gap-2">
            {#if $layout.options?.length === 1}
                <Button
                    {...$layout.options[0].buttonProps??{}}
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
{/if}