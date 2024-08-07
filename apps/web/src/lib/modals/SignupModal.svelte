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
    
</ModalShell>