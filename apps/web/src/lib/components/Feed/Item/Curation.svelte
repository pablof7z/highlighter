<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKList } from "@nostr-dev-kit/ndk";
	import RelatedEvents from "./RelatedEvents.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { appMobileView } from "$stores/app";
	import { pluralize } from "$utils";

    export let list: NDKList;
    export let skipAuthor = false;
    export let href: string | undefined = undefined;
    export let index: number | undefined = undefined;

    $: href = href || `/a/${list.encode()}`;

    const items = list.items.length;
</script>

<a {href} class="flex flex-col gap-2 min-h-[5rem] lg:min-h-[10rem] {$$props.class??""}">
    <div class="flex flex-row gap-4 ">
        <div class="w-1/3 flex-none">
            {#if list.image}
                <img src={list.image} alt={list.title} class="w-full h-full object-cover rounded-sm" />
            {/if}
        </div>

        <div class="w-2/3 flex flex-col">
            <h2 class="text-lg font-bold mb-0 max-sm:max-h-[3.5rem] overflow-y-clip">{list.title}</h2>
            <div class="flex flex-row gap-4 text-muted-foreground lg:text-xs text-sm w-full items-center">
                {#if !skipAuthor}
                    <AvatarWithName user={list.author} avatarSize="tiny" />
                {/if}

                <Badge variant="secondary" class="font-normal text-muted-foreground">
                    <RelativeTime event={list} />
                </Badge>

                <Badge variant="secondary" class="font-normal text-muted-foreground">
                    {items} {pluralize(items, "item")}
                </Badge>
            </div>
            {#if list.description}
                <p class="lg:text-sm text-muted-foreground mt-2 max-sm:max-h-[5rem] overflow-clip">{list.description}</p>
            {/if}

            {#if !$appMobileView}
                <RelatedEvents event={list} class="mt-4" />
            {/if}
        </div>
    </div>

    {#if $appMobileView}
        <RelatedEvents event={list} />
    {/if}
</a>