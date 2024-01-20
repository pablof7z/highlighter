<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { getSummary } from "$utils/article";
	import { RelativeTime, ndk } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";

    export let article: NDKArticle;
    export let skipAuthor = false;

    let userProfile: UserProfileType;
    let authorUrl: string;

    const summary = article.summary || getSummary(article);

    let image = article.image;
    let suffixUrl = urlSuffixFromEvent(article);
    let href: string;

    $: if (!image) { image = userProfile?.image || userProfile?.banner }
    $: href = `${authorUrl}/${suffixUrl}`;
</script>

<a {href} class="flex flex-row gap-6">
    <div class="w-64 h-36 flex-none overflow-hidden rounded-2xl">
        {#if image}
            <img src={image} alt={article.title} class="h-auto w-auto object-cover" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
    </div>

    <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex max-h-36 overflow-clip">
        {#if !skipAuthor}
            <div class="self-stretch justify-between items-center inline-flex leading-5">
                <div class="justify-start items-center gap-3 flex">
                    <AvatarWithName
                        user={article.author}
                        spacing="gap-4"
                        avatarSize="small"
                        bind:userProfile
                        bind:authorUrl
                    />

                    <RelativeTime event={article} class="text-sm opacity-60" />
                </div>
            </div>
        {:else}
            <UserProfile bind:userProfile user={article.author} bind:authorUrl />
        {/if}
        <div class="self-stretch text-neutral-200 text-xl font-semibold leading-relaxed">
            {article.title}
        </div>
        <div class="self-stretch text-neutral-500 text-sm font-normal overflow-y-clip">
            {summary}
        </div>
    </div>
</a>
