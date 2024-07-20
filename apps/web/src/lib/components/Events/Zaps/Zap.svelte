<script lang="ts">
	import ZapSent from './ZapSent.svelte';
    import type { Hexpubkey, NDKEvent, NDKFilter, NDKTag, NDKUser } from '@nostr-dev-kit/ndk';

    import { Heart, Fire, Rocket, Lightning, HeartStraight } from 'phosphor-svelte';
    import { nicelyFormattedSatNumber } from '$utils';
    import { createEventDispatcher } from 'svelte';
    import ZapUserSplit from './ZapUserSplit.svelte';
	import ZapAmountButton from './ZapAmountButton.svelte';
	import { Button } from '$components/ui/button';
	import Input from '$components/ui/input/input.svelte';
	import LnQrCode from '$components/Payment/LnQrCode.svelte';
    import { zap as realZap } from '$utils/zap';

    export let event: NDKEvent | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let forceZap: boolean = false;
    export let skipButton: boolean = false;

    const dispatch = createEventDispatcher();

    let zapSent = false;

    export let amount = 1000;
    let customAmount = '';
    let isValidCustomAmount = true;
    let isCustomAmountSelected = false;
    let comment = '';
    export let zapButtonEnabled = true;
    export let zapping = false;

    let showCustomAmountInput = false;
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

    $: if (forceZap) {
        forceZap = false;
        zap();
    }

    let prs: [string, number, NDKFilter ][] = [];

    type Split = [Hexpubkey, number, number]
    let zapSplits: Split[];
    
    if (event) {
        zapSplits = event.getMatchingTags("zap")
            .map((zapTag: NDKTag) => {
                return [zapTag[1], parseInt(zapTag[3]??"1"), 0]
            });
    } else if (user) {
        zapSplits = [
            [user.pubkey, 1, 0]
        ]
    }

    async function zap() {
        // zapping = true;
        // zapButtonEnabled = false;
        
        if(Number.isNaN(amount) && errorCustomAmount) {
            alert('Specify a number to zap') ;
            return;
        }

        await realZap(amount * 1000, event || user!, comment);

        return;

        // try {
        //     for (const zapSplit of zapSplits) {
        //         const satAmount = Math.round(amount * zapSplit[1] / totalSplitValue);

        //         if (satAmount === 0) continue;

        //         dispatch('zapping', { satAmount, zapSplit });

        //         $ndk
        //             .zap(event, satAmount * 1000, comment, [], $ndk.getUser({ pubkey: zapSplit[0] }))
        //             .then(async (pr: string | null) => {
        //                 console.log('pr', pr, $walletBalance);
        //                 if (pr) {
        //                     if ($defaultWalletBalance && $defaultWalletBalance >= satAmount) {
        //                         console.log("we can pay with wallet balance");

        //                         // try {
        //                             const ret = await payWithProofs(pr, satAmount, undefined, event);
        //                             // console.log('trying to pay with wallet balance', proofs);
        //                             // const ret = await wallet.payLnInvoice(pr, proofs);
        //                             console.log({ret});
        //                             if (ret.isPaid) {
        //                                 zapSent = true;
        //                                 dispatch('zap', { pr, satAmount, zapSplit });
        //                             }
        //                         // } catch (e) {
        //                         //     console.error(e);
        //                         //     toast.error(e.message);
        //                         // }
        //                     } else {
        //                         // prs.push([pr, satAmount, { "#p": [zapSplit[0]], "#e": [event.id], since: Math.floor(Date.now()/1000), kinds: [9735] }]);
        //                         // prs = prs;
        //                     }
        //                 }
        //             })
        //             .catch((e: Error) => {
        //                 console.error(e);
        //                 newToasterMessage(e.message, "error");
        //             })
        //             .finally(() => {
        //                 zapping = false;
        //             });
        //     }

        //     event.ndk = $ndk;
        // } catch (e) {
        //     console.error(e);
        //     newToasterMessage(e.message, "error");
        // } finally {
        //     zapButtonEnabled = true;
        // }
    }

    if (zapSplits.length === 0) {
        zapSplits.push([event.pubkey, 1, 0]);
    }

    let totalSplitValue: number;

    $: totalSplitValue = zapSplits.reduce((acc: number, split: Split) => {
        return acc + split[1];
    }, 0);
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
        <div class="flex flex-col gap-8 m-2">
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

            {#if prs.length > 0}
                <div class="flex flex-row gap-2 flex-nowrap overflow-x-auto no-scrollbar">
                    {#each prs as pr}
                        <LnQrCode pr={pr[0]} satAmount={pr[1]} zapWatcherFilter={pr[2]} />
                    {/each}
                </div>
            {:else}
                <div class="flex flex-col gap-3">
                    <div class="text-base-300-content text-sm font-semibold tracking-widest">AMOUNT</div>

                    <div class="flex max-lg:flex-col flex-row gap-4">
                        <div class="flex flex-row gap-3">
                            <ZapAmountButton title={"1K"} bind:group={amount} value={1000}>
                                <HeartStraight class="w-full h-full" />
                            </ZapAmountButton>
                            <ZapAmountButton title={"10K"} bind:group={amount} value={10000}>
                                <Heart class="w-full h-full" />
                            </ZapAmountButton>
                            <ZapAmountButton title={"50K"} bind:group={amount} value={50000}>
                                <Fire class="w-full h-full" />
                            </ZapAmountButton>
                            <ZapAmountButton title={"100K"} bind:group={amount} value={100000}>
                                <Rocket class="w-full h-full" />
                            </ZapAmountButton>
                            <ZapAmountButton title={"Custom"} bind:group={amount} value={(amount??1000)+1}>
                                <Lightning class="w-full h-full" />
                            </ZapAmountButton>
                        </div>
                    </div>

                    <div class="flex flex-col w-full justify-center items-center pt-4 gap-4">
                        {#if isCustomAmountSelected}
                            <div class="flex flex-col w-full justify-center items-center">
                                <Input
                                    placeholder="Zap custom amount..."
                                    bind:value={customAmount}
                                    on:change={() => {
                                        amount = parseInt(customAmount);
                                    }}
                                    on:keyup={() => {
                                        amount = parseInt(customAmount);
                                    }}
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
                        <Input
                            class="w-full text-lg"
                            placeholder="Add a comment..."
                            bind:value={comment}/>
                    </div>
                </div>

                {#if !skipButton}
                    <Button variant="accent" on:click={zap} class="{$$props.buttonClass??""}" disabled={!zapButtonEnabled}>
                        Zap
                        {nicelyFormattedSatNumber(amount)}
                        sats
                    </Button>
                {/if}
            {/if}
        </div>
    {/if}
</div>