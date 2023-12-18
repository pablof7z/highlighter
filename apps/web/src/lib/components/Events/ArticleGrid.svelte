<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKArticle, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import UserProfileFetch from "$components/User/UserProfile.svelte";
    import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";
    import type { UserProfile } from "../../../app";

    export let article: NDKArticle;
    export let size: "small" | "large" = "small";
    export let skipAuthor: boolean = false;
    const suffixUrl = article.tagValue("d") || article.id;

    const user = article.author;
    let userProfile: UserProfile | undefined = undefined;

    let authorId = user.npub;
    let articleLink = `/${user.npub}/${suffixUrl}`;

    $: authorId = userProfile?.nip05 ? prettifyNip05(userProfile.nip05, 999999) : user.npub;
    $: articleLink = `/${authorId}/${suffixUrl}`;

    const isFullVersion = !article.tagValue("full");
    const wordCount = article.content.split(" ").length;
    const readTime = Math.ceil(wordCount / 265);

    const defaultUrl = "https://cdn.satellite.earth/01a8a5f5162a90fd7e6d3af6bc86d975e08a98f1852864c8ae7d8ba547bad669.png";
</script>

<UserProfileFetch {user} bind:userProfile let:fetching>
    <a href={articleLink} class="flex flex-col items-start gap-4 h-full w-full">
        <img class="{size} max-sm:!w-full max-sm:!h-fit object-cover bg-gradient-to-r from-base-300/80 to-base-300 border-none object-top flex-none round" src={article.image??defaultUrl} />
        <div class="self-stretch justify-start items-start gap-4 inline-flex max-sm:px-4">
            {#if !skipAuthor}
                <a href="/{authorId}" class="justify-start flex-none items-start gap-4 flex">
                    <Avatar {user} {userProfile} {fetching} class="w-11 h-11 rounded-full" />
                </a>
            {/if}
            <div class="w-full shrink flex-col justify-start items-start gap-2 flex">
                <div class="self-stretch text-white text-[15px] font-medium max-h-10 overflow-y-clip">
                    {article.title}
                </div>
                <div class="flex self-stretch h-[38px] flex-row sm:flex-col justify-start items-center
                    gap-8 sm:gap-1
                ">
                    {#if !skipAuthor}
                        <a href="/{authorId}" class="self-stretch text-white text-opacity-60 text-sm font-medium">
                            <Name {user} {userProfile} {fetching} />
                        </a>
                    {/if}
                    {#if isFullVersion}
                        <div class="self-stretch text-white text-opacity-60 text-sm font-medium">
                            {readTime} min read
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </a>
</UserProfileFetch>

<style lang="postcss">
    .small {
        width: 321px;
        height: 180px;
    }

    .large {
        @apply w-[346px] h-[180px];
    }

    a {
        @apply transition-all duration-300 ease-in-out;
    }

    a:hover {
        transform: scale(1.02);
    }
</style>