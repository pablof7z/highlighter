<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { getSummary } from "$utils/article";
	import { RelativeTime, ndk } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";

    export let article: NDKArticle;
    export let href: string | undefined = undefined;

    const explicitHref = !!href;

    let userProfile: UserProfileType;
    let authorUrl: string;

    const summary = article.summary || getSummary(article);

    let image = article.image;
    let suffixUrl = urlSuffixFromEvent(article);

    $: if (!image) { image = userProfile?.image || userProfile?.banner }
    $: if (!explicitHref) href = `${authorUrl}/${suffixUrl}`;
</script>

<a {href} class="flex flex-row gap-6">
    <div class="w-32 h-18 flex-none overflow-hidden rounded-2xl">
        {#if image}
            <img src={image} alt={article.title} class="h-auto w-auto object-cover" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
    </div>

    <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex max-h-36 overflow-clip">
        <div class="self-stretch justify-between items-center inline-flex leading-5">
        </div>
        <div class="self-stretch text-white text-base font-normal leading-relaxed">
            {article.title}
        </div>
        <AvatarWithName
            user={article.author}
            spacing="gap-4"
            avatarSize="tiny"
            bind:userProfile
            bind:authorUrl
        />
    </div>
</a>
