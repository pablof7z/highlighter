<script lang="ts">
	import { Button } from "$components/ui/button";
	import { activeBlossomServer } from "$stores/session";
	import { Uploader } from "$utils/upload";
	import { Microphone, PaperPlaneTilt, Play, Stop, Trash } from "phosphor-svelte";
	import { createEventDispatcher } from "svelte";

    
    const dispatch = createEventDispatcher();

    export let active = false;
    
    export let recording = false;
    export let recorded = false;
    export let progress: number | undefined = undefined;
    export let duration: number | undefined = undefined;
    export let playing = false;
    export let uploading = false;

    export let blobUrl: string | undefined = undefined;

    $: if (recording || uploading || recorded) {
        active = true;
    } else {
        active = false;
    }

    let mediaRecorder: MediaRecorder | undefined;
    let blob: Blob | undefined;
    let contentType: string | undefined;

    function buttonPressed() {
        if (recording) {
            stop()
        } else if (recorded) {
            upload()
            uploading = true;
        } else {
            record()
        }
    }

    let base64data: string | ArrayBuffer | null = null;

    async function record() {
        recording = true
        
        duration = 0;

        const updateDuration = setInterval(() => {
            if (recording) {
                if (duration !== undefined) duration++;
            } else {
                clearInterval(updateDuration);
            }
        }, 1000)

        const stream = await navigator.mediaDevices.getUserMedia({ video: false, audio: true })
        mediaRecorder = new MediaRecorder(stream)
        const chunks: Blob[] = []

        mediaRecorder.ondataavailable = (e) => {
            console.log("recording data")
            chunks.push(e.data)
        }

        mediaRecorder.onstop = () => {
            console.log("recording stopped")
            blob = new Blob(chunks, { type: "audio/ogg; codecs=opus" })
            blobUrl = URL.createObjectURL(blob)
            // base64 encode blob
            const reader = new FileReader();
            reader.onload = () => {
                base64data = reader.result;
                console.log(base64data);
            };

            reader.readAsDataURL(blob);

            console.log(blobUrl)

            contentType = blob.type;
            // make sure we only have a content type
            if (contentType.indexOf(";") !== -1) {
                contentType = contentType.split(";")[0];
            }
        }

        mediaRecorder.start()
    }

    function reset() {
        recording = false
        recorded = false
        playing = false
        uploading = false
        progress = undefined
        duration = undefined
        blobUrl = undefined
    }

    function upload() {
        const uploader = new Uploader(blob, $activeBlossomServer);
        uploader.onProgress = (p) => progress = p;
        uploader.onUploaded = (url: string) => {
            const mediaEvent = uploader.mediaEvent();
            mediaEvent.removeTag("m")
            mediaEvent.tags.push(["m", contentType]);
            url = url.replace(/\.webm/, ".ogg");
            console.log("uploaded", url, mediaEvent);
            dispatch('uploaded', { url, mediaEvent });
            reset();
        };

        uploader.start();
    }

    function stop() {
        recording = false
        recorded = true

        console.log("stopping recording")

        mediaRecorder?.stop()
    }
</script>

<div
    class="flex flex-row gap-4 items-center"
    class:w-full={active}
>
    <Button
        {...$$props.buttonProps}
        on:click={buttonPressed}
    >
        {#if progress}
            <div class="w-4 h-4">
                <progress value={progress} max="100" />
            </div>
        {:else if recorded && !uploading}
            <PaperPlaneTilt class="w-4 h-4" weight="fill" />
        {:else if !recording}
            <Microphone class="w-4 h-4" weight="bold" />
        {:else}
            <Stop class="w-4 h-4" weight="fill" />
        {/if}
    </Button>

    {#if !recording && recorded && !uploading}
        <Button
            {...$$props.buttonProps}
            variant="outline"
            on:click={() => playing = !playing}
        >
            {#if !playing}
                <Play class="w-4 h-4" weight="bold" />
            {:else}
                <Stop class="w-4 h-4" weight="fill" />
            {/if}
        </Button>

        {#if playing && base64data}
            <audio src={base64data}
                autoplay
                on:ended={() => playing = false}
            />
        {/if}

        {#if recorded && !uploading}
            <div class="grow"></div>

            <Button
                {...$$props.buttonProps}
                variant="destructive"
                on:click={reset}
            >
                <Trash class="w-4 h-4" weight="fill" />
            </Button>
        {/if}
    {/if}

    {#if recording}
        <!-- Show duration in MM:SS -->
        {#key duration}
            <div class="text-sm">
                {#if duration}
                    {Math.floor(duration / 60)}:{duration % 60 < 10 ? "0" : ""}{duration % 60}
                {:else}
                    0:00
                {/if}
            </div>
        {/key}
    {/if}
</div>