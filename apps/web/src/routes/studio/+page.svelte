<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { drafts } from "$stores/drafts";
	import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { eventKindToText, mainContentKinds, wrapEvent } from "$utils/event";
    import * as Card from '$components/ui/card';
    import * as DropdownMenu from '$components/ui/dropdown-menu';
	import { Button } from "$components/ui/button";
	import { ArrowRight, CurrencyDollarSimple, DotsThreeVertical, Lightning, Pen, Timer, TrashSimple, Users } from "phosphor-svelte";
	import { derived } from "svelte/store";
	import { eventIsPreview } from "$utils/preview";
	import { nicelyFormattedSatNumber } from "$utils";
	import PublishedToPills from "$components/Groups/PublishedToPills.svelte";
	import NewItemButton from "$views/Home/Main/NewItemButton.svelte";
	import { toast } from "svelte-sonner";

    $layout.title = "Studio";
    $layout.fullWidth = false;
    $layout.sidebar = false;
    $layout.header = undefined;
    $layout.back = { url: '/' };
    $layout.navigation = false;

    const content = $ndk.storeSubscribe({
        kinds: mainContentKinds,
        authors: [$currentUser.pubkey]
    }, { closeOnEose: true })

    const wrappedContent = derived(content, $content => $content.map(wrapEvent));
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
        <div class="flex flex-row gap-4 items-center w-full hover:bg-secondary/20 transition-all duration-200 rounded">
            <div class="flex-none w-1/12">
                {#if c.image || c.thumbnail}
                    <img src={c.image || c.thumbnail} class="w-16 h-16 rounded-sm object-cover flex-none" />
                {:else}
                    <div class="w-16 h-16 bg-secondary rounded-sm flex-none" />
                {/if}
            </div>

            <div class="w-4/12 flex flex-col gap-1 col-span-4 overflow-clip justify-center">
                <a href="/a/{c.encode()}">
                    {c.title}
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
                <div class="text-xs font-light text-muted-foreground">Reads</div>
            </div>

            <div class="w-1/12 flex flex-col items-center justify-center">
                <!-- Zaps -->
                <div class="text-lg font-bold flex flex-row items-center gap-1">
                    <Lightning class="text-gold" size={20} weight="fill" />
                    {nicelyFormattedSatNumber(Math.floor(Math.random() * 100000))}
                </div>
                <div class="text-xs font-light text-muted-foreground">Zaps</div>
            </div>

            <div class="w-2/12 flex flex-row justify-end gap-2">
                <DropdownMenu.Root>
                    <DropdownMenu.Trigger>
                        <Button size="icon" variant="secondary" class="rounded-full">
                            <DotsThreeVertical size={20} />
                        </Button>
                    </DropdownMenu.Trigger>
                    <DropdownMenu.Content>
                        <DropdownMenu.Group>
                            <DropdownMenu.Item href="/studio/article?eventId={c.encode()}" class="flex flex-row gap-2">
                                <Pen size={20} />
                                Edit
                            </DropdownMenu.Item>
                            <DropdownMenu.Item on:click={() => toast.info("Not implemented just yet!")} class="text-red-500 flex flex-row gap-2">
                                <TrashSimple size={20} />
                                Delete
                            </DropdownMenu.Item>
                        </DropdownMenu.Group>
                    </DropdownMenu.Content>
                </DropdownMenu.Root>
            </div>
        </div>
    {/each}
</div>