<script lang="ts">
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { ndk } from "$stores/ndk";
	import { nicelyFormattedMilliSatNumber } from "$utils";
    import { zapInvoiceFromEvent, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { Avatar, EventContent, Name } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;

    const zap = zapInvoiceFromEvent(event);
    const sender = $ndk.getUser({pubkey: zap?.zappee});

    const subscriptionEventId = zap?.zappedEvent;
    let subscriptionEvent: NDKEvent;

    if (subscriptionEventId) {
        $ndk.fetchEvent(subscriptionEventId).then(e => {
            if (e) subscriptionEvent = e;
        });
    }
</script>

{#if subscriptionEvent}
    <UserProfile user={subscriptionEvent.author} let:userProfile let:fetching>
    <div class="flex-col justify-start items-start gap-4 inline-flex">
        <div class="self-stretch justify-start items-center inline-flex">
            <div class="grow shrink basis-0 justify-start items-center gap-4 flex">
                <Avatar {userProfile} {fetching} size="medium" />
                <div class="grow shrink basis-0 flex-col justify-center items-start gap-1 inline-flex">
                    <div class="self-stretch justify-between items-center inline-flex">
                        <div class="text-foreground font-semibold leading-5">
                            <Name {userProfile} {fetching} />
                        </div>
                    </div>
                    <div class="text-foreground text-opacity-60 font-normal leading-5 text-xs">
                        <RelativeTime {event} />
                    </div>
                </div>

                <div class="!text-green-500 font-semibold leading-5">
                    + {nicelyFormattedMilliSatNumber(zap?.amount ?? 0)} sats
                </div>
            </div>
        </div>

        <!-- <ArticleCard {article} skipSummary={true} imageClass="w-1/12" /> -->
        {#if event.content.length > 0}
            <EventContent ndk={$ndk} {event} showEntire={true} maxLength={9999} class="text-lg text-foreground !font-light" />
        {/if}
    </div>
    </UserProfile>
{/if}