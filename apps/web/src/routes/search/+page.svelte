<script lang="ts">
	import { MagnifyingGlass } from 'phosphor-svelte';
	import Input from '$components/Forms/Input.svelte';
    import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import Search from '$views/Search.svelte';

    export let query: string = $page.url.searchParams.get('q') ?? '';

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
</script>

<Search bind:value={query} />