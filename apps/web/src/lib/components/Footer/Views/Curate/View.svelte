<script lang="ts">
	import Curation from "$components/Content/Article/Curation.svelte";
	import { OpenFn } from "$components/Footer";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { State } from ".";
	import { Writable } from "svelte/store";
	import NewCuration from "$components/Content/Article/NewCuration.svelte";
	import { userArticleCurations } from "$stores/session";

    export let article: NDKArticle;
    export let open: OpenFn;
    export let stateStore: Writable<State>;

    if ($userArticleCurations.size === 0) {
        $stateStore.showNew = true;
    }
</script>

{#if $stateStore.showNew}
    <h1>New Curation</h1>
    <NewCuration
        {article}
        bind:forceSave={$stateStore.forceSaveNewCollection}
        on:close={() => open(false)}
    />
{:else}
    <Curation
        {article}
        bind:forceSave={$stateStore.forceSaveCollections}
        on:close={() => open(false)}
    />
{/if}