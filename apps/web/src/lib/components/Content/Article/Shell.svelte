<script lang="ts">
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../../app";
	import Header from "./Header.svelte";

    export let event: NDKEvent | undefined = undefined;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let skipImage = false;
    export let navigationOptions: NavigationOption[] | undefined = undefined;
</script>

<div dir="auto" class="w-full flex flex-col max-sm:max-w-screen overflow-x-clip">
    <Header {...$$props} {...$$slots} />

    <div class="
        flex-col justify-start items-center gap-10 flex w-full max-sm:px-4 relative font-serif !text-3xl
        border-border border-t
    ">
        {#if !isPreview}
            <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <slot name="content" />

                {#if !isFullVersion && event}
                    <div class="absolute bottom-0 right-0 bg-gradient-to-t from-background to-transparent via-background/70 w-full h-2/3 flex flex-col items-center justify-center">
                        <UpgradeButton {event} />
                    </div>
                {/if}
            </div>
        {:else}
            <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                <slot name="content" />
            </div>
        {/if}
    </div>
</div>
