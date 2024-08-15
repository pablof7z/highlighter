<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Crown, CrownSimple, LockSimple } from "phosphor-svelte";
	import { Button } from '$components/ui/button';
    import * as Groups from "$components/Groups"
	import { get } from "svelte/store";
	import { getGroupUrl } from "$utils/url";

    export let event: NDKEvent;
    export let text = "This is a members-only post. Subscribe to read the full article.";

    const author = event.author;

    const hTags = event.getMatchingTags("h");
</script>

<Button variant="outline" size="lg" class="border-accent hover:bg-background hover:text-foreground font-sans flex flex-col items-center p-4 h-fit {$$props.class??""}">
    <CrownSimple class="w-6 h-6" weight="fill" />

    {#if $$slots.default}
    {:else}
        <div class="text-lg font-medium">
            This is a members-only post.
        </div>
        <div class="text-muted-foreground">
            Join to read the full article.
        </div>

        <div class="my-2"></div>

        <Groups.RootList tags={hTags} let:group>
            <Button href={getGroupUrl(get(group))} variant="outline" class="flex flex-row items-center gap-2">
                <Groups.Avatar group={get(group)} size="tiny" />
                <Groups.Name group={get(group)} />
            </Button>
        </Groups.RootList>
    {/if}
</Button>