<script lang="ts">
    import ndk from '$stores/ndk';
	import { NDKAppHandlerEvent, NDKEvent, type NDKUser, type NDKUserProfile } from '@nostr-dev-kit/ndk';
	import { Avatar, EventCardDropdownMenu, EventContent, Name } from '@nostr-dev-kit/ndk-svelte-components';
	import { Star } from 'phosphor-svelte';

    export let pubkey: string | undefined = undefined;
    export let kind: number | undefined = undefined;
    export let nip89event: NDKAppHandlerEvent | null | undefined = undefined;
    export let profile: NDKUserProfile | undefined = undefined;
    export let user: NDKUser | undefined = undefined;

    /**
     * Event that should be referrenced in the card (if different than the app handler event)
    */
    export let event: NDKEvent | undefined = undefined;

    if (!user) user = $ndk.getUser({hexpubkey: pubkey});

    const promise = new Promise((resolve) => {
        if (nip89event) return nip89event.fetchProfile().then(resolve);

        $ndk.fetchEvent({
            kinds: [31990 as number],
            "#k": [kind.toString()],
            authors: [pubkey]
        }).then((e) => {
            if (!e) {
                user?.fetchProfile().then(() => { resolve(user.profile); })
                return;
            }
            if (!e) return resolve(undefined);

            nip89event = NDKAppHandlerEvent.from(e);

            nip89event.fetchProfile().then(resolve);
        });
    });
</script>

{#await promise}
{:then profile}
    <div class="w-full card card-compact">
        <div class="card-body flex flex-row gap-4 whitespace-normal">
            <Avatar ndk={$ndk} userProfile={profile} {user} class="w-24 h-24 object-cover rounded-lg" />
            <div class="flex flex-row gap-4">
                <div class="flex flex-col gap-2 whitespace-normal w-full">
                    <div class="flex flex-row gap-2 items-center w-full justify-between">
                        <Name ndk={$ndk} userProfile={profile} {user} class="text-xl text-base-100-content truncate" />

                        <button
                            class="btn btn-accent btn-outline !rounded-full btn-sm font-normal self-end"
                        >
                            <Star class="w-4 h-4" />
                            Favorite
                        </button>
                    </div>
                    <span class="text-base whitespace-normal">{profile?.about||profile?.bio||""}</span>
                </div>
            </div>
        </div>
    </div>
{:catch e}
        {e}
{/await}