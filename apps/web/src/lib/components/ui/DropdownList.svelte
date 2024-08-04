<script lang="ts">
	import { NavigationOption } from "../../../app";
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import Button from "./button/button.svelte";
	import { CaretDown } from "phosphor-svelte";

    export let options: NavigationOption[] = [];
</script>

<DropdownMenu.Root>
    <DropdownMenu.Trigger>
        <Button variant="accent" class="rounded-full">
            {options[0].name}

            <CaretDown size={16} class="ml-2" />
        </Button>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content class="bg-accent text-accent-foreground">
        <DropdownMenu.Group>
            <DropdownMenu.Label>My Account</DropdownMenu.Label>
            <DropdownMenu.Separator />
            {#each options as option}
                <DropdownMenu.Item>
                    {#if option.icon}
                        <svelte:component this={option.icon} class="w-6 lg:w-5 h-6 lg:h-5 inline" {...option.iconProps??{}} />
                    {/if}
                    {option.name}
                </DropdownMenu.Item>
            {/each}
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>