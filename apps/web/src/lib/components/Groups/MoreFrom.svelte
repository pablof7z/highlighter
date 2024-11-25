<script lang="ts">
	import { Hexpubkey, NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import { addToInbox } from "$lib/utils/user/inbox";
	import { derived, Readable } from "svelte/store";
	import { groupsList, userFollows } from "$stores/session";
	import Button from "$components/ui/button/button.svelte";
	import { Inbox, UserPlus, ArrowRight } from "lucide-svelte";
	import ArticleCard from "$components/Card/ArticleCard.svelte";
	import { ndk } from "$stores/ndk";
    import * as Groups from "$components/Groups";
    import * as Feed from "$components/Feed";
    import * as Buttons from "$components/Buttons";
	import EventMainCta from "$components/buttons/EventMainCta.svelte";

    export let group: Readable<Groups.GroupData>;
    export let articles: Readable<NDKArticle[]>;
    const groupId = $group.id!;
    export let skipIds: Set<string> = new Set();
    export let filter: NDKFilter = { '#h': [groupId]}

    const isPinned = derived(groupsList, $groupsList => $groupsList && $groupsList.items.includes(groupId))

    const contentWithoutSkips = derived(articles, $articles => $articles.filter(i => !skipIds.has(i.tagId())))
</script>

<div class="my-10 border border-border bg-secondary/50 p-4 rounded-lg min-h-[150px] flex flex-col gap-6">
    <div class="flex flex-row gap-4">

        <a href={""} class="flex-none">
            <img src={$group.picture} class="rounded-lg w-32 h-32 object-cover" />
        </a>
        
        <div class="flex flex-col gap-2">

            <a href={""}>
                {$group.name}
            </a>

            <EventContent ndk={$ndk} event={new NDKEvent()} content={$group.about} class="text-muted-foreground text-sm max-h-[80px[" />

            <div class="mt-1 flex flex-row gap-2">
                <Buttons.GroupMainCta {group} />
                
                {#if !$isPinned}
                    <Button variant="secondary" class="flex flex-row items-center rounded-full">
                        <UserPlus size={18} />
                    </Button>
                {/if}
            </div>
            
        </div>
    </div>

    <div class="flex flex-col gap-4 overflow-x-auto">
        {#each $contentWithoutSkips as article}
            <Feed.Items.Article {article} />
            <!-- <ArticleCard
                width="w-60"
                height="h-80"
                {article}
                skipAuthor
                class="grayscale hover:grayscale-0 transition-all duration-300 group"
                imgClass="opacity-50 group-hover:opacity-100 transition-all duration-300"
            /> -->
        {/each}
    </div>

</div>