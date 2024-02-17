<script lang="ts">
    import { qrcode } from "@sveu/extend/qrcode";
	import { onMount } from "svelte";
    import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();

    let LottiePlayer: any;

    let paired = false;
    let uri: string;

    $: ({ output, pending, error } = qrcode(uri??""))

    onMount(async () => {
        const module = await import("@lottiefiles/svelte-lottie-player");
        LottiePlayer = module.LottiePlayer;

        const res = await fetch("/api/user/nwa", {
            method: "GET",
            headers: {
                "Content-Type": "application/json"
            },
        })

        const data = await res.json();
        console.log(data);
        uri = data.url;
    })
</script>

{#if uri}
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
    {:else if uri}
        <img src="{$output}" alt="qrcode" />

        <br />

        {#if $error}
            <p class="text-red-500">{$error}</p>
        {/if}

        <br />
    {/if}
</div>
{/if}