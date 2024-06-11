<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
	import { pageHeader, resetLayout } from "$stores/layout";
	import { onDestroy, onMount } from "svelte";
    import { PageTransition } from 'sveltekit-page-transitions';

    let eventId: string | null;
    let ignoreHeader: boolean;

    $: eventId = $page.url.searchParams.get('eventId');
    $: ignoreHeader = !!$page.url.searchParams.get('ignoreHeader');

    $appMobileHideNewPostButton = true;

    let prevPageHeader: any;

    onMount(() => {
        prevPageHeader = $pageHeader;
    })

    onDestroy(() => {
        resetLayout();
        $pageHeader = prevPageHeader;
    });
</script>

<PageTransition>
{#if eventId}
    {#key eventId}
        <WithItem tagId={eventId} let:event let:article>
            <ItemView event={article ?? event} {ignoreHeader} />
        </WithItem>
    {/key}
{/if}
</PageTransition>