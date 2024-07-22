<script lang="ts">
	import { onDestroy, setContext } from 'svelte';
	import { Readable, Writable, writable } from 'svelte/store';
	import { layout } from "$stores/layout";
    import Header from "./Header.svelte";
	import { NDKArticle, NDKSimpleGroup, NDKVideo } from '@nostr-dev-kit/ndk';
	import Audience from './Audience.svelte';
    import * as Content from "$components/Content";
    import * as Article from "$components/Content/Article";
    import { publish, publishThread } from "./actions/publish.js";
	
	import { DraftItem } from '$stores/drafts';
    import { Mode, PublishInGroupStore, Types as StudioItemTypes } from "$components/Studio";
	import { Thread } from '$utils/thread';

    export let groups: Readable<Record<string, NDKSimpleGroup>>;
    export let event: Writable<NDKArticle | NDKVideo | undefined>;
    export let thread: Writable<Thread | undefined>;
    export let draft: DraftItem | undefined = undefined;
    export let publishInGroups: PublishInGroupStore;
    export let publishAt: Writable<Date | undefined>;
    export let mode: Writable<Mode>;
    export let type: Writable<StudioItemTypes>;

    $layout.header = {
        component: Header,
        props: {
            mode,
            event,
            groups,
            publishAt,
            publishInGroups,
            onPublish: async () => {
                await publish(
                    $event,
                    $thread,
                    $publishInGroups,
                    $publishAt,
                )
            }
            // onSsveDraft
        }
    }

    onDestroy(() => {
        $layout.header = undefined;
    });
</script>

<div class="flex flex-col w-full">
    {#if $mode === 'edit'}
        <slot {mode} {event} />
    {:else if $mode === 'audience'}
        <Audience
            {groups}
            {publishInGroups}
        />
    {:else if $mode === 'preview'}
        <Article.Header
            article={$event}
            isPreview
        >

        </Article.Header>
        <Content.Body event={$event} isPreview>

        </Content.Body>
    {/if}
</div>