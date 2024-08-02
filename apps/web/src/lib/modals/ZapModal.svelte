<script lang="ts">
	import { nicelyFormattedSatNumber } from '$utils';
	import Zap from "$components/Events/Zaps/Zap.svelte";
	import ModalShell from "$components/ModalShell.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../app";
	import { Lightning } from 'phosphor-svelte';

    export let event: NDKEvent;

    let zapAmount: number = 1000;
    let forceZap = false;
    let zapping = false;

    let actionButtons: NavigationOption[] = [];
    let zapButtonEnabled = true;

    $: actionButtons = [
        {
            name: (
                zapping ? "Zapping..." :
                zapAmount ? `Zap ${nicelyFormattedSatNumber(zapAmount)} sats` : `Zap`
            ),
            icon: Lightning,
            iconProps: { weight: "fill" },
            buttonProps: {
                variant: 'default',
                class: '!w-full',
                disabled: !zapButtonEnabled,
            },
            fn: () => {forceZap = true; }
        }
    ];
</script>

<ModalShell
    title="Zap"
    {actionButtons}
>
    <Zap
        target={event}
        bind:zapButtonEnabled
        bind:amount={zapAmount}
        bind:zapping
        bind:forceZap
        skipButton
        buttonClass="button"
    />
    <!-- <div slot="footerExtra" class="shrink basis-0 hidden"></div> -->
</ModalShell>