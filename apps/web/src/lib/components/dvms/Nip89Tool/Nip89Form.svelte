<script lang="ts">
	import Nip89AddParamModal from './../../../modals/Nip89AddParamModal.svelte';
    import { kindToText, jobRequestKinds } from "$utils";
	import { Info } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import { openModal } from "svelte-modals";
	import type { Nip90Param } from '$utils/nip90';

    const dispatch = createEventDispatcher();

    export let name = '';
    export let pubkey = '';
    export let image = '';
    export let supportedKind: number;
    export let about = '';
    export let nip90Params: Record<string, Nip90Param> = {};

    function submit() {
        dispatch("done");
    }

    function cancel() {
        dispatch('cancel')
    }

    let validForm = false;

    $: validForm = (
        name.length === 0 ||
        pubkey.length === 0 ||
        image.length === 0 ||
        !supportedKind
    );

    function addParam() {
        openModal(Nip89AddParamModal, {
            name: '',
            onSave: (name: string, p: Nip90Param) => {
                nip90Params[name] = p;
            }
        });
    }

    function openNip90Param(name: string) {
        openModal(Nip89AddParamModal, {
            name,
            values: nip90Params[name].values?.join(", "),
            required: nip90Params[name].required,
            onSave: (name: string, p: Nip90Param) => {
                nip90Params[name] = p;
            },
            onRemove: (name: string) => {
                delete nip90Params[name];
                nip90Params = nip90Params;
            }
        });
    }
</script>

<div class="card-title flex flex-col gap-4">
    <h3 class="text-2xl text-base-100-content">NIP-89 DVM announcement</h3>
    <h4 class="font-normal text-base">
        NIP-89 allows you to advertise your DVM and its functionalities.
    </h4>
</div>

<form class="flex flex-col gap-4">
    <div class="flex flex-col md:flex-row gap-4">
        <div class="flex flex-col items-start md:w-1/3">
            <label for="name" class="block">Name</label>
            <input id="name" bind:value={name} type="text" class="input input-bordered w-full" required>
        </div>

        <div class="flex flex-col items-start md:w-1/3">
            <label for="pubkey" class="block">DVM Pubkey (in hex)</label>
            <input id="pubkey" bind:value={pubkey} type="text" class="input input-bordered w-full" required>
        </div>

        <div class="flex flex-col items-start md:w-1/3">
            <label for="image" class="block">Profile Picture (URL)</label>
            <input id="image" bind:value={image} type="url" class="input input-bordered w-full" required>
        </div>
    </div>

    <div class="flex flex-col items-start">
        <label for="supportedKind" class="block">Supported Features</label>
        <select
            bind:value={supportedKind} class="select select-bordered w-full">
            {#each jobRequestKinds as kind}
                <option value={kind}>{kind}: {kindToText(kind)}</option>
            {/each}
        </select>
        <p class="mt-2 text-sm text-info flex flex-row gap-2 items-center">
            <Info class="w-8 h-8 inline-block mr-1" />
            You can have multiple NIP-89 announcements if your DVM provides different functionalities; that way each announcement can describe the functionality specifically.
        </p>
    </div>

    <div class="">
        <label for="about" class="block mb-2">About</label>
        <textarea id="about" bind:value={about} rows="5" class="textarea textarea-bordered w-full" placeholder="Describe your DVM's capabilities. This is your chance to pitch your DVM to potential users. Make it count!" required></textarea>
    </div>

    <details class="collapse collapse-arrow border border-base-300 bg-base-200 join-item">
        <summary class="collapse-title">
            <div class="flex flex-row gap-2 items-end">
                <h3>
                    Advanced
                </h3>
            </div>
        </summary>

        <div class="collapse-content">
            <section>
                <div class="flex flex-row gap-2 justify-between mb-2 items-center">
                    <div class="flex flex-col gap-2">
                        <h3>
                            Params
                        </h3>
                        <span class="font-thin text-base opacity-80">
                            If your DVM supports some extra parameters or some
                            specific parameter options (e.g. <em>models</em> being
                            <em>chatgpt3.5</em> and <em>chatgpt4</em>) you
                            can specify them here so users can choose from them.
                        </span>
                    </div>

                    <button class="btn btn-primary" on:click={addParam}>
                        Add Param
                    </button>
                </div>

                <ul class="menu">
                    {#each Object.entries(nip90Params) as [name, param]}
                        <li>
                            <button class="flex flex-row gap-2 items-center py-3" on:click={() => openNip90Param(name)}>
                                <span class="text-accent2 font-bold mr-4">{name}</span>
                                <span class="text-xs opacity-80 badge badge-info">
                                    {param.required ? "required" : "optional"}
                                </span>
                                {#if param.values}
                                    {#each param.values as value}
                                        <span class="text-xs opacity-80 badge badge-neutral">{value}</span>
                                    {/each}
                                {/if}
                            </button>
                        </li>
                    {/each}
                </ul>

            </section>
        </div>
    </details>

    <div class="flex flex-row items-center">
        <button class="btn btn-primary btn-wide" on:click={submit} disabled={validForm}>Generate Event</button>
        <div class="alert items-center">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-info shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <span class="text-xs">
                You'll be able to sign with your DVMs key. No event will be published now.
            </span>
        </div>
        <button class="btn btn-ghost" on:click={cancel}>Cancel</button>
    </div>
</form>
