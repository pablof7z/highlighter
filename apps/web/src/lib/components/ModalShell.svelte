<script lang="ts">
	import { page } from '$app/stores';
	import { modalState } from '$stores/layout';
	import { onDestroy, onMount } from 'svelte';
	import { onBeforeClose } from "svelte-modals";
    import { closeModal } from '$utils/modal';
	import { beforeNavigate } from '$app/navigation';
	import { appMobileView } from '$stores/app';
	import { NavigationOption } from '../../app';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';
	import { Button } from './ui/button';
    import * as Dialog from "$lib/components/ui/dialog/index.js";
    import * as Drawer from "$lib/components/ui/drawer/index.js";

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
        window.visualViewport?.removeEventListener("resize", resizeHandler);
    })

    const viewport = window.visualViewport;

    onMount(() => {
        if (viewport) window.visualViewport?.addEventListener("resize", resizeHandler);

        // add an event listener that fires on any input element focus
        document.body.addEventListener("focus", resizeHandler);
        document.body.addEventListener("blur", resizeHandler);
    })

    let height = viewport?.height;

    function resizeHandler() {
        if (!containerEl) return;
        
        if (!/iPhone|iPad|iPod/.test(window.navigator.userAgent)&& viewport?.height && height && viewport.height !== height) {
            containerEl.style.bottom = `${height - viewport.height + 10}px`;
        }
    }
</script>

{#if !$appMobileView}
    <Dialog.Root bind:open>
        <Dialog.Content class="sm:max-w-[425px]">
            <Dialog.Header>
                <Dialog.Title>{title}</Dialog.Title>
            </Dialog.Header>

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
    <Drawer.Content>
      <Drawer.Header class="text-left flex flex-row w-full justify-between items-end">
        <Drawer.Title class="truncate grow">{title}</Drawer.Title>
        <div class="w-fit">
            <HorizontalOptionsList options={actionButtons} />

        </div>
      </Drawer.Header>
      <slot />
    </Drawer.Content>
  </Drawer.Root>
{/if}

