<script lang="ts">
    import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import Search from '$views/Search.svelte';
	import FilterFeed from '$components/Feed/FilterFeed.svelte';
	import { getNip50RelaySet } from '$utils/ndk';
	import { layout } from '$stores/layout';
	import { onDestroy } from 'svelte';

    $layout.title = 'Search';
    $layout.fullWidth = false;

    onDestroy(() => {
        $layout.fullWidth = undefined;
    });

    export let query: string = $page.url.searchParams.get('q') ?? '';
    let displayResults = true;

    function onKeyDown(e: KeyboardEvent) {
        if (e.key === 'Enter') {
            search();
        }
    }

    async function search() {
        // if the query string is a URL redirect to /load?url=<query>
        if (query.startsWith('https')) {
            const uri = new URL(window.location.href);
            uri.pathname = '/load';
            uri.searchParams.set('url', query);
            goto(uri.toString());
            return;
        }
    }

    $layout.header = {
        component: Search,
        props: {
            value: query,
            onSearch: (q: string) => {
                query = q
                displayResults = false;

                // if ($pageHeader.props) {
                //     $pageHeader.props.value = q;
                //     $pageHeader.props.displayResults = false;

                //     const uri = new URL(window.location.href);
                //     uri.searchParams.set('q', q);
                //     pushState(uri.pathname + uri.search, {});
                // }
                // $pageHeader.props
            },
            displayResults
        }
    }
</script>

<!-- <Search value={query} on:change={(e) => query = e.detail} /> -->
{#if query}
    {#key query}
        <FilterFeed
            filters={[ { search: query } ]}
            relaySet={getNip50RelaySet()}
        />
    {/key}
{/if}