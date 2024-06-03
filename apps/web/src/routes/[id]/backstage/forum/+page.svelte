<script lang="ts">
	import { page } from "$app/stores";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import StylishContainer from "$components/PageElements/StylishContainer.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import NewGroupPostModal from "$modals/NewGroupPostModal.svelte";
import { ndk } from "$stores/ndk.js";
	import { NDKFilter, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { Bell } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { openModal } from '$utils/modal';
	import EventWrapper from "$components/Feed/EventWrapper.svelte";

    let { user } = $page.data;

    const filters: NDKFilter[] = [
        { kinds: [ NDKKind.GroupNote ], "#h": [ user.pubkey ] }
    ]

    const events = $ndk.storeSubscribe(filters, { groupable: false, subId: 'feed'});

    onDestroy(() => events.unsubscribe());

    let authorUrl: string;

    function newPost() {
        openModal(NewGroupPostModal, {
            groupId: user.pubkey,
            creator: user,
        })
    }

    async function enableNotifications() {
        const permission = await Notification.requestPermission();

        if (permission === 'granted') {
            console.log('Notifications enabled');
        } else {
            console.log('Notifications denied');
        }
    }

    function color(i: number) {
        const colors = [ "#496989", "#58A399", "#A8CD9F", "#E2F4C5" ]

        return colors[i % colors.length];
    }
</script>

<UserProfile {user} bind:authorUrl />

<div class="flex flex-col lg:flex-row gap-6 max-7-xl">
    <div class="flex flex-col gap-6 lg:w-1/4 h-fit">
        <!-- <div class="h-fit">
            <StylishContainer class="p-6">
                <div class="text-lg text-base-100-content font-medium">
                    Stay up-to-date
                </div>

                <button on:click={enableNotifications} class="button px-4">
                    <Bell class="w-5 h-5 mr-2" />
                    Enable notifications
                </button>
            </StylishContainer>
        </div> -->
        
        <div class="backstage-box-container h-fit">
            <div class="text-lg text-base-100-content font-medium">
                Backstage forum
            </div>
    
            <p>
                This is a private forum to share thoughts, ideas and updates in a calm place. Only supporters of this creator can see and interact here.
            </p>
    
            <button class="button w-fit px-4" on:click={newPost}>
                New post
            </button>
        </div>
    </div>
    
    <ul class="max-w-3xl mx-auto w-full border-x border-base-300 gap-2 flex flex-col">
        {#each $events as event, i}
            <li style="border: solid {color(i)} 4px; background: {color(i)}44;">
                <EventWrapper
                    {event}
                    compact={true}
                    expandThread={false}
                    expandReplies={false}
                    showReply={false}
                    class="text-lg"
                    urlPrefix="{authorUrl}/backstage/forum/"
                />
            </li>
        {/each}
    </ul>
</div>