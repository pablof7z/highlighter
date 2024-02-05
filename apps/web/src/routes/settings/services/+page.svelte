<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
    import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import ServiceItem from './ServiceItem.svelte';
	import { NDKEvent, NDKKind, NDKPrivateKeySigner, type NostrEvent } from '@nostr-dev-kit/ndk';

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: "Highlighter",
        left: {
            label: "Back",
            url: "/settings",
        }
    };
</script>

<MainWrapper>
    <div class="flex flex-col gap-6">
        <section>
            <h1>Publishing</h1>
            <ServiceItem
                kind={5905}
                title="Post Schedule"
                eventId="naddr1qqy8x6rfwpukzunyqgsgtssdxasw7nsewcr3545lkd3lflcgdj5swe5lh9gk0nw9xpvnf5grqsqqql8kvkq450"
            >
                <div slot="about">
                    <span class="text-white inline">Highlighter</span>
                    uses DVMs to schedule posts.
                    These services allow you to schedule posts from any nostr-compatible application.
                </div>
            </ServiceItem>
            <ServiceItem
                kind={NDKKind.DVMReqImageGeneration}
                title="Image Generation"
                eventId="naddr1qqg8x6mtw56h5dr6w3nk6wrjw3mr2qgawaehxw309ahx7um5wgkhqatz9emk2mrvdaexgetj9ehx2aqzyp2k0scmru0v6v7dzs9g805h08sqxmvqwd4zas32zn5nc8e85xaekqcyqqq8easlxv24f"
            >
                <div slot="about">
                    Highlighter uses Shipyard to schedule posts. Shipyard is a free and open source service that allows you to schedule posts to any nostr-compatible service.
                </div>
            </ServiceItem>
        </section>
    </div>
</MainWrapper>

<style lang="postcss">
    h1 {
        @apply text-2xl font-semibold text-neutral-200;
    }

    h2 {
        @apply text-xl font-semibold;
        @apply text-white/80;
        @apply mb-2;
    }

    section {
        @apply bg-base-200 rounded-box p-4 flex flex-col gap-6;
    }
</style>