<script lang="ts">
	import { finalizeLogin, trustedPubkeys } from "$utils/login";
	import { NDKPrivateKeySigner } from "@nostr-dev-kit/ndk";
    import { qrcode } from "@sveu/extend/qrcode";
	import { onMount } from "svelte";
    import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();

    let LottiePlayer: any;

    const key = NDKPrivateKeySigner.generate();
    const secret = key.privateKey!;
    console.log(secret, secret.length);
    const value = new URL(`nostr+walletauth://${trustedPubkeys[0]}`);
    value.protocol = "nostr+walletauth";
    value.searchParams.set("secret", secret);
    value.searchParams.set("required_commands", "pay_invoice make_invoice lookup_invoice");
    value.searchParams.set("relay", "wss://relay.damus.io");
    value.searchParams.set("budget", "1000000/month");
    value.searchParams.set("identity", trustedPubkeys[0]);

    $: ({ output, pending, error } = qrcode(value.toString()))

    let paired = false;

    onMount(async () => {
        const module = await import("@lottiefiles/svelte-lottie-player");
        LottiePlayer = module.LottiePlayer;

        fetch("/api/user/nwa", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ secret })
        }).then(() => {
            console.log("done");
            paired = true;
            finalizeLogin().then(() => {
                dispatch("success");
            })
        })
    })
</script>

<div class="grid place-items-center">
    {#if paired}
    <div class="max-w-lg mx-auto w-full">
        <LottiePlayer
            src="/images/done.json"
            autoplay={true}
            loop={false}
            controls={false}
            renderer="svg"
            background="transparent"
            speed={0.5}
        />
    </div>
    {:else if $pending}
        <p>Pending.........</p>
    {:else}
        <img src="{$output}" alt="qrcode" />

        <br />

        {#if $error}
            <p class="text-red-500">{$error}</p>
        {/if}

        <br />
    {/if}
</div>