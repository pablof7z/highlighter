<script lang="ts">
	import { NDKWebLNWallet } from '@nostr-dev-kit/ndk-wallet';
	import RadioButton from "$components/Forms/RadioButton.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { onMount } from "svelte";
	import { NavigationOption } from "../../../app";

    export let value: string = "create";

    let weblnAvailable = false;

    onMount(() => {
        weblnAvailable = !!window.webln;
    })

    async function webln() {
        const wallet = new NDKWebLNWallet();
        try {
            const balance = await wallet.balance();
        } catch (e) {
            console.error(e);
        }
    }

    function cont() {
        switch (value) {
            case 'webln': webln();
        }
    }

    const actionButtons: NavigationOption[] = [
        { name: "Continue", fn: cont }
    ]
</script>

<ModalShell
    title="Connect Wallet"
    {actionButtons}
>
    <div class="flex flex-col gap-4">
        <RadioButton bind:currentValue={value} value="create">
            Use native wallet

            <div slot="description">
                Highlighter provides an embedded wallet that you can use
                from any NIP-60 compatible application.
            </div>
        </RadioButton>

        <RadioButton bind:currentValue={value} value="webln" class="{
            weblnAvailable ? "" : "pointer-events-none opacity-50"
        }">
            Use WebLN

            <div slot="description">
                {#if weblnAvailable}
                    Use Lightning Network via your WebLN Extension.
                {:else}
                    WebLN not detected in this browser.
                {/if}
            </div>
        </RadioButton>

        <!-- <RadioButton bind:currentValue={value} value="nwc">
            Nostr Wallet Connect

            <div slot="description">
                {#if weblnAvailable}
                    Use Lightning Network via your WebLN Extension.
                {:else}
                    WebLN not detected in this browser.
                {/if}
            </div>
        </RadioButton> -->
    </div>
</ModalShell>