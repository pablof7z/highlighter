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

    const defaultUrl = "https://cdn.satellite.earth/01a8a5f5162a90fd7e6d3af6bc86d975e08a98f1852864c8ae7d8ba547bad669.png";
</script>

<a href={articleLink} class="flex flex-col items-start gap-4 h-full">
    <img class="max-sm:{size} object-cover bg-gradiesnt-to-r from-base-300/80 to-base-300 border-none object-top flex-none rounded-xl !w-[321px] !h-[180px]" src={article.image??defaultUrl} />
    <div class="self-stretch justify-start items-start gap-4 inline-flex">
        {#if !skipAuthor}
            <div class="justify-start flex-none items-start gap-4 flex">
                <Avatar {user} {userProfile} class="w-11 h-11 rounded-full" />
            </div>
        {/if}
        <div class="w-full shrink flex-col justify-start items-start gap-2 flex">
            <div class="self-stretch text-white text-[15px] font-medium max-h-10 overflow-y-clip">
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
        @apply w-[346px] h-[180px];
    }

    a {
        @apply transition-all duration-300 ease-in-out;
    }

    a:hover {
        transform: scale(1.02);
    }
</style>