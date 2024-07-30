<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
    import { PageTransition } from 'sveltekit-page-transitions';
    import * as Content from "$components/Content";

    let eventId: string | null;
    let ignoreHeader: boolean;
    let mode: string;

    $: eventId = $page.url.searchParams.get('eventId');
    $: ignoreHeader = !!$page.url.searchParams.get('ignoreHeader');
    $: mode = $page.url.searchParams.get('view') || 'event';

    let prevPageHeader: any;
</script>

<PageTransition>
    {#if eventId}
        {#key eventId}
            <WithItem tagId={eventId} let:event>
                {#if event}
                    <Content.Shell {event}>
                        {#if mode === 'event'}
                            <Content.Body />
                        {:else if mode === "comments"}
                            <Content.Comments />
                        {/if}
                    </Content.Shell>
                {/if}
            </WithItem>
        {/key}
    {/if}
</PageTransition>