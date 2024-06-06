<script lang="ts">
	import { NavigationOption } from './../../app.d.ts';
    import Signup from './Signup.svelte';
	import Login from "./Login.svelte";
	import Welcome from "./Welcome.svelte";
	import ModalShell from '$components/ModalShell.svelte';
	import LogoGradient from '$icons/LogoGradient.svelte';
	import { Block } from 'konsta/svelte';
	import { DoorOpen, User } from 'phosphor-svelte';
	import { closeModal } from '$utils/modal.js';

    export let mode: 'signup' | 'login' | 'welcome' = 'signup';

    function signedUp() {
        closeModal();
        // mode = 'welcome';
    }

    let title: string;

    $: switch (mode) {
        case 'signup':
            title = 'Sign Up';
            break;
        case 'login':
            title = 'Log In';
            break;
        case 'welcome':
            title = 'Welcome!';
            break;
    }
    

    let actionButtons: NavigationOption[] = [];

    // $: switch (mode) {
    //     case 'signup':
    //         title = 'Sign Up';
    //         actionButtons = [
    //             {
    //                 name: "Already have an account?", fn: () => mode = 'login',
    //             },
    //             { 
    //                 name: "Sign Up",
    //                 icon: DoorOpen,
    //                 class: "button !button !button-primary",
    //                 fn: () => mode = 'signup'
    //             }
    //         ]
    //         break;
    //     case 'login':
    //         title = 'Log In';
    //         break;
    //     case 'welcome':
    //         title = 'Welcome!';
    //         break;
    // }
</script>

<ModalShell
    class="w-full sm:max-w-md"
    {title}

    {actionButtons}
>
    <div class="flex flex-col gap-4 w-full">
        {#if mode === 'signup'}
            <div class="w-full flex flex-col gap-5">
                <Signup on:signed-up={signedUp} />
            </div>
        {:else if mode === 'login'}
            <div class="w-full flex flex-col gap-5">
                <Login />
            </div>
        {:else if mode === 'welcome'}
            <div class="w-full flex flex-col gap-5">
                <Welcome />
        </div>
        {/if}
    </div>

    <div class:hidden={mode === 'welcome'}>
        {#if mode === 'signup'}
            <p class="text-center text-neutral-500 text-base my-2">
                Already have a Nostr account?
                <button on:click={() => mode = 'login'} class="text-foreground font-semibold underline">Log in</button>
            </p>
        {:else}
            <p class="text-center text-neutral-500 text-base my-2">
                Don’t have an account?
                <button on:click={() => mode = 'signup'} class="text-foreground/50 font-semibold underline">Sign Up</button>
            </p>
        {/if}
    </div>
</ModalShell>