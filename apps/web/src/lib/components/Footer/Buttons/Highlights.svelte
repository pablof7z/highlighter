<script lang="ts">
	import { goto } from '$app/navigation';
	import { getEventUrl } from '$utils/url';
	import LogoSmall from './../../../icons/LogoSmall.svelte';
	import { ndk } from '$stores/ndk.js';
	import { ChatCircle } from 'phosphor-svelte';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import { onDestroy } from 'svelte';

    export let event: NDKEvent;

    const highlights = $ndk.storeSubscribe([
        { kinds: [NDKKind.Highlight], ...event.filter() },
    ])

    onDestroy(() => {
        highlights.unsubscribe();
    });

    function clicked() {
        goto(getEventUrl(event, undefined, 'highlights'));
    }
</script>

<ButtonWithCount
    count={$highlights.length}
    class="gap-3 hover:bg-orange-500/20 group rounded-full text-muted-foreground"
    on:click={clicked}
>
    <LogoSmall class="w-6 h-6 transition-all duration-100 group-hover:text-orange-500" />
</ButtonWithCount>
