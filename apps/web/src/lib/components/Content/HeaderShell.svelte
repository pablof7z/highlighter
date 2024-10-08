<script lang="ts">
    import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { layout } from "$stores/layout";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { Badge } from "$components/ui/badge";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
    import * as App from "$components/App";

    export let isPreview = false;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string | undefined = undefined;
    
    export let skipSummary = false;
    export let skipImage = false;
    export let event: NDKEvent | undefined = undefined;

    export let title: string | false;
    export let zaps = false;
    export let toolbar = false;

    export let ignoreHeader = false;
    export let maxImageHeight = "max-h-[20rem]";

    let isInView: boolean;
    
    // $: if (!ignoreHeader && !isPreview) {
    //     $layout.header = undefined;
    //     $layout.title = title || "Untitled";
    // }
</script>

<App.HeaderShell class="
    flex flex-col gap-4
    {$$props.class??""}
" bind:isInView>
    {#if !skipImage}
        <div class="overflow-clip flex relative">
            <slot name="image" />
        </div>
    {/if}
    <div class="flex flex-col gap-0" data-header-shell-ignore>
        <div class="self-stretch text-foreground max-sm:text-xl text-4xl font-semibold responsive-padding" class:hidden={title === false}>
            <slot name="title" />
        </div>
        <div class="responsive-padding text-base text-foreground/70 font-normal lg:max-h-[10rem] overflow-y-auto scrollbar-hide" class:hidden={skipSummary}>
            <slot name="summary" />
        </div>

        {#if event && !ignoreHeader}
            <div class="flex flex-row gap-6 my-2">
                <Badge variant="secondary">
                    <a href={authorUrl}>
                        <AvatarWithName {userProfile} user={event.author} avatarSize="tiny" class="text-sm text-muted-foreground" />
                    </a>
                </Badge>

                {#if !isPreview}
                    <Badge variant="secondary">
                        <RelativeTime {event} />
                    </Badge>
                {/if}
            </div>
        {/if}

        <slot />

        {#if !isPreview}
            <div
                class="flex flex-col w-full divide-border border-y border-border"
                class:border-y={zaps || toolbar}
                class:divide-y={zaps && toolbar}
            >
                <slot name="zaps" />
                <slot name="toolbar" />
            </div>
        {/if}
    </div>
</App.HeaderShell>