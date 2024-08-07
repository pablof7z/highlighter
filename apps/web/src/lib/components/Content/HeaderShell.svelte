<script lang="ts">
    import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { inview } from "svelte-inview";
	import { layout } from "$stores/layout";
	import BackButton from "$components/App/Navigation/BackButton.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { Badge } from "$components/ui/badge";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";

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
    
    function inViewChange(e) {
        if (ignoreHeader) return;
        const { inView } = e.detail;

        isInView = inView;
        
        if (inView) {
            $layout.header = false;
        } else {
            $layout.header = undefined;
            $layout.title = title;
        }
    }
</script>


<div class="
    flex flex-col gap-4 {(!skipImage) ? '' : ""}
    {$$props.class??""}
" use:inview on:inview_change={inViewChange}>
    {#if !skipImage}
        <div class="overflow-clip flex relative">
            {#if !ignoreHeader}
                <div class="z-10 left-2 top-[var(--safe-area-inset-top)] absolute">
                    <BackButton href="/" />
                </div>
            {/if}
            <slot name="image" />
        </div>
    {/if}
    <div class="flex flex-col gap-0">
        <div class="self-stretch text-foreground max-sm:text-xl text-4xl font-semibold responsive-padding" class:hidden={title === false}>
            <slot name="title" />
        </div>
        <div class="responsive-padding text-base text-foreground/70 font-normal lg:max-h-[10rem] overflow-y-auto scrollbar-hide" class:hidden={skipSummary}>
            <slot name="summary" />
        </div>

        {#if event}
            <div class="flex flex-row gap-6 my-2">
                <Badge variant="secondary">
                    <a href={authorUrl}>
                        <AvatarWithName {userProfile} user={event.author} avatarSize="tiny" class="text-sm text-muted-foreground" />
                    </a>
                </Badge>

                <Badge variant="secondary">
                    <RelativeTime {event} />
                </Badge>
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
</div>