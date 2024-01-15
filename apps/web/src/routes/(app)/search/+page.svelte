<script lang="ts">
	import { MagnifyingGlass } from 'phosphor-svelte';
	import Input from '$components/Forms/Input.svelte';
    import { page } from '$app/stores';
	import { goto } from '$app/navigation';

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

<div class="max-w-xl mx-auto">
    <div class="join join-horizontal w-full">
        <Input
            placeholder="Type a URL to highlight"
            color="black"
            bind:value={query}
            on:keydown={onKeyDown}
            class="w-full text-xl join-item"
            type="search"
            autofocus
        />
        <button class="button join-item px-5">
            <MagnifyingGlass />
        </button>
    </div>
</div>