<script lang="ts">
	import { nip19 } from 'nostr-tools';
	import { goto } from "$app/navigation";
	import ItemLink from "$components/Events/ItemLink.svelte";
	import Input from "$components/Forms/Input.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { userFollows } from "$stores/session";
	import { vanityUrls, vanityUrlsByPubkey } from "$utils/const";
	import { getNip50RelaySet } from "$utils/ndk";
	import { SearchResult } from "$utils/search";
	import { searchUser } from "$utils/search/user";
	import { Avatar, Name, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind } from "@nostr-dev-kit/ndk";
	import { ArrowRight, Check, CheckCircle, MagnifyingGlass, UserCircleCheck } from "phosphor-svelte";
	import { SvelteComponent, createEventDispatcher } from "svelte";
	import { page } from '$app/stores';

    export let value: string = "";
    export let onSearch: (q: string) => void;
    export let displayResults = true;

    const dispatch = createEventDispatcher();

    type SearchMode = 'all' | 'articles' | 'hashtag';
    type SearchResultWithExt = SearchResult &
        { url: string } & // url
        { hashtag: string };// hash
    type SearchOption = { searchMode?: SearchMode, id: string, icon: SvelteComponent, label: string, fn: () => Promise<void> };

    let results: (SearchResultWithExt | SearchOption)[] = [];
    let selectedItem = 0;
    let searchMode: SearchMode = 'all';

    let searching = false;

    async function users() {
        const res = await searchUser(value, $ndk, $userFollows);
        for (const user of res) {
            let url = `/${user.nip05}`;

            if (vanityUrlsByPubkey[user.id]) {
                url = vanityUrlsByPubkey[user.id];
            }
            
            results.push({type: 'user', result: user, url, id: user.id});
        }

        results = results;
    }

    async function highlightUrl() {
        goto(`/load?url=${encodeURIComponent(value)}`);
    }

    function searchAll() {
        if ($page.url.pathname === '/search') {
            onSearch(value);
            dispatch("change", value);
        } else {
            goto('/search?q=' + encodeURIComponent(value));
        }
    }
    
    async function searchArticle() {
        searching = true;
        results = [];
        searchMode = 'articles';
        const res = await $ndk.fetchEvents([
            {kinds: [NDKKind.Article], limit: 10, search: value}
        ], undefined, getNip50RelaySet());

        for (const event of res) {
            console.log(event.rawEvent());
            results.push({ type: "event", result: NDKArticle.from(event), url: `/a/${event.encode()}`, id: event.id });
        }

        searching = false;

        results = results;
    }
    
    async function keydown(event: KeyboardEvent) {
        if (value.length === 0) {
            searchMode = 'all';
            results = [];
            return;
        }

        displayResults = true;

        // if value is a bech32 event
        try {
            nip19.decode(value);
            const e = await $ndk.fetchEvent(value);
            if (e) {
                if (e.isParamReplaceable()) {
                    goto(`/a/${e.encode()}`);
                } else {
                    goto(`/e/${e.encode()}`);
                }
            }
        } catch {} 
        
        if (event.key === "Enter") {
            const selected = results[selectedItem];
            if (selected) {
                if (selected.url) {
                    dispatch("done");
                    goto(selected.url);
                } else if (selected.fn) {
                    await selected.fn();
                }
            }
        } else if (event.key === "ArrowDown") {
            selectedItem = Math.min(selectedItem + 1, results.length - 1);
            // scroll to selected item
            document.querySelector(`li:nth-child(${selectedItem + 1})`)?.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "nearest" });
            
        } else if (event.key === "ArrowUp") {
            selectedItem = Math.max(selectedItem - 1, 0);

            document.querySelector(`li:nth-child(${selectedItem - 1})`)?.scrollIntoView({ behavior: "smooth", block: "nearest", inline: "nearest" });
        } else if (event.key.match(/[a-zA-Z0-9]/)) {
            results = [];

            if (value.match(/^\#\w+/)) {
                results.push({ id: 'search-hashtag', label: `Search for '${value}'`, fn: () => goto(`/t/${encodeURIComponent(value.slice(1, -1))}`) });
            }

            // is URI
            if (isUri()) {
                console.log("is uri");
            } else {
                console.log({searchMode});
                results.push({ id: 'search-articles', label: `Search articles with '${value}'`, icon: MagnifyingGlass, fn: searchArticle });
                results.push({ id: 'search-all', label: `Search everywhere for '${value}'`, icon: MagnifyingGlass, fn: searchAll });
                results = results;
                if ( searchMode === 'all') await users();
                console.log(results);
            }

            results = results;
        }
    }

    function isUri() {
        try {
            new URL(value);
            results.push({ id: 'highlight-url', icon: ArrowRight, label: `Highlight '${value}'`, fn: highlightUrl });
            return true;
        } catch {
            return false;
        }
    }

    let renderedResults: (SearchResultWithExt | SearchOption)[] = [];
    $: {
        renderedResults = results.slice(0, 10);
        for (const result of results.slice(11, -1)) {
            if (result.fn) renderedResults.push(result);
        }
        renderedResults = renderedResults;
    }
</script>

<div class="
    flex flex-row gap-2 w-full items-center border-b border-base-300 {$$props.inputContainerClass??""}
    {$$props.containerClass??""}
">
    {#if searching}
        <span class="loading loading-sm text-accent2"></span>
    {:else}
        <MagnifyingGlass class="w-8 h-8 text-neutral-500" />
    {/if}
    
    <Input
        color="black"
        bind:value
        placeholder="Search"
        autofocus={true}
        class="bg-transparent w-full border-none text-xl"
        on:keyup={keydown}
        on:focus={() => displayResults = true}
    />
</div>

{#if value.length > 0 && displayResults}
    <ul class="flex flex-col items-start grow overflow-y-auto w-full pt-6 {$$props.containerClass??""}">
        {#each renderedResults as {type, icon, label, result, id, fn}, i (id + i)}
            {#if type === "user"}
                <li class:selected={i === selectedItem}>
                    <a href="/{result.nip05}" class="flex flex-row gap-2 items-center">
                        <AvatarWithName userProfile={result.profile} avatarSize="small" />
                        {#if result.followed}
                            <UserCircleCheck class="w-6 h-6 text-accent2" />
                        {/if}
                    </a>
                </li>
            {:else if type === "event"}
                <li class:selected={i === selectedItem}>
                    <ItemLink event={result} />
                </li>
            {:else if fn}
                <li class:selected={i === selectedItem}>
                    <button on:click={fn}>
                        {#if icon}
                            <svelte:component this={icon} class="w-6 h-6 mr-2 inline" />
                        {/if}
                        {label}
                    </button>
                </li>
            {/if}
        {/each}
    </ul>
{/if}

<style lang="postcss">
    li {
        @apply p-2 px-4 w-full rounded-lg;
    }
    
    li.selected, li:hover {
        @apply bg-base-300;
    }
</style>