<script lang="ts">
	import ZapSent from './ZapSent.svelte';
    import type { Hexpubkey, NDKEvent, NDKTag } from '@nostr-dev-kit/ndk';
    import { requestProvider } from 'webln';

    import { Heart, Fire, Rocket, Lightning, HeartStraight } from 'phosphor-svelte';
    import { ndk } from '$stores/ndk.js';
    import { nicelyFormattedSatNumber } from '$utils';
    import { createEventDispatcher } from 'svelte';
    import ZapUserSplit from './ZapUserSplit.svelte';
	import ZapAmountButton from './ZapAmountButton.svelte';

    export let event: NDKEvent;

    const dispatch = createEventDispatcher();

    let _weblnPageReload = false

    let modalErrorMessage: string = ``

    let zapSent = false;

    let amount = 1000;
    let customAmount = '';
    let isValidCustomAmount = true;
    let isCustomAmountSelected = false;
    let comment = '';
    let zapButtonEnabled = true;
    let zapping = false;

    let showCustomAmountInput = false;
    //let valueCustomAmount = ``
    let errorCustomAmount = ``

    $: isCustomAmountSelected = ![1000, 10000, 50000, 100000].includes(amount)

    $: {
        if (amount) {
            zapButtonEnabled = true;
        } else {
            if ((!showCustomAmountInput && amount != 0) || (customAmount && isValidCustomAmount)){
                zapButtonEnabled = true;
            } else {
                zapButtonEnabled = false;
            }
        }
    }

    async function zap() {
        if(Number.isNaN(amount) && errorCustomAmount) {
            alert('Specify a number to zap') ;
            return;
        }

        try {
            const prs: string[] = await Promise.all(
            zapSplits.map((zapSplit) =>
                event.zap(
                    zapSplit[2] * 1000,
                    comment,
                    [],
                    $ndk.getUser({ hexpubkey: zapSplit[0] })  // if this is async, use await
                )));

            event.ndk = $ndk;
            zapping = true;

            for (const pr of prs) {
                if (!pr) {
                    console.log('no payment request');
                    continue
                }

                const webln = await requestProvider();
                await webln.sendPayment(pr);
                zapping = false;
                zapSent = true;
                // TODO we should check here if the payment was successful, with a timer
                // that is canceled here; if the timer doesn't come back, show the modal again
            }

            dispatch('zap', { event });
        } catch (e) {
            const error_msg = String(e).trim()

            let error_tmpl_0 = `TypeError: signer is`
            let error_tmpl_1 = `Error: Prompt was closed`
            let error_tmpl_2 = `Error: webln.enable() failed`

            if(error_msg.slice(0, error_tmpl_0.length) === error_tmpl_0) {
                modalErrorMessage = `A 'webln' signer is required to zap.`
            } else if(error_msg.slice(0, error_tmpl_1.length) === error_tmpl_1) {
                modalErrorMessage = `The 'webln' signer was closed.`
            } else if(error_msg.slice(0, error_tmpl_2.length) === error_tmpl_2) {
                modalErrorMessage = `Reloading the page.`

                _weblnPageReload = true
            }

            zapping = false;
        }
    }

    type Split = [Hexpubkey, number, number]
    const zapSplits: Split[] = event.getMatchingTags("zap")
        .map((zapTag: NDKTag) => {
            return [zapTag[1], parseInt(zapTag[3]??"1"), 0]
        });

    if (zapSplits.length === 0) {
        zapSplits.push([event.pubkey, 1, 0]);
    }

    let totalSplitValue: number;

    $: totalSplitValue = zapSplits.reduce((acc: number, split: Split) => {
        return acc + split[1];
    }, 0);


    $: {
        if(_weblnPageReload) {
            _weblnPageReload = false
            location.reload()
        }

    }
</script>

<div class="flex max-lg:flex-col flex-row flex-nowrap justify-center gap-4">
    {#if zapSent}
        <div class="flex flex-col items-center justify-center">
            <div>
                <ZapSent class="h-[267px]"/>
            </div>
            <!-- <button on:click={closeModal} class="w-fit">
                <span class="glow flex items-center gap-3 text-foreground text-base leading-normal font-normal">
                    <CheckSimple class="text-accent"/>
                    Zap Sent
                </span>
            </button> -->
        </div>
    {:else}
        <div class="flex flex-col gap-8">
            <div class="flex flex-col gap-4">
                <div
                    class="text-base-300-content text-sm font-semibold tracking-widest"
                    class:hidden={zapSplits.length === 1}
                >SPLITS</div>
                {#if zapSplits}
                    {#each zapSplits as zapSplit}
                        <ZapUserSplit
                            pubkey={zapSplit[0]}
                            bind:split={zapSplit[1]}
                            bind:satSplit={zapSplit[2]}
                            {totalSplitValue}
                            totalSatsAvailable={amount}
                            hideRange={zapSplits.length === 1}
                        />
                    {/each}
                {/if}
                <!-- TODO add other people involved in the highlight? -->
            </div>

            <div class="flex flex-col gap-3">
                <div class="text-base-300-content text-sm font-semibold tracking-widest">AMOUNT</div>

                <div class="flex max-lg:flex-col flex-row gap-4">
                    <div class="flex flex-row gap-3">
                        <ZapAmountButton title={"1K"} bind:group={amount} value={1000} onButtonClick={async () => { showCustomAmountInput = false } }>
                            <HeartStraight />
                        </ZapAmountButton>
                        <ZapAmountButton title={"10K"} bind:group={amount} value={10000} onButtonClick={async () => { showCustomAmountInput = false } }>
                            <Heart />
                        </ZapAmountButton>
                        <ZapAmountButton title={"50K"} bind:group={amount} value={50000} onButtonClick={async () => { showCustomAmountInput = false } }>
                            <Fire />
                        </ZapAmountButton>
                        <ZapAmountButton title={"100K"} bind:group={amount} value={100000} onButtonClick={async () => { showCustomAmountInput = false } }>
                            <Rocket />
                        </ZapAmountButton>
                        <ZapAmountButton title={"Custom"} buttonActive={showCustomAmountInput} onClick={async () => { amount = showCustomAmountInput ? 1000 : 0; showCustomAmountInput = !showCustomAmountInput }}>
                            <Lightning />
                        </ZapAmountButton>
                    </div>
                </div>

                <div class="flex flex-col w-full justify-center items-center pt-4 gap-4">
                    {#if showCustomAmountInput}
                        <div class="flex flex-col w-full justify-center items-center">
                            <input
                                placeholder="Zap custom amount..."
                                bind:value={customAmount}
                            />
                        </div>
                        {#if errorCustomAmount}
                            <div class="flex flex-row w-full justify-center items-center">
                                <p class="font-sans font-light text-sm">
                                    {`${errorCustomAmount}`}
                                </p>
                            </div>
                        {/if}
                    {/if}
                    <input
                        class="w-full"
                        maxlength="50"
                        placeholder="Add a comment..."
                        bind:value={comment}/>
                </div>
            </div>

            <button on:click={zap} class="{$$props.buttonClass??""} {!zapButtonEnabled ? 'btn-disabled' : ''}">
                Zap
                {nicelyFormattedSatNumber(amount)}
                sats
            </button>
        </div>
    {/if}
</div>