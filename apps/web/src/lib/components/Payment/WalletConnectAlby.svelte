<script lang="ts">
	import { onMount } from "svelte";
    import { webln } from "@getalby/sdk";
    import { createEventDispatcher } from "svelte";
	import { newToasterMessage } from "$stores/toaster.js";
	import { CheckCircle } from "phosphor-svelte";

    const dispatch = createEventDispatcher();

    let nwc = webln.NostrWebLNProvider.withNewSecret();

    let connecting = true;
    let success = false;
    let url: string;

    onMount(() => {
        openAlby();
    });

    async function openAlby() {
        try {
            const a = await nwc.initNWC({
                name: "Highlighter"
            });
            url = await nwc.getNostrWalletConnectUrl(true);
            connecting = false;

            if (url) {
                success = true;

                dispatch("success", {
                    url,
                    nwc
                });
            } else {
                setTimeout(() => {
                    dispatch("cancel");
                }, 1500);
            }
        } catch (e: any) {
            if (e?.message) {
                newToasterMessage(e.message, 'error');
            }
            dispatch("cancel");
        }
    }
</script>

{#if connecting}
    <div class="flex flex-col items-center justify-center text-black gap-6">
        <div class="text-2xl font-semibold">Connecting to Alby...</div>
        <div class="text-lg">
            <div class="loading loading-lg"></div>
        </div>
        <div class="text-lg">Alby should have popped up to request authorization</div>
        <button class="button" on:click={() => dispatch('cancel')}>Cancel</button>
    </div>
{:else if success}
    <div class="flex flex-col items-center justify-center text-black gap-6">
        <div class="flex flex-row text-success gap-6 items-center">
            <CheckCircle class="w-12 h-12" />
            <div class="text-2xl font-semibold">Connected!</div>
        </div>
    </div>
{:else}
    <div class="flex flex-col items-center justify-center text-black gap-6">
        <div class="text-2xl font-semibold">Failed to connect to Alby</div>
        <button class="button" on:click={() => dispatch('cancel')}>Cancel</button>
    </div>
{/if}
