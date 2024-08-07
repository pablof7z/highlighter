<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { Writable } from "svelte/store";
	import { ComposerState } from ".";
	import Avatar from "$components/User/Avatar.svelte";
	import currentUser from "$stores/currentUser";

    export let state: Writable<ComposerState>;
    export let placeholder: string | undefined = undefined;
    export let minHeight = "10rem";
</script>

{#if state}
    <div class="flex flex-row gap-4">
        <Avatar user={$currentUser} size="small" />
        
        <ContentEditor
            bind:content={$state.content}
            allowMarkdown={false}
            autofocus={true}
            toolbar={false}
            {placeholder}

            class="
                text-lg
                {$$props.class??""}
            "
            style="
                min-height: {minHeight};
            "
        />
    </div>
{/if}