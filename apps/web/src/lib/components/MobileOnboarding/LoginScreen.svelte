<script lang="ts">
	import { goto } from "$app/navigation";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import currentUser from "$stores/currentUser";
	import { login } from "$utils/login";
    import { createEventDispatcher } from "svelte";

    const dispatcher = createEventDispatcher();

    let nsec: string;

    $: if ($currentUser) goto("/");
</script>

<div class="flex flex-col items-start justify-center w-4/5">
    <PageTitle title="Login" />
    
    <label class="mb-2">
        Enter your key to login
    </label>

    <Input type="password" bind:value={nsec} class="w-full text-center text-lg" autofocus placeholder="Nsec" />

    <div class="self-end w-full py-10 flex flex-col-reverse gap-4 responsive-padding">
        <Button variant="outline"  on:click={() => dispatcher('signup')} class="w-full col-span-2">
            Create account
        </Button>

        <Button size="lg" on:click={() => login(nsec)}>
            Login
        </Button>
    </div>
</div>