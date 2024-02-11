<script lang="ts">
    import { pageSidebar } from '$stores/layout.js';
    import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';

    $pageSidebar = {
        component: CreatorOnboardingActions,
        props: {
            sidebarView: true
        }
    }

    onDestroy(() => { $pageSidebar = null; })
</script>

<slot />