<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
    import Input from '$components/ui/input/input.svelte';
	import SearchModal from '$modals/SearchModal.svelte';
	import { pageHeader, searching } from '$stores/layout';
	import { openModal } from '$utils/modal';
	import { ndk } from "$stores/ndk";
	import { nip19 } from 'nostr-tools';
	import { MagnifyingGlass, PaperPlaneRight } from 'phosphor-svelte';
    import { createEventDispatcher, onMount } from 'svelte';
	import { fade, slide } from 'svelte/transition';
	import { Drawer } from 'vaul-svelte';

    export let value: string = "";

    onMount(() => {
        value = $page.url.searchParams.get("q") ?? "";
    })

    const dispatch = createEventDispatcher();

    function redirectTo(url: string) {
        dispatch("searched");
        goto(url);
        $searching = false;
    }

    function looksLikeEmail(str: string) {
        return str.includes("@") && str.includes(".");
    }

    function looksLikeHashtag(str: string) {
        return str.startsWith("#");
    }

    function looksLikeNpub(str: string) {
        return !!str.match(/^(npub1|nprofile1)/);
    }

    function looksLikeNpub19(str: string) {
        if (str.match(/^(nevent1|note1|naddr1)/)) {
            try {
                nip19.decode(str);
                return true;
            } catch (e) {
                return false;
            }
        }

        return false;
    }

    function looksLikeUrl(str: string) {
        try {
            new URL(str);
            return true;
        } catch (e) {
            return false;
        }
    }

    function search() {
        $searching = true;
        if (looksLikeHashtag(value)) {
            return redirectTo(`/search?q=${encodeURIComponent(value)}`);
        }

        if (looksLikeEmail(value)) {
            $ndk.getUserFromNip05(value).then(user => {
                if (user) return redirectTo(`/${value}`);
            });
        }

        if (looksLikeNpub(value)) {
            return redirectTo(`/${value}`);
        }

        if (looksLikeNpub19(value)) {
            return redirectTo(`/e/${value}`);
        }

        if (looksLikeUrl(value)) {
            return redirectTo(`/load?url=${encodeURIComponent(value)}`);
        }

        if ($pageHeader?.searchFn) {
            return $pageHeader.searchFn(value);
        }
    }

    async function keyup(event: KeyboardEvent) {
        if (event.key === "Enter") {
            search();
            (event.target as HTMLInputElement).blur();
        }
    }

    let noFocus = true;
</script>

<div class="flex flex-col gap-6 w-full mx-auto sm:px-4 relative max-w-3xl {$$props.class??""}">
    <MagnifyingGlass class="absolute top-1/2 max-sm:hidden sm:left-6 transform -translate-y-1/2 w-6 h-6 text-neutral-500" />

    <Input
        bind:value
        color="black"
        label="Search"
        placeholder="Search or enter a URL to highlight"
        class="sm:pl-14 {$$props.inputClass??""}"
        on:keyup={keyup}
        on:focus={() => openModal(SearchModal)}
        on:blur={() => noFocus = true}
        {...{autofocus: $$props.autofocus}}
    />
    <button class="absolute top-1/2
        right-0 sm:right-4 transform -translate-y-1/2 w-6 h-6 text-neutral-500 hover:!text-accent focus:!text-accent transition-all duration-300" on:click={search}>
        <PaperPlaneRight class="w-full h-full" />
    </button>
</div>

{#if !noFocus}
    <button
        class="
            absolute sm:fixed top-16 left-0 w-screen h-screen bg-background opacity-80 z-40
            sm:pl-20
        "
        on:click={() => dispatch("dismiss")}
        transition:fade={{duration: 300}}
    />
{/if}