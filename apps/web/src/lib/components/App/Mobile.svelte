<script lang="ts">
	import { browser } from '$app/environment';
    import { isMobileBuild } from '$utils/view/mobile';
    import { App as CapacitorApp, URLOpenListenerEvent } from '@capacitor/app';
    import { PushNotifications } from "@capacitor/push-notifications";
    import { Badge } from '@capawesome/capacitor-badge';
    import { goto } from '$app/navigation';
    import { mobileNotifications, unreadNotifications } from '$stores/notifications';

    export let showPromptForNotificiations = false;
    
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