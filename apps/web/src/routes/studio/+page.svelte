<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { drafts } from "$stores/drafts";
	import { l, layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { eventKindToText, mainContentKinds, wrapEvent } from "$utils/event";
    import * as Card from '$components/ui/card';
	import { Button } from "$components/ui/button";
	import { ArrowRight, CurrencyDollarSimple, DotsThreeVertical, Lightning, Pen, Timer, TrashSimple, Users } from "phosphor-svelte";
    import * as Studio from '$components/Studio';
	
	import NewItemButton from "$views/Home/Main/NewItemButton.svelte";
	import { onDestroy } from "svelte";
	import { NDKKind } from "@nostr-dev-kit/ndk";

    l({
        title: "Studio",
        header: undefined,
        fullWidth: false,
        sidebar: false,
        back: { url: '/' },
        navigation: false
    });

    const content = $ndk.storeSubscribe({
        kinds: [ NDKKind.Article, NDKKind.HorizontalVideo ],
        authors: [$currentUser!.pubkey]
    })

    onDestroy(() => content.unsubscribe());

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

<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <Card.Root class="row-span-2 col-span-2 bg-secondary">
        <Card.Header>
            <Card.Title>
                Publications
            </Card.Title>
        </Card.Header>
    
        <Card.Content class="text-muted-foreground text-sm flex flex-col gap-3">
            <p>
                Group and monetize your content,
                providing your audience a place to find and interact with your work
                and with other members of your audience.
            </p>
        </Card.Content>
    
        <Card.Footer>
            <Button href="/publication/new">
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

<Studio.ContentList.Root {content} />