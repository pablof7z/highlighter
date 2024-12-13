<script lang="ts">
    import type { PostState } from "../../state.svelte";
    import { Image } from "lucide-svelte";
    import UploadButton from "@/components/buttons/UploadButton.svelte";
    import { cn } from "@/utils";
	import type { ButtonProps } from "@/components/ui/button";
	import type { Snippet } from "svelte";

    type Props = {
		postState: PostState;
        class?: string;
        variant?: ButtonProps["variant"];
        imgProps?: Record<string, any>;
        children?: () => Snippet;
	}

	const {
        postState = $bindable(),
        class: className = "",
        variant = "ghost",
        imgProps = {},
        children
    }: Props = $props();
</script>

<UploadButton
    {variant}
    class={cn("flex flex-col items-center justify-center p-0 group relative overflow-clip", className)}
    onUploaded={(url, mediaEvent) => {
        postState.image = url;
    }}
>
    {#if !postState.image}
        {#if children}
            {@render children()}
        {:else}
            <Image class="!w-8 !h-8 text-foreground/50" />
        {/if}
    {:else}
        <div class="w-auto h-auto group-hover:opacity-20 transition-opacity duration-300">
            <img src={postState.image} alt="" class="w-32 h-32 object-cover rounded-lg" {...imgProps} />
        </div>
        <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <Image class="!w-12 !h-12 text-foreground" />
        </div>
    {/if}
</UploadButton>