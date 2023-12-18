<script lang="ts">
	import { ndk, newToasterMessage, uploadToSatelliteCDN } from "@kind0/ui-common";
    import { createEventDispatcher } from "svelte";

    export let url: string;

    const dispatch = createEventDispatcher();
    let uploadProgress: number | undefined;
    let done: boolean | undefined;
    let fileUpload: HTMLInputElement;

    async function handleFileUpload() {
        if (!fileUpload?.files) return;

        const file = fileUpload.files[0];
        if (!file) return;

        const xhr = await uploadToSatelliteCDN($ndk, file.type);
        xhr.upload.addEventListener('progress', (event) => {
            console.log(event.lengthComputable);
            if (event.lengthComputable) {
                uploadProgress = (event.loaded / event.total) * 100;
            }
        });

        done = false;

        xhr.addEventListener('load', async () => {
            if (xhr.status === 200) {
                const json = JSON.parse(xhr.responseText);
                url = json.url;
                done = true;

                dispatch("uploaded", { url });
            } else if (xhr.status === 402) {
                newToasterMessage("Payment required to upload to your Satellite CDN", "error");
                return;
            } else {
                console.error(`Failed to upload image: ${xhr.statusText}`);
                newToasterMessage("Failed to upload image: " +xhr.status, "error")
            }
        });

        xhr.addEventListener('error', (e) => {
            console.log(e);
            console.log(xhr)
            console.error(`Failed to upload image: ${xhr.statusText}`);
            newToasterMessage(`Failed to upload image: ${xhr.statusText}`, "error");
        });

        xhr.send(file);
    }
</script>

<!-- svelte-ignore a11y-label-has-associated-control -->
<label class="hover:opacity-80 cursor-pointer {$$props.wrapperClass??""}">
    {#if url}
        <!-- svelte-ignore a11y-missing-attribute -->
        <img
            src={url}
            class={$$props.class??""}
            class:animate-pulse={done === false}
        />
    {:else}
        <slot />
    {/if}
    {#if uploadProgress !== undefined && !done}
        <div class="h-2 bg-accent top-0 absolute z-30 left-0 transition-all duration-300" style="width: {uploadProgress}%;"></div>
        <div class="h-2 bg-base-300 w-full top-0 absolute z-20"></div>
    {/if}
    <input type="file" bind:this={fileUpload} id="fileUploader" accept="image/*" class="hidden" on:change={handleFileUpload}>
</label>
