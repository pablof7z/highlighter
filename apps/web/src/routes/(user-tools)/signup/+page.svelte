<script lang="ts">
	import { layout } from "$stores/layout";
    import * as Session from "$components/Session";
	import { onMount } from "svelte";
	import { goto } from "$app/navigation";
	import currentUser from "$stores/currentUser";

    let title = "Welcome!"
    
    $: $layout.title = title;
    $layout.navigation = false;
    $layout.sidebar = false;
    $layout.fullWidth = false;
    $layout.footer = undefined;

    $: if ($currentUser) {
        goto("/");
    }

    let mode: 'signup' | 'login' | 'welcome';

    function next() {

    }

    onMount(() => {
        if (!!window.nostr) {
            mode ??= 'login';
        } else {
            mode = 'signup';
        }
    })
</script>

<div class="h-full w-full flex items-center justify-center">
    <div class="max-w-sm w-full lg:border rounded">
        {#if mode === 'signup'}
            <Session.Signup bind:mode bind:title on:signed-up={next} />
        {:else if mode === 'login'}
            <div class="w-full flex flex-col gap-5">
                <Session.Login bind:mode bind:title on:logged-in={next} />
            </div>
        {:else if mode === 'welcome'}
            <div class="w-full flex flex-col gap-5">
                <!-- <Session.Welcome /> -->
            </div>
        {/if}
    </div>
</div>