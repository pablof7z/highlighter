<script lang="ts">
	import WalletConnectAlby from './WalletConnectAlby.svelte';
    import Input from "$components/Forms/Input.svelte";
	import { ArrowDown, ArrowLeft } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import { finalizeLogin } from '$utils/login';
    import { createEventDispatcher } from 'svelte';
	import WalletConnectNwa from './WalletConnectNWA.svelte';
	import NwcIcon from '$icons/NwcIcon.svelte';
	import { Textarea, ZapIcon } from '@kind0/ui-common';

    type Mode = "alby" | "mutiny" | "nwc" | "nwa" | "zap";

    export let mode: Mode | undefined;
    export let nwcUrl: string;

    const dispatch = createEventDispatcher();

    let nwc: string;

    async function nwcConnect(url: string) {
        debugger
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

<div class="flex flex-col gap-[1px] rounded-box w-full">
    {#if mode}
        <button class="bg-black/30 hover:bg-white/5 transition-all duration-300 px-6 py-4 rounded-t-box flex flex-row gap-4 items-center" on:click={() => mode = undefined} transition:slide>
            <div class="w-12 h-12 flex flex-col items-center bg-black justify-center mask mask-squircle flex-none">
                <ArrowLeft class="w-8 h-8 text-neutral-500" />
            </div>

                <div class="font-normal text-lg text-white">
                    Back
                </div>
        </button>
    {/if}
    {#if !mode || mode === 'alby'}
    <button class="bg-black/30 hover:bg-white/5 transition-all duration-300 px-6 py-4 rounded-t-box flex flex-row gap-4 items-stretch" on:click={() => mode = "alby"} transition:slide>
        <img src="https://raw.githubusercontent.com/getAlby/media/4647cca3705445f81d204fc6cd19287f085dc644/Alby-logo-icons/Alby%20logo.jpg" class="w-12 h-12 mask mask-squircle bg-zinc-700" />
        <div class="flex flex-col items-start w-full">
            <div class="font-normal text-lg text-white">
                Alby Wallet
            </div>

            <div class="font-normal text-sm text-neutral-500">
                Connect with your Alby wallet
            </div>
        </div>
    </button>
    {/if}

    {#if !mode || mode === 'mutiny'}
    <button class="bg-black/30 hover:bg-white/5 transition-all duration-300 px-6 py-4 flex flex-row gap-4 items-stretch" on:click={() => mode = "mutiny"} transition:slide>
        <div class="w-12 h-12 flex flex-col items-center justify-center bg-black rounded-box flex-none">
            <img src="https://void.cat/d/CZPXhnwjqRhULSjPJ3sXTE.webp" class="w-12 h-12 mask mask-squircle bg-zinc-700" />
        </div>
        <div class="flex flex-col items-start w-full">
            <div class="font-normal text-lg text-white">
                Mutiny
            </div>

            <div class="font-normal text-sm text-neutral-500">
                Connect with your Mutiny Wallet
            </div>
        </div>
    </button>
    {/if}

    {#if !mode || mode === 'nwc'}
    <button class="bg-black/30 hover:bg-white/5 transition-all duration-300 px-6 py-4 flex flex-row gap-4 items-stretch" on:click={() => mode = "nwc"} transition:slide>
        <div class="w-12 h-12 flex flex-col items-center justify-center bg-black rounded-box flex-none">
            <NwcIcon class="w-12 h-12 mask mask-squircle" />
        </div>
        <div class="flex flex-col items-start w-full">
            <div class="font-normal text-lg text-white">
                Nostr Wallet Connect
            </div>

            <div class="font-normal text-sm text-neutral-500">
                Manually connect with any Nostr Wallet Connect
            </div>
        </div>
    </button>
    {/if}

    {#if !mode || mode === 'nwa'}
    <button class="bg-black/30 hover:bg-white/5 transition-all duration-300 px-6 py-4 flex flex-row gap-4 items-stretch rounded-b-box" on:click={() => mode = "nwa"} transition:slide>
        <div class="w-12 h-12 flex flex-col items-center justify-center bg-black rounded-box flex-none">
            <ZapIcon class="w-8 h-8 mask mask-squircle text-accent2" />
        </div>
        <div class="flex flex-col items-start w-full">
            <div class="font-normal text-lg text-white">
                Nostr Wallet Auth
            </div>

            <div class="font-normal text-sm text-neutral-500">
                Scan a QR code to connect quickly connect
            </div>
        </div>
    </button>
    {/if}
</div>


{#if mode === "nwc"}
    <div class="flex-col w-full justify-start items-center gap-3 inline-flex flex-nowrap" transition:slide>
        <div class="self-stretch flex-col justify-start items-start gap-4 flex">
            <div class="text-white text-base font-medium leading-normal">Nostr Wallet Connect</div>
            <Textarea
                class="w-full min-h-[8rem] textarea-bordered"
                placeholder="Wallet connect URL / pairing secret (nostr+walletconnect://...)"
                bind:value={nwc}
            />
            <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                <button class="button w-full" on:click={() => nwcConnect(nwc)}>
                    Connect
                </button>
            </div>
        </div>
    </div>
{:else if mode === "mutiny"}
    <div class="flex-col w-full justify-start items-center gap-3 inline-flex flex-nowrap" transition:slide>
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

        <button class="button w-full" on:click={() => nwcConnect(nwc)}>
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