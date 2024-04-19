<script lang="ts">
    import Signup from './Signup.svelte';
	import Login from "./Login.svelte";
	import Welcome from "./Welcome.svelte";
	import ModalShell from '$components/ModalShell.svelte';
	import LogoGradient from '$icons/LogoGradient.svelte';

    export let mode: 'signup' | 'login' | 'welcome' = 'signup';

    function signedUp() {
        mode = 'welcome';
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
</script>

<ModalShell
    color="glassy"
    class="w-full py-4 sm:p-6 sm:max-w-md"
>
    <div class="flex flex-col gap-4 w-full">
        <div class="flex flex-row items-center justify-between">
            <div class="justify-between items-center inline-flex">
                <div class="text-neutral-200 text-[32px] font-semibold leading-[40.96px]">
                    {title}
                </div>
            </div>

            <LogoGradient />
        </div>

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
                <button on:click={() => mode = 'login'} class="text-white font-semibold underline">Log in</button>
            </p>
        {:else}
            <p class="text-center text-neutral-500 text-base my-2">
                Don’t have an account?
                <button on:click={() => mode = 'signup'} class="text-white/50 font-semibold underline">Sign Up</button>
            </p>
        {/if}
    </div>
</ModalShell>