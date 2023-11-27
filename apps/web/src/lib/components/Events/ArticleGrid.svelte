<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKArticle, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";

    export let article: NDKArticle;
    export let size: "small" | "large" = "small";
    export let skipAuthor: boolean = false;
    const suffixUrl = article.tagValue("d") || article.id.slice(0, 18);

    const user = article.author;
    let userProfile: NDKUserProfile | undefined = undefined;

    let articleLink = `/${user.npub}/${suffixUrl}`;
    user.fetchProfile().then(profile => {
        if (profile && profile.nip05) {
            userProfile = profile;
            const nip05 = prettifyNip05(profile.nip05, 999999);
            articleLink = `/${nip05}/${suffixUrl}`;
        }
    });

    const isFullVersion = !article.tagValue("full");
    const wordCount = article.content.split(" ").length;
    const readTime = Math.ceil(wordCount / 265);
</script>

<a href={articleLink} class="grow shrink basis-0 flex-col justify-between items-start gap-4 inline-flex h-full">
    <img class="max-sm:{size} object-cover relative rounded-xl flex-grow" src={article.image} />
    <div class="self-stretch justify-start items-start gap-4 inline-flex">
        {#if !skipAuthor}
            <div class="justify-start items-start gap-4 flex">
                <Avatar {user} {userProfile} class="w-11 h-11 rounded-full" />
            </div>
        {/if}
        <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex">
            <div class="self-stretch text-white text-[15px] font-medium">
                {article.title}
            </div>
            <div class="self-stretch h-[38px] flex-col justify-start items-start gap-1 flex">
                {#if !skipAuthor}
                    <div class="self-stretch text-white text-opacity-60 text-sm font-medium">
                        <Name {user} {userProfile} />
                    </div>
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

<style lang="postcss">
    .small {
        @apply w-72 h-40;
    }

    .large {
        @apply w-[346px] h-52;
    }

    a {
        @apply transition-all duration-300 ease-in-out;
    }

    a:hover {
        transform: scale(1.02);
    }
</style>