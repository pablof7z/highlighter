<script lang="ts">
	import { onDestroy, setContext } from 'svelte';
	import { Readable, Writable, writable } from 'svelte/store';
	import { layout } from "$stores/layout";
    import Header from "./Header.svelte";
	import { NDKArticle, NDKList, NDKSimpleGroup, NDKVideo } from '@nostr-dev-kit/ndk';
	import Audience from './Audience.svelte';
    import * as Content from "$components/Content";
    import * as Article from "$components/Content/Article";
	
	import { DraftItem } from '$stores/drafts';
    import { Mode, PublishInGroupStore, PublishInTierStore, Scope, Types as StudioItemTypes } from "$components/Studio";
	import { Thread } from '$utils/thread';
	import { addDraftCheckpoint } from '$utils/drafts';
	import Publish from './Publish.svelte';

    export let event: Writable<NDKArticle | NDKVideo | undefined>;
    export let preview: Writable<NDKArticle | NDKVideo | undefined>;
    export let thread: Writable<Thread | undefined>;
    export let withPreview: Writable<boolean>;

    export let mode: Writable<Mode>;
    export let type: Writable<StudioItemTypes>;
    export let groupsList: Readable<NDKList | undefined>;
    
    export let draft: DraftItem | undefined = undefined;
    export let publishInGroups: PublishInGroupStore;
    export let publishInTiers: PublishInTierStore;
    export let publishAt: Writable<Date | undefined>;
    export let publishScope: Writable<Scope>;

    export let authorUrl: string;

    $layout.header = {
        component: Header,
        props: {
            mode,
            event,
            publishScope,
            publishAt,
            publishInGroups,
            onSaveDraft: async (manuallySaved: boolean) => {
                const res = addDraftCheckpoint(
                    manuallySaved,
                    draft,
                    { event: JSON.stringify($event!.rawEvent()) },
                    "article",
                    $event!
                )

                if (res) {
                    draft = res;
                    return true;
                }
            },
            onPublish: async () => {
                $mode = 'publish';
            }
        }
    }

    onDestroy(() => {
        $layout.header = undefined;
    });
</script>
<div class="flex flex-col w-full">
    <div class:hidden={$mode !== 'audience'}>
        <Audience
            {preview}
            {type}
            {withPreview}
            {publishInGroups}
            {publishInTiers}
            {publishScope}
        />
    </div>
    <div class:hidden={$mode !== 'edit'}>
        <slot {mode} {event} />
    </div>
    {#if $mode === 'preview' && $event instanceof NDKArticle}
        <Article.Header
            article={$event}
            isPreview
        >

        </Article.Header>
        <Content.Body event={$event} isPreview>

        </Content.Body>
    {:else if $mode === 'publish'}
        <Publish
            {event}
            {preview}
            {withPreview}
            {authorUrl}
            {publishScope}
            {publishInGroups}
            {publishInTiers}
            {publishAt}
            {type}
        />
    {/if}
</div>