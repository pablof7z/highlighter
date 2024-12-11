<script lang="ts">
	import RelayList from '@/components/ui/RelayList.svelte';
    import { appState } from '@/state/app.svelte';
    import * as Card from '@/components/ui/card';
</script>

<main>
    <header>
        <h1>Relays</h1>
        <h2>
            Configure where Highlighter Studio publishes your content.
        </h2>
    </header>

    <section>
        <header>
            <h2>Application Relays</h2>
        </header>
        <RelayList bind:relays={appState.relays} />
    </section>
    
    <section>
        <header>
            <h2>Draft Relays</h2>
            <h3>
                These are the relays where your drafts will be stored. These should be a
                few relays you trust.
            </h3>
        </header>
        <RelayList bind:relays={appState.draftRelays} />
    </section>
</main>

<style lang="postcss">
    main > header {
        @apply text-2xl font-medium tracking-tight;
        @apply pb-4 mb-8;
        @apply border-b border-border;
        
        h2 {
            @apply text-sm text-muted-foreground font-normal tracking-tight;
            @apply mb-2;
        }
    }

    section {
        @apply my-6;

        header {
            @apply mb-4;
        }
        
        h2 {
            @apply text-base font-normal tracking-tight;
        }

        h3 {
            @apply text-xs text-muted-foreground;
        }
    }

    section + section {
        @apply border-t border-border pt-6;
    }
</style>