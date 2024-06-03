<script lang="ts">
	import SubscriptionZapReceived from "$components/Creator/ActivityItems/SubscriptionZapReceived.svelte";
    import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import UserProfile from "$components/User/UserProfile.svelte";
    import SubscriptionReceipt from "$components/Subscriptions/SubscriptionReceipt.svelte";
	import { ndk } from "$stores/ndk.js";
    import { NDKSubscriptionReceipt, type NDKSubscriptionStart } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { currencyFormat } from "$utils/currency";
	import { termToShort } from "$utils/term";
	import Box from "$components/PageElements/Box.svelte";
	import { CaretRight } from "phosphor-svelte";

    export let subsciptionStart: NDKSubscriptionStart;

    const recipient = subsciptionStart.recipient;
    const amount = subsciptionStart.amount;
    let authorUrl: string = `/${recipient?.npub}`;

    const actions = $ndk.storeSubscribe(
        subsciptionStart.filter(),
        { groupable: true }
    )

    onDestroy(() => actions.unsubscribe());
</script>

<UserProfile user={recipient} let:userProfile let:fetching>
    <Box innerClass="w-full">
        <div class="flex flex-row justify-between w-full">
            {#if userProfile}
                <AvatarWithName bind:authorUrl {userProfile} {fetching} avatarType="square" avatarSize="large" nameClass="text-white text-lg">
                    <a href={authorUrl} class="button button-primary text-xs">
                        Go Backstage
                        <CaretRight class="inline" />
                    </a>
                </AvatarWithName>
            {/if}
            <div class="text-lg font-medium text-white">
                {currencyFormat(amount?.currency, amount?.amount)}/{termToShort(amount?.term)}
            </div>
        </div>

        {#each $actions as action}
            {#if action.kind === 9735}
                <SubscriptionZapReceived event={action} />
            {:else if action.kind === 7003}
                <SubscriptionReceipt receipt={NDKSubscriptionReceipt.from(action)} />
            {:else}
                <div>
                    {JSON.stringify({kind: action.kind, content: action.content})}
                </div>
            {/if}

        {/each}

    </Box>
</UserProfile>