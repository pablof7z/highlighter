<script lang="ts">
    import { App, Page, Block } from 'konsta/svelte';
	import MobileLayoutNavigation from './MobileLayoutNavigation.svelte';
	import MobileLayoutHeader from './MobileLayoutHeader.svelte';
	import MobileFloatNewPostButton from './MobileFloatNewPostButton.svelte';
	import Modal from '../Modal.svelte';
	import { appMobileHideNewPostButton } from '$stores/app';
    import { PageTransitionController, cover } from 'sveltekit-page-transitions'
	import { isMobileBuild } from '$utils/view/mobile';
    import { App as CapacitorApp, URLOpenListenerEvent } from '@capacitor/app';
	import { browser } from '$app/environment';
    import { Badge } from '@capawesome/capacitor-badge';
    import { PushNotifications } from "@capacitor/push-notifications";
	import { goto } from '$app/navigation';
	import { mobileNotifications, unreadNotifications } from '$stores/notifications';
	import PromptForNotifications from '$views/Mobile/Pages/PromptForNotifications.svelte';

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
    <PageTransitionController transition={cover}>
        {#if showPromptForNotificiations}
            <PromptForNotifications on:done={() => showPromptForNotificiations = false} />
        {:else}
        <Page>
            <MobileLayoutHeader />
        
            <MobileLayoutNavigation />
            <slot />
            <Modal />
        </Page>

        {#if !$appMobileHideNewPostButton}
            <MobileFloatNewPostButton />
        {/if}
        {/if}
    </PageTransitionController>
</App>