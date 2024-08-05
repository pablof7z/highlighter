<script lang="ts">
	import { page } from '$app/stores';
	import { modalState } from '$stores/layout';
	import { onDestroy, onMount } from 'svelte';
	import { action, onBeforeClose } from "svelte-modals";
    import { closeModal } from '$utils/modal';
	import { beforeNavigate } from '$app/navigation';
	import { appMobileView } from '$stores/app';
	import { NavigationOption } from '../../app';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';
    import * as Dialog from "$lib/components/ui/dialog/index.js";
    import * as Drawer from "$lib/components/ui/drawer/index.js";
    import { Keyboard } from '@capacitor/keyboard';
	import { isMobileBuild } from '$utils/view/mobile';
    import * as Modal from "./Modal";

    export let title: string | undefined = undefined;
    export let open = true;

    /**
     * Buttons to render on the shell
     */
    export let actionButtons: NavigationOption[] = [];

    const slideAnimationDuration = 300;

    let url = $page.url.pathname;
    $: if ($page.url.pathname !== url) closeModal();

    let mounted = false;
    let containerEl: HTMLElement;
    let kHeight = 0;

    if (isMobileBuild()) {
        Keyboard.addListener("keyboardWillHide", () => {
            kHeight = 0;
        });
        
        Keyboard.addListener('keyboardWillShow', info => {
            const { keyboardHeight } = info;
            kHeight = keyboardHeight;
        });
    }

    onMount(() => {
        mounted = true;
        $modalState = "open";
    });

    beforeNavigate(() => {
        $modalState = "closing";
        // $modal = null;
    })

    if (!$appMobileView) {
        onBeforeClose(() => {
            if (mounted === true) {
                $modalState = "closing";
                mounted = false;
                setTimeout(closeModal, slideAnimationDuration);
                return false;
            }
        });
    }

    onDestroy(() => {
        $modalState = "closed";
    })
</script>

{#if !$appMobileView}
    <Dialog.Root bind:open>
        <Dialog.Content class="sm:max-w-[425px]">
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
                        {#if $$slots.footerExtra}
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
            class="{$$props.class??""} transition-all duration-500 max-h-[calc(100vh-2rem)] overflow-y-auto"
            style="padding-bottom: {kHeight}px;"
        >
        <Drawer.Header class="text-left flex flex-row w-full justify-between items-end">
            {#if title}
                <Drawer.Title class="truncate grow">{title}</Drawer.Title>
            {:else if actionButtons}
                <div class="w-full grow"></div>
                {#each actionButtons as option, index (option.id ?? option.name ?? option.href)}
                    <Modal.Shell.DrawerButton {option} {index} />
                {/each}
            {/if}
        </Drawer.Header>
        <slot />
        </Drawer.Content>
    </Drawer.Root>
{/if}

