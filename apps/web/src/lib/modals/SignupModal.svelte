<script lang="ts">
	import { NavigationOption } from './../../app.d.ts';
	import ModalShell from '$components/ModalShell.svelte';
	import { closeModal } from '$utils/modal.js';
	import Button from '$components/ui/button/button.svelte';
	import { onMount } from 'svelte';

    export let mode: 'signup' | 'login' | 'welcome';

    function signedUp() {
        closeModal();
        // mode = 'welcome';
    }

    let title: string;

    onMount(() => {
        if (!!window.nostr) {
            mode ??= 'login';
        } else {
            mode = 'signup';
        }
    })
    

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
    class="w-full sm:max-w-lg !p-2"
    {title}
>
    <div class="flex flex-col gap-4 w-full">
        {#if mode === 'signup'}
            <div class="w-full flex flex-col gap-5">
                <Signup on:signed-up={signedUp} bind:actionButtons bind:mode bind:title />
            </div>
        {:else if mode === 'login'}
            <div class="w-full flex flex-col gap-5">
                <Login bind:actionButtons bind:mode />
            </div>
        {:else if mode === 'welcome'}
            <div class="w-full flex flex-col gap-5">
                <Welcome />
            </div>
        {/if}
    </div>

    <svelte:fragment slot="footerExtra">
        {#if mode !== "welcome"}
            <Button size="sm">
                Continue as Guest
            </Button>
        {/if}
    </svelte:fragment>
</ModalShell>