<script lang="ts">
	import { pushState } from '$app/navigation';
    import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import Search from '$views/Search.svelte';
	import FilterFeed from '$components/Feed/FilterFeed.svelte';
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { getNip50RelaySet } from '$utils/ndk';
	import { pageHeader } from '$stores/layout';

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

    $pageHeader ??= {}
    $pageHeader.component = Search;
    $pageHeader.props = {
        value: query,
        onSearch: (q: string) => {
            query = q
            displayResults = false;

            if ($pageHeader.props) {
                $pageHeader.props.value = q;
                $pageHeader.props.displayResults = false;

                const uri = new URL(window.location.href);
                uri.searchParams.set('q', q);
                pushState(uri.pathname + uri.search, {});
            }
            $pageHeader.props
        },
        displayResults
    };
</script>

<!-- <Search value={query} on:change={(e) => query = e.detail} /> -->

{#if query}
    <PageTitle title={`Search: ${query}`} />

    {#key query}
        <FilterFeed
            filters={[ { search: query } ]}
            relaySet={getNip50RelaySet()}
        />
    {/key}
{/if}