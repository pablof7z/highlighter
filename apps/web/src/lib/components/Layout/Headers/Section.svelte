<script lang="ts">
	import BackButton from "$components/PageElements/Navigation/BackButton.svelte";
	import { NavigationOption } from "../../../../app";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { Button } from "$components/ui/button";
	import { CaretDown } from "phosphor-svelte";
	import { layout } from "$stores/layout";

    export let title: string = $layout.title ?? "Highlighter";
    export let backUrl: string;
    export let options: NavigationOption[] = [];
    export let selectedOption: NavigationOption | undefined = options[0];
    export let placeholder = "Select";

    $: if (!selectedOption && options.length > 0) {
        selectedOption = options[0];
    }
</script>

<div class="flex flex-row items-center">
    <BackButton href={backUrl} />

    <span class="title grow truncate">
        {title}
    </span>

    {#if options.length > 0}
        <div class="flex flex-row gap-2">
            <DropdownMenu.Root>
                <DropdownMenu.Trigger>
                    <Button variant="accent" class="rounded-full px-6">
                        {selectedOption?.name}
                        <CaretDown class="ml-4" />
                    </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content>
                    <DropdownMenu.Group>
                        {#each options as option (option.id??option.name??option.value)}
                            <DropdownMenu.Item>
                                {option.name}
                            </DropdownMenu.Item>
                        {/each}
                    </DropdownMenu.Group>
                </DropdownMenu.Content>
            </DropdownMenu.Root>
        </div>
    {/if}
</div>

<style lang="postcss">
    .title {
        @apply text-2xl text-foreground font-bold;
    }
</style>