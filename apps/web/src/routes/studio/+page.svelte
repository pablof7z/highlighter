<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { drafts } from "$stores/drafts";
	import { l, layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { eventKindToText, mainContentKinds, wrapEvent } from "$utils/event";
    import * as Card from '$components/ui/card';
    import * as DropdownMenu from '$components/ui/dropdown-menu';
    import * as Event from '$components/Event';
	import { Button } from "$components/ui/button";
	import { ArrowRight, CurrencyDollarSimple, DotsThreeVertical, Lightning, Pen, Timer, TrashSimple, Users } from "phosphor-svelte";
	import { derived, writable } from "svelte/store";
	import { eventIsPreview } from "$utils/preview";
	import { nicelyFormattedSatNumber } from "$utils";
	import PublishedToPills from "$components/Groups/PublishedToPills.svelte";
	import NewItemButton from "$views/Home/Main/NewItemButton.svelte";
	import { onDestroy } from "svelte";

    l({
        title: "Studio",
        header: undefined,
        fullWidth: false,
        sidebar: false,
        back: { url: '/' },
        navigation: false
    });

    const deletedItems = writable(new Set<string>());

    const content = $ndk.storeSubscribe({
        kinds: mainContentKinds,
        authors: [$currentUser!.pubkey]
    })

    onDestroy(() => content.unsubscribe());

    const withoutDeletes = derived([content, deletedItems], ([$content, $deletedItems]) => {
        return $content
            .filter(c => !c.hasTag("deleted"))
            .filter(c => !$deletedItems.has(c.id));
    });

    const wrappedContent = derived(withoutDeletes, $content => $content.map(wrapEvent));

    // async function deleteEvent(event: NDKEvent) {
    //     toast.info(`${eventKindToText(event.kind)} deleted`, {
    //         action: {
    //             label: "Undo",
    //             onClick: () => {
    //                 clearTimeout(deleteTimeout);
    //                 dispatch('delete:cancel', event)
    //                 goto(eventUrl);
    //                 toast.success("Post restored!");
    //             }
    //         }
    //     }
    // }
</script>

<div class="flex flex-row items-start justify-between my-10">
    <div class="flex flex-col items-start">
        <h1 class="text-5xl font-bold mb-0">
            Studio
        </h1>
        <h3 class="font-light text-muted-foreground text-lg">
            A place to manage all your content
        </h3>
    </div>

    <NewItemButton />
</div>

<div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <Card.Root class="row-span-2 col-span-2 bg-secondary">
        <Card.Header>
            <Card.Title>
                Publications
            </Card.Title>
        </Card.Header>
    
        <Card.Content class="text-muted-foreground text-sm flex flex-col gap-3">
            <p>
                A place for your long-forms, notes, videos and podcasts.
            </p>

            <p>
                A place for your audience to discover, discuss and turbocharge your content's distribution organically.
            </p>
        </Card.Content>
    
        <Card.Footer>
            <Button>
                Create Your Publication
                <ArrowRight class="ml-2" />
            </Button>
        </Card.Footer>
    </Card.Root>

    <Card.Root>
        <a href="/studio/drafts" class="grow">
            <Card.Header
                class="flex flex-row items-center justify-between space-y-0 pb-2"
            >
                <Card.Title class="text-sm font-medium">Drafts</Card.Title>
                <Pen class="text-muted-foreground h-4 w-4" />
            </Card.Header>
            <Card.Content>
                <div class="text-2xl font-bold">{$drafts.length}</div>
            </Card.Content>
        </a>
    </Card.Root>
        
    <Card.Root>
        <Card.Header
            class="flex flex-row items-center justify-between space-y-0 pb-2"
        >
            <Card.Title class="text-sm font-medium">Scheduled</Card.Title>
            <Timer class="text-muted-foreground h-4 w-4" />
        </Card.Header>
        <Card.Content>
            <div class="text-2xl font-bold">0</div>
        </Card.Content>
    </Card.Root>
    
    <Card.Root class="col-span-2">
        <Card.Header
            class="flex flex-row items-center justify-between space-y-0 pb-2"
        >
            <Card.Title class="text-sm font-medium">Subscribers</Card.Title>
            <Users class="text-muted-foreground h-4 w-4" />
        </Card.Header>
        <Card.Content>
            <div class="text-2xl font-bold">420</div>
            <p class="text-muted-foreground text-xs">(coming soon)</p>
        </Card.Content>
    </Card.Root>
</div>

<div class="flex flex-col gap-4">
    {#each $wrappedContent as c (c.id)}
        <div
            class="flex flex-row gap-4 items-center w-full hover:bg-secondary/20 transition-all duration-200 rounded"
        >
            <div class="flex-none w-1/12">
                {#if c.image || c.thumbnail}
                    <img src={c.image || c.thumbnail} class="w-16 h-16 rounded-sm object-cover flex-none" />
                {:else}
                    <div class="w-16 h-16 bg-secondary rounded-sm flex-none" />
                {/if}
            </div>

            <div class="grow flex flex-col gap-1 col-span-4 overflow-clip justify-center">
                <a href="/a/{c.encode()}">
                    {c.title??c.dTag}
                    {#if eventIsPreview(c)}
                        <div class="text-muted-foreground text-xs">(Preview version)</div>
                    {/if}
                </a>
            </div>

            <div class="w-2/12 text-muted-foreground text-xs flex flex-col justify-center col-span-2">
                {eventKindToText(c.kind)}
                <div class="w-fit">
                    <PublishedToPills event={c} />
                </div>
            </div>

            <div class="w-1/12 flex flex-col items-center justify-center">
                <!-- Views -->
                <div class="text-lg font-bold">{Math.floor(Math.random() * 1000)}</div>
                <div class="text-xs font-light text-muted-foreground">Views</div>
            </div>

            <div class="w-1/12 flex flex-col items-center justify-center">
                <!-- Zaps -->
                <div class="text-lg font-bold flex flex-row items-center gap-1">
                    <Lightning class="text-gold" size={20} weight="fill" />
                    {nicelyFormattedSatNumber(Math.floor(Math.random() * 100000))}
                </div>
                <div class="text-xs font-light text-muted-foreground">Zaps</div>
            </div>

            <div class="w-1/12 flex flex-row justify-end gap-2">
                <Event.Dropdown
                    event={c}
                    on:delete={() => deletedItems.update(set => set.add(c.id))}
                    on:delete:cancel={() => deletedItems.update(set => {set.delete(c.id); return set})}
                />
            </div>
        </div>
    {/each}
</div>