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
	import { goto } from '$app/navigation';
	import { unreadNotifications } from '$stores/notifications';

    if (isMobileBuild() && browser) {
        CapacitorApp.addListener('appUrlOpen', (event: URLOpenListenerEvent) => {
            const url = new URL(event.url);
            // get the path and query string from the URL
            goto(url.pathname + url.search);

            Badge.requestPermissions();
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
        <Page>
            <MobileLayoutHeader />
        
            <MobileLayoutNavigation />
            <slot />
            <Modal />
        </Page>

        {#if !$appMobileHideNewPostButton}
            <MobileFloatNewPostButton />
        {/if}
    </PageTransitionController>
</App>