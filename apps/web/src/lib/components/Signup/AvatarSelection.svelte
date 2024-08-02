<script lang="ts">
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Button } from "$components/ui/button";
	import { skeletonAvatars } from "$utils/login";
	import { NDKPrivateKeySigner } from "@nostr-dev-kit/ndk";
	import { PlusCircle } from "phosphor-svelte";

    const signer = NDKPrivateKeySigner.generate();
    const avatars = skeletonAvatars;
    export let acatar = avatars[Math.floor(Math.random() * avatars.length)];
    
    function onUpload(e) {
        acatar = e.detail.url;
        avatars.push(e.detail.url);
    }
</script>

<div class="flex flex-col items-center gap-2">
    <img src={acatar} class="w-24 h-24 rounded-full ring-2 border-4 border-transparent object-cover " />
            
    <div class="flex flex-row gap-4 items-center">
        {#each skeletonAvatars as src}
            <button
                on:click={() => acatar = src}
            >
                <img
                    {src}
                    class="
                        w-24 h-24 rounded-full
                        ring-2
                        object-cover
                        border-4 border-transparent
                        transition-all duration-500 avatar
                        {src === acatar ? 'selected' : ''}
                    "
                />
            </button>
        {/each}
        <BlossomUpload {signer} on:uploaded={onUpload}>
            <button class="w-10 h-10 p-0">
                <PlusCircle class="w-full h-full text-muted-foreground" />
            </button>
        </BlossomUpload>
    </div>
</div>


<style lang="postcss">
    .field {
        @apply flex flex-col gap-2;
    }

    label {
        @apply text-foreground text-lg;
    }

    img.avatar {
        @apply rounded-full w-8 h-8 opacity-40 transition-all duration-500;
        @apply ring-foreground/50;
        @apply hover:opacity-80;
    }
</style>