<script lang="ts">
	import { NDKNutzap } from '@nostr-dev-kit/ndk';
	import { wallet, walletBalance, walletService } from "$stores/wallet";
    import { nicelyFormattedSatNumber } from "$utils";
    import { Lightning } from "phosphor-svelte";
	import { onMount } from "svelte";
	import { writable } from 'svelte/store';
	import { slide } from 'svelte/transition';
	import Avatar from '$components/User/Avatar.svelte';
	import currentUser from '$stores/currentUser';
	import { currencyFormat } from '$utils/currency';

    const newZaps = writable<NDKNutzap[]>([]);

    let loading = false;
    $: loading = !!($currentUser && $walletService.state === "loading" && !$wallet);
    $walletService.on("ready", () => {
        console.log('wallet ready');
        loading = false;
    });
    
    onMount(() => {
        $walletService.on("nutzap:seen", (nutzap: NDKNutzap) => {
            console.log('nutzap', nutzap.rawEvent());
            newZaps.update(nutzaps => [...nutzaps, nutzap]);
            setTimeout(() => {
                newZaps.update(nutzaps => {
                    nutzaps.shift();
                    return nutzaps
                });
            }, 2000);
        });
    })
</script>

<a
    href="/wallet"
    class="
        flex items-center justify-between flex-grow flex-col border border-secondary w-full rounded-full overflow-clip
        transition-all duration-300 ease-in-out
        bg-background/50
        { $newZaps.length > 0 ? "bg-gold/20" : "" }
    "
>
    {#if $newZaps.length > 0}
        <div
            class="flex items-center w-full flex-row gap-2  p-2" transition:slide
        >
            <span class="text-accent text-xl font-semibold">
                <Avatar user={$newZaps[0].author} size="small" />
            </span>
            <span class="text-foreground text-sm truncate grow">
                {$newZaps[0].comment??""}
            </span>
            <span>
                +{nicelyFormattedSatNumber($newZaps[0].amount)}
                {$newZaps[0].unit??"sat"}
            </span>
        </div>
    {:else}
        <div class="flex items-center w-full gap-2  p-2" transition:slide>
            <Lightning class="text-accent w-6 h-6" weight="fill" />
            <span class="text-foreground text-xl font-semibold grow">
                {#if $walletBalance?.[0]}
                    {currencyFormat(
                        $walletBalance[0].unit,
                        $walletBalance[0].amount
                    )}..
                {:else}
                    0 sats!
                {/if}
            </span>
        </div>
    {/if}
</a>