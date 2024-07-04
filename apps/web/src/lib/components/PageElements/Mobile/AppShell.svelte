<script lang="ts">
    import { App, Page } from 'konsta/svelte';
	import MobileLayoutNavigation from './MobileLayoutNavigation.svelte';
	import MobileLayoutHeader from './MobileLayoutHeader.svelte';
	import MobileFloatNewPostButton from './MobileFloatNewPostButton.svelte';
	import Modal from '../Modal.svelte';
	import { appMobileHideNewPostButton } from '$stores/app';
    import { PageTransitionController, push } from 'sveltekit-page-transitions'
	import { isMobileBuild } from '$utils/view/mobile';
    import { App as CapacitorApp, URLOpenListenerEvent } from '@capacitor/app';
	import { browser } from '$app/environment';
    import { Badge } from '@capawesome/capacitor-badge';
    import { PushNotifications } from "@capacitor/push-notifications";
	import { goto } from '$app/navigation';
	import { mobileNotifications, unreadNotifications } from '$stores/notifications';
	import PromptForNotifications from '$views/Mobile/Pages/PromptForNotifications.svelte';
    import { Toaster } from "$lib/components/ui/sonner";
	import { layoutMode, pageHeader } from '$stores/layout';

    let showPromptForNotificiations = false;

    if (isMobileBuild() && browser) {
        CapacitorApp.addListener('appUrlOpen', (event: URLOpenListenerEvent) => {
            const url = new URL(event.url);
            // get the path and query string from the URL
            goto(url.pathname + url.search);

            PushNotifications.checkPermissions().then((perm) => {
                console.log({perm});
            });

            if ($mobileNotifications === null) {
                Badge.isSupported().then(({isSupported}) => {
                    if (isSupported) {
                        showPromptForNotificiations = true;
                    } else {
                        console.log('badge is not supported')
                    }
                })
            }
        });
    }

    $: if (isMobileBuild() && browser) {
        if ($unreadNotifications > 0) {
            Badge.set({ count: $unreadNotifications });
        } else {
            Badge.clear()
        }
    }
</script>

<App theme="ios" safeAreas={true} class="k-ios">
    <PageTransitionController transition={push}>
        {#if showPromptForNotificiations}
            <PromptForNotifications on:done={() => showPromptForNotificiations = false} />
        {:else}
        <Page>
            <MobileLayoutHeader />

            {#if $pageHeader?.footer}
                <div class="left-0 bottom-0 fixed transition-all duration-300 z-50 w-full hairline-t">
                    <svelte:component this={$pageHeader.footer.component} {...$pageHeader.footer.props} />
                </div>
            {/if}
        
            <slot />
            <Modal />
        </Page>

        <!-- {#if !$appMobileHideNewPostButton && $layoutMode !== "mobile-full-screen"}
            <MobileFloatNewPostButton />
        {/if} -->
        {/if}
        <Toaster />
    </PageTransitionController>
</App>