<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { appMobileView } from "$stores/app";
	import { inboxList } from "$stores/inbox";
	import { createBlossom } from "$utils/blossom";
	import { closeModal } from "$utils/modal";
	import { HighlightIcon, Avatar, Name } from "@kind0/ui-common";
	import { NDKUser } from "@nostr-dev-kit/ndk";
    export let user: NDKUser;

    function highlight() {
        $inboxList.addItem(user);
        $inboxList.publishReplaceable();
        highlighted = true;
    }

    function undo() {
        const index = $inboxList.tags.map(t => t[1]).indexOf(user.pubkey);
        if (index >= 0) {
            $inboxList.removeItem(index, false).then(list => {
                list.publishReplaceable();
            });
        }
        closeModal();
    }

    let highlighted = false;
    let receiveDms = true;

    const blossom = createBlossom({ user });
</script>

<ModalShell color="glassy" class="max-w-lg !p-0">
    <UserProfile {user} let:userProfile>
        {#if !highlighted}
            <div class="flex flex-col-reverse justify-stretch items-stretch">
                <div class="w-full flex flex-col gap-8 items-center text-lg text-center p-6">
                    <h1 class="text-center text-5xl">
                        Highlight your
                        <div class="text-accent2 whitespace-nowrap">
                            favorite creators
                        </div>
                        from the crowd
                    </h1>
                    <p>
                        Add the creators you care about the most to your inbox; receive their latest updates,
                        and tune-in into their highest quality content.
                    </p>

                    <div class="flex flex-col gap-2">
                        <button class="button-black text-lg text-white px-8 py-4" on:click={highlight}>
                            Highlight
                            <Name {user} />
                        </button>
                        <button class="text-xs" on:click={() => closeModal()}>Close</button>
                    </div>
                </div>

                <div class="w-full h-full relative flex flex-col gap-8 justify-center p-6 items-center text-lg">
                    {#if userProfile?.banner || userProfile?.name}
                        <img use:blossom src={ userProfile.banner || `https://picsum.photos/800/600?random=${userProfile.name}` } class="w-full h-full object-cover absolute opacity-50" />
                    {/if}

                    <Avatar user={user} class="w-24 h-24" />
                </div>
            </div>
        {:else}
            <div class="flex flex-col-reverse justify-stretch items-stretch">
                <div class="w-full flex flex-col gap-8 items-center text-lg text-center p-6">
                    <h1 class="text-center text-5xl">
                        Hooray!
                    </h1>
                    <h1 class="text-center text-3xl">
                        <Name {user} {userProfile} class="text-accent2" />'s
                        highlights are now
                        in your inbox
                    </h1>

                    <Checkbox bind:value={receiveDms} class="text-lg w-full items-start">
                        <span class="text-left">
                            Receive direct messages
                            with <Name {user} {userProfile} class="text-accent2" />'s
                            new content
                        </span>
                    </Checkbox>

                    <div class="flex flex-col gap-2">
                        <button class="button-black text-lg text-white px-8 py-4" on:click={() => closeModal()}>
                            Close
                        </button>
                        <button class="text-xs" on:click={undo}>Undo</button>
                    </div>
                </div>

                <div class="w-full h-full relative flex flex-col gap-8 justify-center p-6 items-center text-lg grow flex-grow">
                    <img src={userProfile?.banner} class="w-full h-full object-cover absolute opacity-50" />

                    <Avatar user={user} class="w-24 h-24" />
                </div>
            </div>
        {/if}
    </UserProfile>
</ModalShell>