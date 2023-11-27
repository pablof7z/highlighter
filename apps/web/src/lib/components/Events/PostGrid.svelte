<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKArticle, NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
    export let size: "small" | "large" = "small";
    export let skipAuthor: boolean = false;
    const suffixUrl = event.tagValue("d") || event.id.slice(0, 18);

    const user = event.author;
    let userProfile: NDKUserProfile | undefined = undefined;

    let articleLink = `/${user.npub}/${suffixUrl}`;
    user.fetchProfile().then(profile => {
        if (profile && profile.nip05) {
            userProfile = profile;
            const nip05 = prettifyNip05(profile.nip05, 999999);
            articleLink = `/${nip05}/${suffixUrl}`;
        }
    });

    const wordCount = event.content.split(" ").length;
    const readTime = Math.ceil(wordCount / 265);
</script>

<a href={articleLink} class="grow shrink basis-0 flex-col justify-between items-start gap-4 inline-flex h-full">
    <div class="w-72 h-40 flex-grow bg-base-200 p-6 text-lg overflow-hidden relative rounded-lg">
        <div class="w-96">
            {event.content}
        </div>
        <div class="h-full w-6 bg-gradient-to-r from-transparent to-black absolute top-0 right-0"></div>
        <div class="w-full h-10 bg-gradient-to-b from-transparent to-black absolute bottom-0 left-0"></div>
    </div>
    <div class="self-stretch justify-start items-start gap-4 inline-flex">
        {#if !skipAuthor}
            <div class="justify-start items-start gap-4 flex">
                <Avatar {user} {userProfile} class="w-11 h-11 rounded-full" />
            </div>
        {/if}
        <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex">
            <div class="self-stretch text-white text-[15px] font-medium">

            </div>
            <div class="self-stretch h-[38px] flex-col justify-start items-start gap-1 flex">
                {#if !skipAuthor}
                    <div class="self-stretch text-white text-opacity-60 text-sm font-medium">
                        <Name {user} {userProfile} />
                    </div>
                {/if}
                <div class="self-stretch text-white text-opacity-60 text-sm font-medium">
                    {readTime} min read
                </div>
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