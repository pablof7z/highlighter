<script lang="ts">
	import { Check, Lightning } from 'phosphor-svelte';
	import { Button } from "$components/ui/button";
	import { countWords } from '$utils/article';
	import ButtonWithCount from '$components/buttons/ButtonWithCount.svelte';
	import SmallZapButton from '$components/buttons/SmallZapButton.svelte';
	import { NDKEvent } from '@nostr-dev-kit/ndk';

    export let event: NDKEvent;
    export let zapped = false;
    let _zapped = zapped;

    // after zapping, the button will be green for 2 seconds
    $: if (_zapped) {
        _zapped = false;
        setTimeout(() => zapped = false, 2000);
    }
</script>

<SmallZapButton {event} />

<ButtonWithCount
    count={"1.1k"}
    class="gap-3"
>
    <Lightning class="w-4 h-4 text-gold" weight="fill" />
</ButtonWithCount>
