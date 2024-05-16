<script lang="ts">
    import { App, Page, Block } from 'konsta/svelte';
	import MobileLayoutNavigation from './MobileLayoutNavigation.svelte';
	import MobileLayoutHeader from './MobileLayoutHeader.svelte';
	import MobileFloatNewPostButton from './MobileFloatNewPostButton.svelte';
	import Modal from '../Modal.svelte';
	import { appMobileHideNewPostButton } from '$stores/app';
    import { PageTransitionController, cover } from 'sveltekit-page-transitions'

</script>

<App theme="ios" safeAreas={true} class="k-ios">
    <PageTransitionController transition={cover}>
        <Page>
            <MobileLayoutHeader />
        
            <MobileLayoutNavigation />
            <slot />
            <Block>
                <Modal />
            </Block>
        </Page>

        {#if !$appMobileHideNewPostButton}
            <MobileFloatNewPostButton />
        {/if}
    </PageTransitionController>
</App>