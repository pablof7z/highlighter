<script lang="ts">
	import { goto } from '$app/navigation';
    import Input from '$components/Forms/Input.svelte';
	import { ndk } from '@kind0/ui-common';
	import { nip19 } from 'nostr-tools';
	import { MagnifyingGlass, PaperPlaneRight } from 'phosphor-svelte';

    export let value: string = "";

    let searching = false;

    function redirectTo(url: string) {
        goto(url);
        searching = false;
    }

    function looksLikeEmail(str: string) {
        return str.includes("@") && str.includes(".");
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
        searching = true;
        if (looksLikeEmail(value)) {
            $ndk.getUserFromNip05(value).then(user => {
                if (user) return redirectTo(`/${value}`);
            });
        }

        if (looksLikeNpub19(value)) {
            return redirectTo(`/e/${value}`);
        }

        if (looksLikeUrl(value)) {
            return redirectTo(`/load?url=${encodeURIComponent(value)}`);
        }
    }

    async function keyup(event: KeyboardEvent) {
        if (event.key === "Enter") {
            search();
        }
    }
</script>

<div class="flex flex-col gap-6 w-full mx-auto sm:px-4 relative max-w-3xl {$$props.class??""}">
    {#if !searching}
        <MagnifyingGlass class="absolute top-1/2 sm:left-4 transform -translate-y-1/2 w-6 h-6 text-neutral-500" />
    {:else}
        <div class="absolute top-1/2 sm:left-4 transform -translate-y-1/2 w-6 h-6 text-neutral-500">
            <span class="loading loading-sm text-accent2"></span>
        </div>
    {/if}
    <Input
        bind:value
        color="black"
        label="Search"
        placeholder="Search or enter a URL to highlight"
        class="grow basis-0 sm:bg-base-200 border-none font-normal pl-14 placeholder:!text-neutral-500 !rounded-full !text-neutral-300
        sm:focus:outline sm:focus:!outline-base-300 {$$props.inputClass??""}"
        on:keyup={keyup}
    />
    <button class="absolute top-1/2
        right-0 sm:right-4 transform -translate-y-1/2 w-6 h-6 text-neutral-500 hover:!text-accent2 focus:!text-accent2 transition-all duration-300" on:click={search}>
        <PaperPlaneRight class="w-full h-full" />
    </button>
</div>
