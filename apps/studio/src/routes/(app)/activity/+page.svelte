<script lang="ts">
	import AvatarWithName from "@/components/user/AvatarWithName.svelte";
	import { currentUser } from "@/state/current-user.svelte";
	import { ndk } from "@/state/ndk";
	import { NDKEvent, NDKHighlight, NDKKind } from "@nostr-dev-kit/ndk";

    const user = $derived.by(currentUser);

    let myContent = $state<NDKEvent[] | null>(null);
    const myContentIds = $derived(myContent?.map(c => c.tagId()));

    let highlights = $state<NDKHighlight[] | null>(null);
    let comments = $state<NDKEvent[] | null>(null);

    $effect(() => {
        if (!user || myContent) return;

        myContent = ndk.$subscribe([
            { kinds: [NDKKind.Article], "authors": [user.pubkey]}
        ])
    })

    $inspect('eosed?', myContent?.eosed);
    $inspect('my content length', myContent?.length);

    $effect(() => {
        if (!user || highlights || !myContent || !myContent.eosed) return;

        highlights = ndk.$subscribe([
            { kinds: [NDKKind.Highlight], "#a": myContentIds}
        ])

        comments = ndk.$subscribe([
            { kinds: [NDKKind.Text, NDKKind.GenericRespose], "#a": myContentIds}
        ])
    });
</script>


<div class="flex items-center justify-between space-y-2">
	<h2 class="text-3xl font-bold tracking-tight">Activity</h2>
</div>

{#if highlights}
	{#each highlights as highlight (highlight.id)}
        <div class="bg-muted p-4 rounded-md">
            {highlight.content}
            
            <div class="flex flex-row gap-2 mt-4">
                Highlighted by <AvatarWithName of={highlight.pubkey} />
            </div>
        </div>
	{/each}
{/if}

{#each (comments??[]) as comment (comment.id)}
    <div class="bg-muted p-4 rounded-md">
        <AvatarWithName of={comment.pubkey} />
        <p>{comment.content}</p>

        on

        {comment.tagValue("a")}
    </div>
{/each}