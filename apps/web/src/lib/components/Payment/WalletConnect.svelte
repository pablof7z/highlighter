<script lang="ts">
	import WalletConnectAlby from './WalletConnectAlby.svelte';
    import Input from "$components/Forms/Input.svelte";
	import { ArrowDown } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import { page } from '$app/stores';
	import { finalizeLogin } from '$utils/login';
    import { createEventDispatcher } from 'svelte';
	import GlassyInput from '$components/Forms/GlassyInput.svelte';
	import WalletConnectNwa from './WalletConnectNWA.svelte';

    type Mode = "alby" | "mutiny" | "nwc" | "nwa";

    export let mode: Mode | undefined;
    export let nwcUrl: string;

    const dispatch = createEventDispatcher();

    let nwc: string;

    async function nwcConnect(url: string) {
        await fetch("/api/user/nwc", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ nwc: url })
        })
        await finalizeLogin();
        nwcUrl = url;
        dispatch('connected', {url});
    }

    const onSuccess = async (e: CustomEvent<{url: string, nwc: any}>) => {
        const { url, nwc } = e?.detail || {};

        if (url) nwcConnect(url);
        else dispatch('connected', {url});
    }
</script>

{#if !mode}
    <div class="flex-col justify-start items-center gap-3 inline-flex flex-nowrap" transition:slide>
        <button class="button w-full"
            on:click={() => mode = "alby"}
        >
            Connect with Alby
        </button>

        <button class="button w-full" on:click={() => mode = "mutiny"}>
            Connect with Mutiny
        </button>

        <button class="button w-full" on:click={() => mode = "nwa"}>
            Connect with NWA
        </button>

        <div class="self-stretch justify-center items-center gap-3 inline-flex">
            <div class="grow shrink basis-0 h-[0px] border border-neutral-700"></div>
            <div class="text-neutral-500 text-sm font-normal leading-5">OR</div>
            <div class="grow shrink basis-0 h-[0px] border border-neutral-700"></div>
        </div>
        <div class="self-stretch h-[123px] flex-col justify-start items-start gap-1.5 flex">
            <div class="text-whiet text-base font-medium leading-normal">Nostr Wallet Connect</div>
            <GlassyInput
                class="w-full"
                placeholder="Wallet connect URL / pairing secret"
                bind:value={nwc}
            />
            <div class="self-stretch h-[93px] flex-col justify-start items-start gap-1.5 flex">
                <button class="button w-full" on:click={() => nwcConnect(nwc)}>
                    Connect
                </button>
            </div>
        </div>
    </div>
{:else if mode === "mutiny"}
    <div class="flex-col justify-start items-center gap-3 inline-flex flex-nowrap" transition:slide>
        <div class="text-white">

            Add a new Wallet Connection from:
            <div class="text-center flex flex-col items-center">
                <b>Settings</b>
                <ArrowDown />
                <b>Wallet Connections</b>
                <ArrowDown />
                <b>Add Connection</b>
                <ArrowDown />
                and copy the connection string.
                <ArrowDown />
                <Input bind:value={nwc} class="w-full" placeholder="Paste connection string here" />
            </div>
        </div>

        <button class="button button-primary w-full" on:click={() => nwcConnect(nwc)}>
            Connect
        </button>
    </div>
{:else if mode === "alby"}
    <WalletConnectAlby
        on:success={onSuccess}
        on:cancel={() => mode = undefined}
    />
{:else if mode === "nwa"}
    <WalletConnectNwa on:success={onSuccess} />
{/if}