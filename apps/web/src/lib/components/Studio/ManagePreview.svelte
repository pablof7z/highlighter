<script lang="ts">
	import { getAuthorUrl } from '$utils/url';
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { Writable, Readable, get, derived } from "svelte/store";
	import { Globe } from "phosphor-svelte";
    import * as Studio from "$components/Studio";
    import * as Card from "$lib/components/ui/card/index.js";
    import * as Collapsible from "$lib/components/ui/collapsible/index.js";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import currentUser from '$stores/currentUser';

    export let state: Writable<Studio.State<Studio.PreviewableTypes>>;

    let update = 0;
        
    if ($state.previewAppend === undefined) {
        $state.previewAppend = Studio.defaultPreviewFooter;

        if ($currentUser)
            getAuthorUrl($currentUser).then(url => {
                if (url) {
                    $state.previewAppend += "\n\n" + "https://highlighter.com" + url;
                    update = Date.now();
                }
            })
    }
</script>

<div class="flex flex-col gap-6 py-6 responsive-padding">
    <Card.Root>
        <Card.Header>
            <Card.Title>Preview</Card.Title>
            <Card.Description>
                Allow non-members to preview this post.
            </Card.Description>
        </Card.Header>

        <Card.Content>
            <div class="border flex flex-col divide-y divide-border rounded">
                <Checkbox bind:value={$state.withPreview} class="p-3 border rounded">
                    <Globe class="w-10 h-10" slot="icon" />

                    <div class="flex flex-row gap-2 items-center">
                        
                        <div class="flex flex-col items-start gap-0 5">
                            <b class="text-lg">Public preview</b>
                            <div class="text-muted-foreground text-sm">
                                {#if $state.withPreview}
                                    Non-members will see a preview of this post.
                                {:else}
                                    Non-members will not know this post exists.
                                {/if}
                            </div>
                        </div>
                    </div>

                    <!-- <Button
                        variant="outline"
                        slot="button"
                        class="{ $state.withPreview ? "" : "hidden" }"
                    >
                        Edit Preview
                    </Button> -->
                </Checkbox>
            </div>
        </Card.Content>
    </Card.Root>

    <Card.Root>
        <Collapsible.Root open={true}>
            <Collapsible.Trigger>
                <Card.Header class="text-left">
                    <Card.Title>Call-to-action</Card.Title>
                    <Card.Description>
                        Invite readers to join your community to access your content.
                    </Card.Description>
                </Card.Header>
            </Collapsible.Trigger>
            <Collapsible.Content>
                <Card.Content>
                    {#key update}
                        <ContentEditor
                            bind:content={$state.previewAppend}
                            toolbar={false}
                            class="bg-secondary p-4 rounded h-32"
                            placeholder="Join our community to access the full post..."
                        />
                    {/key}
                    <div class="text-xs text-muted-foreground my-2">
                        This will be displayed at the end of the preview to encourage readers to join your community.
                    </div>
                </Card.Content>
            </Collapsible.Content>
        </Collapsible.Root>
    </Card.Root>
    
</div>
