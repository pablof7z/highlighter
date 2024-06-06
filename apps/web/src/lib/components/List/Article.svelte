<script lang="ts">
	import { getSummary } from "$utils/article";
	import Name from '$components/User/Name.svelte';
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../../../app";
	import { urlSuffixFromEvent } from "$utils/url";
	import UserProfile from "$components/User/UserProfile.svelte";

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

<a {href} class="flex flex-row gap-6 {$$props.class??""}">
    <div class="flex-none overflow-hidden">
        {#if image}
            <img src={image} alt={article.title} class="object-cover w-32 h-24 rounded-2xl" />
        {:else}
            <div class="bg-gray-200" />
        {/if}
    </div>

    <div class="grow shrink basis-0 flex-col justify-between items-start gap-2 inline-flex max-h-36 overflow-clip">
        <div class="self-stretch text-foreground text-base font-medium leading-relaxed overflow-clip">
            {article.title}
            <div class="text-sm text-neutral-400">
                {summary}
            </div>
        </div>
        <UserProfile
            user={article.author}
            bind:userProfile
            bind:authorUrl
        >
            <Name
                user={article.author}
                spacing="gap-4"
                avatarSize="tiny"
                class="text-xs"
                bind:userProfile
                bind:authorUrl
            />
        </UserProfile>
    </div>
</a>
