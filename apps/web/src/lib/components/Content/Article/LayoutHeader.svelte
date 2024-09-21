<script lang="ts">
	import { NDKEvent } from '@nostr-dev-kit/ndk';
    import BackButton from "$components/App/Navigation/BackButton.svelte";
	import { Button } from '$components/ui/button';
	import Avatar from '$components/User/Avatar.svelte';

    export let event: NDKEvent;
    export let title: string;
</script>

<div class="flex flex-row items-center justify-between px-2 h-full">
    <div class="absolute left-2">
        <BackButton />
    </div>
    
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full flex flex-row gap-2 items-center">
        <Avatar pubkey={event.pubkey} type="square" size="large" />
        {title}
    </div>

    <div class="absolute right-2">
        <Button>
            Subscribe
        </Button>
    </div>
</div>