<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { currencyFormat, currencySymbol } from "$utils/currency";
	import { termToShort } from "$utils/term";
import { NDKArticle, NDKEvent, profileFromEvent, type NDKUserProfile, type NDKIntervalFrequency } from "@nostr-dev-kit/ndk";
	import { ArrowDown } from "phosphor-svelte";

    export let event: NDKEvent;
    const amountTag = event.getMatchingTags("amount")[0];
    const [ _, amount, currency, _term ] = amountTag||[];
    const term = _term as NDKIntervalFrequency;

    const embeddedEvent = event.tagValue("event");
    let tierEvent: NDKArticle;

    if (embeddedEvent) {
        try {
            tierEvent = NDKArticle.from(new NDKEvent($ndk, JSON.parse(embeddedEvent)));
        } catch {}
    }

    if (!embeddedEvent) {
        const tierId = event.tagValue("a");
        if (tierId) {
            $ndk.fetchEvent(tierId).then(e => {
                if (e) tierEvent = NDKArticle.from(e);
            });
        }
    }

    const clientTag = event.getMatchingTags("client")[0];
    let clientNip89: NDKEvent;
    let clientProfile: NDKUserProfile;

    if (clientTag?.[2]) {
        $ndk.fetchEvent(clientTag[2]).then(e => {
            if (e) {
                clientNip89 = e;
                clientProfile = profileFromEvent(e);
            }
        });
    }
</script>

<UserProfile user={event.author} let:userProfile let:fetching>
<div class="flex-col justify-start items-start gap-4 inline-flex">
    <div class="self-stretch justify-start items-center inline-flex">
        <div class="grow shrink basis-0 justify-start items-center gap-4 flex">
            <div class="w-12 h-12 p-2 bg-neutral-700 rounded-full justify-center items-center flex">
                <ArrowDown class="text-green-500" />
            </div>
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-1 inline-flex">
                <div class="self-stretch justify-between items-center inline-flex">
                    <div class="text-foreground font-semibold leading-5">New Subscriber!</div>
                    {#if amountTag}
                        <div class="!text-green-500 font-semibold leading-5">
                            {currencyFormat(currency, parseInt(amount))}/{termToShort(term)}
                        </div>
                    {/if}
                </div>
                <div class="text-foreground text-opacity-60 font-normal leading-5 text-xs">
                    <RelativeTime {event} />
                </div>
            </div>
        </div>
    </div>

    <div class="flex flex-row gap-2 items-end p-6 bg-foreground/20 rounded w-full">
        <Avatar {userProfile} {fetching} size="small" />
        <div>
            <Name {userProfile} {fetching} class="text-foreground font-semibold" />

            {#if tierEvent}
                subscribed to
                <span class="text-foreground font-semibold">{tierEvent.title}</span>
            {/if}

            {#if clientTag}
                via
                <span class="text-foreground">
                    {#if clientProfile}
                        {clientProfile.name}
                        {#if clientProfile.image}
                            <Avatar userProfile={clientProfile} size="small" type="square" class="ml-2" />
                        {/if}
                    {:else}
                        {clientTag[1]}
                    {/if}
                </span>
            {/if}
        </div>
    </div>


    {#if event.content.length > 0}
        <div class="self-stretch text-foreground font-normal leading-5">
            {event.content}
        </div>
    {/if}
</div>
</UserProfile>