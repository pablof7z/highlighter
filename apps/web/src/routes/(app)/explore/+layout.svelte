<script lang="ts">
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import { pageHeader } from '$stores/layout';

    const marginClass ="w-full";

    $pageHeader = {
        title: "Discover"
    }
</script>

<MainWrapper {marginClass}>
    <slot />
</MainWrapper>
