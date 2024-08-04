<script lang="ts">
	import { layout } from "$stores/layout";
    import * as Session from "$components/Session";
	import { onMount } from "svelte";

    let title = "Welcome!"
    
    $: $layout.title = title;
    $layout.navigation = false;

    let mode: 'signup' | 'login' | 'welcome';

    onMount(() => {
        if (!!window.nostr) {
            mode ??= 'login';
        } else {
            mode = 'signup';
        }
    })
</script>

{#if mode === 'signup'}
    <Session.Signup bind:mode bind:title />
{:else if mode === 'login'}
    <div class="w-full flex flex-col gap-5">
        <Session.Login bind:mode bind:title />
    </div>
{:else if mode === 'welcome'}
    <div class="w-full flex flex-col gap-5">
        <!-- <Session.Welcome /> -->
    </div>
{/if}