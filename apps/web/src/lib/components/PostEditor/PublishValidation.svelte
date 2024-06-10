<script lang="ts">
	import { WarningItem } from './warnings.js';
	import { type, event, preview, view, status } from "$stores/post-editor";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { Warning } from "phosphor-svelte";
	import { closeModal } from '$utils/modal';
	import { slide } from "svelte/transition";
	import { Button } from '$components/ui/button/index.js';

    export let canPublish: boolean | undefined = undefined;

    export let warnings: WarningItem[] = [];

    $: {
        warnings = [];

        switch ($type) {
            case "article": {
                const article = $event as NDKArticle;
                // no title
                if (!article.title) {
                    warnings.push({
                        message: "Your article doesn't have a title",
                        showStopper: true,
                        link: {
                            text: "Fix",
                            fn: () => { $view = "edit"; closeModal(); }
                        }
                    });
                }

                // no content
                if (!article.content) {
                    warnings.push({
                        message: "Your article doesn't have any content",
                        showStopper: true,
                        link: {
                            text: "Fix",
                            fn: () => { $view = "edit"; closeModal(); }
                        }
                    });
                }

                if (!article.image && !$status.some(s => s === "Uploading image")) {
                    warnings.push({
                        message: "Would you like to add a cover image to your article?",
                        showStopper: false,
                        link: {
                            text: "Add Image",
                            fn: () => { $view = "meta"; closeModal(); }
                        }
                    });
                }

                break;
            }

            case "video": {
                const video = $event as NDKVideo;
                if (!video.url && !$status.some(s => s === "Uploading video")) {
                    warnings.push({
                        message: "The video file is not set or ready",
                        showStopper: true,
                        link: {
                            text: "Fix",
                            fn: () => { $view = "edit"; closeModal(); }
                        }
                    });
                }

                // video must have a title
                if (!video.title) {
                    warnings.push({
                        message: "Your video doesn't have a title",
                        showStopper: true,
                        link: {
                            text: "Fix",
                            fn: () => { $view = "edit"; closeModal(); }
                        }
                    });
                }

                // video should have a thumbnail
                if (!video.thumbnail && !$status.some(s => s === "Uploading thumbnail")) {
                    warnings.push({
                        message: "Your video doesn't have a thumbnail",
                        showStopper: false,
                        link: {
                            text: "Continue",
                            fn: () => { $view = "meta"; closeModal(); }
                        }
                    });
                }
                break;
            }
        }

        canPublish = !warnings.some(warning => warning.showStopper) && $status.length === 0;
    }
</script>

<div class="flex flex-col w-full">
    {#each $status as st}
        <div role="alert" class="alert justify-between" transition:slide>
            <span class="loading loading-sm text-info"></span>
            <div>
                <span class="flex-grow">{st}</span>
            </div>
        </div>
    {/each}

    {#each warnings as warning}
        <div role="alert" class="alert justify-between" transition:slide>
            <Warning class="text-info" />
            <div>
                <span class="flex-grow">{warning.message}</span>
            </div>

            {#if warning.link}
                <div>
                    <Button
                        variant={warning.showStopper ? 'accent' : 'outline'}
                        on:click={warning.link.fn}
                    >
                        {warning.link.text}
                    </Button>
                </div>
            {/if}
        </div>
    {/each}
</div>
