<script lang="ts">
	import { page } from "$app/stores";
	import LoginScreen from "$components/MobileOnboarding/LoginScreen.svelte";
	import SignupScreen from "$components/MobileOnboarding/SignupScreen.svelte";
    
    let mode: string;
    
    $: mode = $page.url.searchParams.get("mode") ?? "signup";
</script>

<div class="flex flex-col h-full w-full fixed top-0 bottom-0 left-0 right-0 justify-center items-center">
    {#if mode === "signup"}
        <SignupScreen on:login={() => mode = "login"} />
    {:else}
        <LoginScreen on:signup={() => mode = "signup"} />
    {/if}
</div>