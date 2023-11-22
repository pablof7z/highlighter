<script lang="ts">
    import LogoBlack from '$icons/LogoBlack.svelte';
	import { closeModal } from "svelte-modals";
    import { createEventDispatcher } from "svelte";
	import { fade } from "svelte/transition";
    import Signup from './Signup.svelte';
	import Login from "./Login.svelte";

    const dispatch = createEventDispatcher();

    async function onClose() {
        closeModal()
        dispatch("close");
    }

    export let mode: 'signup' | 'login' = 'signup';

    let iframeUrl: string | undefined;
</script>

<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex justify-center items-center
    z-50
    w-screen
" transition:fade on:click={onClose}>
    <div class="
    card
    rounded-3xl
    w-96
    shadow-xl
    flex flex-col
    relative
    overflow-y-hidden
    {$$props.class}
    " style="pointer-events: auto; max-height: 92vh;" on:click|stopPropagation={()=>{}} transition:fade>
        <div class="bg-white p-8 rounded-2xl shadow-lg w-96">
            {#if !iframeUrl}
                <div class="flex justify-center">
                    <LogoBlack />
                </div>

                {#if mode === 'signup'}
                    <Signup bind:iframeUrl />
                    <p class="text-center text-sm my-2">Already have a Nostr account? <button on:click={() => mode = 'login'} class="text-black font-bold underline">Log in</button></p>
                    {:else}
                    <Login />
                    <p class="text-center text-sm my-2">Don’t have an account? <button on:click={() => mode = 'signup'} class="text-black font-bold underline">Sign Up</button></p>
                {/if}
            {:else}
                <iframe src={iframeUrl} class="w-full h-96"></iframe>
            {/if}
        </div>
    </div>
</div>