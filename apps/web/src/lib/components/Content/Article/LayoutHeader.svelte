<script lang="ts">
	import { NDKEvent } from '@nostr-dev-kit/ndk';
    import BackButton from "$components/App/Navigation/BackButton.svelte";
	import { openModal } from '$utils/modal';
	import SubscribeModal from '$modals/SubscribeModal/index.svelte';
    import * as Buttons from "$components/buttons";
	import AvatarWithName from '$components/User/AvatarWithName.svelte';

    export let event: NDKEvent;
    export let title: string;

    function subscribe() {
        openModal(SubscribeModal, { event });
    }
</script>

<div class="flex flex-row items-center justify-between px-2 h-full">
    <div class="absolute left-2">
        <BackButton />
    </div>
    
    <div class="max-w-[var(--content-focused-width)] mx-auto w-full flex flex-row gap-2 items-center">
        <AvatarWithName pubkey={event.pubkey} avatarType="square" avatarSize="large">
            <span class="text-muted-foreground text-xs">
                {title}
            </span>
        </AvatarWithName>

        <div class="grow"></div>

        <Buttons.EventMainCta
            {event}
            skipText
        />
    </div>
</div>