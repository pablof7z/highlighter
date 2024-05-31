<script lang="ts">
	import { pageHeader } from '$stores/layout';
	import { inview } from 'svelte-inview';

    /**
     * Title of the local page -- this will be displayed in the page
     */
    export let title: string;

    /**
     * This is the default title that will be shown
     * while the title is visible in the page.
     */
    export let defaultTitle: string | undefined = undefined;

    function titleInView() {
        if (!$pageHeader) return;
        $pageHeader.title = defaultTitle;
    }

    function titleOutOfView() {
        if (!$pageHeader) return;
        $pageHeader.title = title ?? defaultTitle ?? "";
    }
</script>

<h1 class={$$props.class??""} use:inview on:inview_enter={titleInView} on:inview_leave={titleOutOfView}>
    {title}
</h1>