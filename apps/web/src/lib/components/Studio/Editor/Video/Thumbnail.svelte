<script lang="ts">
    import * as Studio from '$components/Studio';
	import { NDKVideo } from '@nostr-dev-kit/ndk';
    import * as Collapsible from '$components/ui/collapsible/';
	import { Button } from '$components/ui/button';
    import ChooseVideoThumbnail from '$components/Forms/ChooseVideoThumbnail.svelte';
	import { Writable } from 'svelte/store';
	import { CaretDown } from 'phosphor-svelte';

    export let state: Writable<Studio.State<"video">>;
    let video: NDKVideo = $state.video;
    $: $state.video = video;

    export let videoFile: File | undefined;
    
    export let done: boolean;
    let status: string | undefined;

    let selectedBlob: Blob | undefined = undefined;
</script>

<Collapsible.Root class="my-6">
    <Collapsible.Trigger asChild let:builder>
        <Button builders={[builder]} variant="outline" class="w-full justify-between text-muted-foreground text-lg h-auto">
            <span>Thumbnail</span>
            <span class="text-sm">
                {status??""}
                <CaretDown class="w-4 h-4 text-muted-foreground inline" />
            </span>
        </Button>
    </Collapsible.Trigger>
    <Collapsible.Content>
        <section class="settings">
            <div class="field">
                <div class="title">Cover Image</div>

                <ChooseVideoThumbnail
                    {videoFile}
                    currentThumbnail={video.thumbnail}
                    title={video.title??"Untitled"}
                    content={video.content??""}
                    duration={video.duration}
                    bind:selectedBlob
                />
            </div>
        </section>
    </Collapsible.Content>
</Collapsible.Root>