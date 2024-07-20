<script lang="ts">
	import { onDestroy, setContext } from 'svelte';
	import { Readable, writable } from 'svelte/store';
	import { layout } from "$stores/layout";
    import Header from "./Header.svelte";
	import { NDKArticle, NDKSimpleGroup, NDKVideo } from '@nostr-dev-kit/ndk';
	import Audience from './Audience.svelte';
    import * as Content from "$components/Content";
    import * as Article from "$components/Content/Article";
    import { publish } from "./actions/publish.js";
	import { goto } from '$app/navigation';

    export let groups: Readable<Record<string, NDKSimpleGroup>>;
    
    const event = writable<NDKArticle | NDKVideo | undefined>();
    const mode = writable<string>('edit');
    const publishAt = writable<Date | undefined>();

    setContext('mode', mode);
    setContext('event', event);

    $layout.header = {
        component: Header,
        props: {
            mode,
            event,
            publishAt,
            onPublish: async () => {
                const e = await publish($event, $publishAt);
                if (e) {
                    // delete draft
                    goto(`/a/${e.encode()}`);
                }
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
    <Audience {event} {groups} />
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