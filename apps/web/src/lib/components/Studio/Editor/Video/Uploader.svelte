<script lang="ts">
    import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import VideoUploader from '$components/Forms/VideoUploader.svelte';
    import * as Studio from '$components/Studio';
	import { NDKVideo } from '@nostr-dev-kit/ndk';
    import { Input } from '$components/ui/input';
    import * as Collapsible from '$components/ui/collapsible/';
	import { Button } from '$components/ui/button';
	import { Writable } from 'svelte/store';
	import { CaretDown, Check } from 'phosphor-svelte';
	import { Progress } from '$components/ui/progress';
	import TagInput from '$components/Editor/TagInput.svelte';

    export let state: Writable<Studio.State<Studio.Type.Video>>;
    let video: NDKVideo = $state.video;
    $: $state.video = video;

    $: video.content ??= "";
    
    export let videoFile: File | undefined;

    export let done: boolean;

    let status: string | undefined;
    let uploadProgress: number | undefined;

    let videoUrl: string | undefined = video.url;

    function uploading(e: CustomEvent<{progress: number | string}>) {
        const { progress } = e.detail;

        // if (!status) {
        //     $status.push(st);
        //     console.log('status is', $status, progress);
        // }

        // if progress is a number
        if (typeof progress === 'number') {
            uploadProgress = progress;
        } else {
            status = "Uploading";
        }

        if (progress === undefined) {
            status = "Uploaded";
            setTimeout(() => {
                status = undefined;
                done = true;
            }, 1500);
        }
    }

    function uploaded() {
        status = "Uploaded";
        done = true;

        // remove from status
        // status.update((s) => s.filter((st) => st !== "Uploading video"));
        // console.log('status is', $status);

        setTimeout(() => {
            status = undefined;
        }, 1500);
    }

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }

    let contentAreaElement: HTMLTextAreaElement;

    let open = !done;
    let showTags = video.getMatchingTags("t").length > 0;
</script>

<Collapsible.Root class="my-6" bind:open>
    <Collapsible.Trigger asChild let:builder>
        <Button builders={[builder]} variant="outline" class="w-full justify-between text-muted-foreground text-lg h-auto mb-2 relative">
            <span>
                Video
            </span>
            <span class="text-sm">
                {#if done}
                    <Check class="w-4 h-4 text-green-500 inline mr-2" />
                {/if}
                {status??""}
                <CaretDown class="w-4 h-4 text-muted-foreground inline" />
            </span>
            {#if !done && uploadProgress !== undefined}
                <div class="absolute bottom-0 left-0 h-1 right-0">
                    <Progress value={uploadProgress} class="rounded-sm h-1" barClass="dark:bg-gold light:bg-foreground" />
                </div>
            {/if}
        </Button>
    </Collapsible.Trigger>
    <Collapsible.Content>
        <VideoUploader
            wrapperClass="min-h-[24rem]"
            bind:video
            bind:videoUrl
            bind:videoFile
            thumbnail={video.thumbnail}
            on:uploading={uploading}
            on:uploaded={uploaded}
        />

        <div class="flex flex-col mt-4 gap-2 border bg-secondary p-4 rounded">
            <Input
                bind:value={video.title}
                class="!bg-transparent text-2xl border-none !p-0 focus:ring-0 !text-foreground font-['InterDisplay'] font-semibold placeholder:text-muted-foreground placeholder:font-normal focus-visible:!ring-0 focus-visible:!outline-0 focus-visible:!shadow-none"
                placeholder="Title"
                on:keydown={onTitleKeyDown}
            />

            <ContentEditor
                bind:value={video.content}
                bind:element={contentAreaElement}
                toolbar={false}
                class="
                    !bg-transparent border-none rounded-lg text-foreground
                    focus:ring-0 text-opacity-60
                    text-base
                    resize-none min-h-[2rem]
                "
                placeholder="Description"
            />

            {#if !showTags}
                <Button variant="outline" size="xs" class="w-fit" on:click={() => showTags = true}>
                    Add tags
                </Button>
            {:else}
                <TagInput event={video}
                    class="
                    border-none rounded-lg text-foreground
                    "
                />
            {/if}
        </div>
    </Collapsible.Content>
</Collapsible.Root>
