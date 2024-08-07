<script lang="ts">
	import { page } from '$app/stores';
    import { closeModal } from '$utils/modal';
	import { appMobileView } from '$stores/app';
	import { NavigationOption } from '../../app';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';
    import * as Dialog from "$lib/components/ui/dialog/index.js";
    import * as Drawer from "$lib/components/ui/drawer/index.js";
    import { Keyboard } from '@capacitor/keyboard';
	import { isMobileBuild } from '$utils/view/mobile';
    import * as Modal from "./Modal";
	import { action } from 'svelte-modals';
	import { onMount } from 'svelte';

    export let title: string | undefined = undefined;
    export let open = true;
    export let padding = "responsive-padding";

    export let secondaryButtons: NavigationOption[] | undefined = undefined;
    
    /**
     * Buttons to render on the shell
     */
    export let actionButtons: NavigationOption[] = [];


    let url = $page.url.pathname;
    $: if ($page.url.pathname !== url) closeModal();

    let kHeight = 0;

    if (isMobileBuild()) {
        try {
            Keyboard.addListener("keyboardWillHide", () => {
                kHeight = 0;
            });
            
            Keyboard.addListener('keyboardWillShow', info => {
                const { keyboardHeight } = info;
                kHeight = keyboardHeight;
            });
        } catch {}
    }
</script>

<!-- <div class="fixed top-52 left-2 bg-red-500 p-4 z-[9999999]">
    {kHeight}
</div> -->

{#if !$appMobileView}
    <Dialog.Root bind:open>
        <Dialog.Content class="{$$props.class??""}">
            {#if title}
                <Dialog.Header>
                    <Dialog.Title>{title}</Dialog.Title>
                </Dialog.Header>
            {/if}

            <slot />

            <Dialog.Footer>
                {#if $$slots.footer}
                    <div class="w-full flex flex-row gap-4 items-center justify-end flex-none mt-4">
                        <slot name="footer" />
                    </div>
                {:else if actionButtons.length > 0}
                    <div class="w-full flex flex-row gap-4 items-center justify-between flex-none mt-4">
                        {#if secondaryButtons}
                            <div>
                                <HorizontalOptionsList options={secondaryButtons} activeOption={false} />
                            </div>
                        {:else if $$slots.footerExtra}
                            <slot name="footerExtra" />
                        {:else}
                            <div class="grow"></div>
                        {/if}
                        
                        <div>
                            <HorizontalOptionsList options={actionButtons} />
                        </div>
                    </div>
                {/if}
            </Dialog.Footer>
        </Dialog.Content>
    </Dialog.Root>
{:else}
    <Drawer.Root shouldScaleBackground bind:open>
        <Drawer.Content
            class="
                {padding}
                transition-all duration-500 overflow-y-auto
                {$$props.class??""}
            "
            style="padding-bottom: {kHeight}px; max-height: calc(100dvh - 2rem);"
        >
        <Drawer.Header class="text-left flex flex-row w-full justify-between items-end">
            {#if title}
                <Drawer.Title class="truncate grow">{title}</Drawer.Title>
            {:else}
                <div class="w-full grow"></div>
            {/if}
            {#if actionButtons}
                {#each actionButtons as option, index (option.id ?? option.name ?? option.href)}
                    <Modal.Shell.DrawerButton total={actionButtons.length} {option} {index} />
                {/each}
            {/if}
        </Drawer.Header>
        <slot />

        {#if secondaryButtons}
            <Drawer.Footer>
                <HorizontalOptionsList options={secondaryButtons} activeOption={false} />
            </Drawer.Footer>
        {/if}
        
        </Drawer.Content>
    </Drawer.Root>
{/if}

