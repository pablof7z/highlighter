<script lang="ts">
	import ImageUploader from '$components/Forms/ImageUploader.svelte';
	import { page } from "$app/stores";
	import CreatorFeed from "$components/Feed/CreatorFeed.svelte";
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import { userTiers, getUserSupporters, userSubscription, userContent, startUserView, userGAContent, getUserSupportPlansStore } from "$stores/user-view";
	import { Avatar, Name, ndk, user as currentUser } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEventId, NDKEvent, type NostrEvent, serializeProfile } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import EditableAvatar from "$components/User/EditableAvatar.svelte";
    import Image from "phosphor-svelte/lib/Image";
	import { Pen } from "phosphor-svelte";
	import CategorySelector from "$components/Forms/CategorySelector.svelte";
	import { onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import CreatorProfileTabs from './CreatorProfileTabs.svelte';
	import Curations from '$components/Curations.svelte';
	import Highlights from '$components/Highlights.svelte';
	import { pageHeader } from '$stores/layout';
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import CreatorFooter from '$components/Creator/CreatorFooter.svelte';
	import type { UserProfileType } from '../../app';
	import { openModal } from 'svelte-modals';
	import BecomeSupporterModal from '$modals/BecomeSupporterModal.svelte';

    let id: string;
    let { user } = $page.data;
    const defaultBanner = 'https://tonygiorgio.com/content/images/2023/03/cypherpunk-ostrach--copy--2.png';

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }

    onMount(() => {
        addReadReceipt(user);
        openModal(BecomeSupporterModal, { user, tiers: getUserSupportPlansStore() })
    })

    let articles: Readable<Map<NDKEventId, NDKArticle>>;

    $: if (!articles && userSubscription && $userSubscription) {
        articles = derived(userSubscription, $userSubscription => {
            const articles = new Map<NDKEventId, NDKArticle>();

            for (const event of $userSubscription) {
                if (
                    event.pubkey !== user.pubkey ||
                    event.kind !== NDKKind.Article
                ) continue;

                const id = event.encode();
                if (!articles.has(id)) articles.set(id, NDKArticle.from(event));
            }

            return articles;
        });
    }

    let userProfile: UserProfileType;
    let kind37777Event: NDKEvent | undefined;
    let canEdit = false;
    let editing = false;
    let editingCategories: string[] = [];

    $: if (user && user?.pubkey === $currentUser?.pubkey) canEdit = true;

    function edit() {
        editingCategories = userProfile.categories || [];
        editing = true;
    }

    async function save() {
        userProfile.display_name = userProfile.name;
        const profile = new NDKEvent($ndk, {
            kind: 0,
            content: serializeProfile(userProfile)
        } as NostrEvent);
        if (kind37777Event) profile.tags.push(["d", kind37777Event.tagValue("d")!]);
        for (const category of editingCategories) {
            profile.tags.push(["t", category]);
        }
        await profile.publish();
        editing = false;
    }

    $: if (userProfile && !userProfile.banner) userProfile.banner = defaultBanner;

    let activeTab: string = "Publications";

    $: $pageHeader = {}
</script>

<svelte:head>
    <title>{userProfile?.name ?? id} on Highlighter</title>
    <meta name="description" content="Creator profile" />
    <meta property="og:title" content={user.npub} />
    <meta property="og:description" content="Creator profile" />
    <meta property="og:image" content={userProfile?.image || defaultBanner} />
</svelte:head>

<MainWrapper class="sm:px-6" marginClass="max-w-3xl mx-auto">
    <UserProfile {user} bind:userProfile bind:kind37777Event let:fetching>
        <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%]">
            {#if userProfile && editing}
                <ImageUploader
                    class="absolute w-full h-full object-cover object-top lg:rounded"
                    bind:url={userProfile.banner}
                    let:onOpen
                >
                    <div class="bg-base-200 w-full h-full items-center justify-center flex flex-row">
                        <button class="btn btn-lg bg-base-200 border border-neutral-800 btn-circle" on:click={() => onOpen()}>
                            <Image class="w-8 h-8" />
                        </button>
                    </div>
                </ImageUploader>
            {:else}
                <img src={userProfile?.banner??defaultBanner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
            {/if}
        </div>
        <!-- Profile Header -->
        <div class="
            flex
            max-sm:flex-col max-sm:w-full max-sm:items-start max-sm:gap-4
            overflow-hidden
            items-end justify-between p-3 sm:p-6 relative -mt-16
            gap-4
        ">
            <div class="flex items-end">
                {#if canEdit}
                    <EditableAvatar user={user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black" />
                {:else}
                    <Avatar user={user} {userProfile} {fetching} class="w-28 h-28 flex-none object-cover mask mask-squircle rounded-none" />
                {/if}

                <div class="ml-4 overflow-clip">
                    <div class="name text-xl font-semibold text-base-100-content">
                        {#if editing && userProfile}
                            <div class="flex flex-row items-center gap-2">
                                <Pen class="w-4 h-4" />
                                <input bind:value={userProfile.name} class="border-none !bg-transparent !p-0 text-lg  border-b-2 border-white" />
                            </div>
                        {:else}
                            <Name {userProfile} {fetching} />
                        {/if}
                    </div>
                    <p class="text-sm truncate max-w-md text-neutral-500">
                        {#if editing && userProfile}
                            <div class="flex flex-row items-center gap-2">
                                <Pen class="w-4 h-4" />
                                <input bind:value={userProfile.about} class="border-none !bg-transparent !p-0 text-sm border-b-2 border-white" />
                            </div>
                        {:else}
                            {#if fetching && !userProfile?.about}
                                <div class="skeleton h-15 w-48">&nbsp;</div>
                            {:else if userProfile?.about}
                                {userProfile?.about}
                            {:else}
                                &nbsp;
                            {/if}
                        {/if}
                    </p>
                </div>
            </div>

            {#if !canEdit}
                {#if $userTiers}
                    <CurrentSupporters
                        supporters={getUserSupporters()}
                        tiers={getUserSupportPlansStore()}
                        {user}
                    />
                {/if}
            {:else}
                {#if editing}
                    <div class="flex flex-row items-center gap-8">
                        <button class="button" on:click={save}>Save</button>
                        <button class="" on:click={() => editing = false}>Cancel</button>
                    </div>
                {:else}
                    <button class="button" on:click={edit}>Edit</button>
                {/if}
            {/if}
        </div>

        {#if editing}
            <CategorySelector bind:categories={editingCategories} />
        {/if}
    </UserProfile>

    <div class="border-t border-b border-neutral-800 py-3 mb-6">
        <CreatorProfileTabs bind:value={activeTab} name={userProfile?.displayName} />
    </div>

    {#if activeTab === "Publications"}
        <div class="flex flex-row gap-10">
            {#if $userContent && $userGAContent}
                <div
                    class="w-full transition-all duration-300"
                    class:opacity-50={editing}
                >
                    <CreatorFeed content={$userContent} contentGA={$userGAContent} />
                </div>
            {/if}

        </div>
    {:else if activeTab === "Curations"}
        <Curations
            filter={{"authors": [user.pubkey]}}
        />
    {:else if activeTab === "Highlights"}
        <Highlights
            filter={{"authors": [user.pubkey]}}
        />
    {/if}
</MainWrapper>

<CreatorFooter {user} tiers={userTiers} />

<style lang="postcss">
    .name {
        @apply max-w-sm truncate;
    }
</style>