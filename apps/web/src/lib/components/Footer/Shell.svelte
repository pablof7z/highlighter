<script lang="ts">
	import { slide } from 'svelte/transition';
	import { Button } from "$components/ui/button";
	import { CaretUp } from "phosphor-svelte";
	import { ComponentType, createEventDispatcher, onMount, SvelteComponent } from 'svelte';
	import { Input } from '$components/ui/input';
	import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { footerMainView } from '$stores/layout';

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let mainView: string | undefined = undefined;
    export let maxHeight = "50vh";
    export let placeholder: string | undefined = "Reply";
    export let onPublish: ((content: string) => void) | undefined = undefined;
    export let collapse = () => {
        collapsed = true;
        mainView = undefined;
        dispatch("collapse");
    }

    $: mainView = $footerMainView;

    type ButtonView = {
        name: string,
        Button: ComponentType,
        View: ComponentType,
        buttonProps?: Record<string, any>
        props?: Record<string, any>
    }
    export let buttons: ButtonView[] = [];

    /**
     * Whether, when the component is mounted, it should be opened
     */
    export let openOnMount: boolean | undefined = undefined;

    const dispatch = createEventDispatcher();

    /**
     * Whether to hide the collapsed view when expanded
     */
    export let hideCollapsedView = false;

    let position = 0;
    let dragged = 0;

    function touchstart(e: TouchEvent) {
        dragging = true;
        position = e.touches[0].clientY;
    }

    function touchend() {
        dragging = false;
        position = 0;
    }

    onMount(() => {
        if (openOnMount) {
            collapsed = false;
        }
    })

    const touchmove = (e: TouchEvent) => {
        if (dragging) {
            e.preventDefault();
            dragged = e.touches[0].clientY - position;

            if (collapsed && dragged > 0) dragged = 0;
            else if (!collapsed && dragged < 0) dragged = 0;

            if (collapsed && dragged < -100) {
                collapsed = false;
            } else if (!collapsed && dragged > 100) {
                collapse()
            }
        }
    }

    export function open(view?: any | string | false) {
        if (view === false) {
            collapse();
            return;
        }
        
        collapsed = false;
        if (typeof view !== "string")
            view = "main"

        mainView = view;
    }

	function toggleCollapse() {
        if (collapsed) {
            open();
        } else {
            collapse();
        }
	}

    function onEditorFocused() {
        open('editor');
    }
    export let content = "";

    function cancelEditor() {
        open(false);
        content = "";
    }

    function editorPublish() {
        content = content.trim();
        if (content.length === 0) return;
        onPublish?.(content);
        open(false);
        content = "";
    }

    let buttonViewNames = new Set<string>();

    $: {
        buttonViewNames = new Set(buttons.map(b => b.name));
    }
</script>

<div
    on:touchstart={touchstart}
    on:touchend={touchend}
    on:touchmove={touchmove}
    style="
    {
        (dragging) ? "transform: translateY(" + dragged/50 + "px);" : ""
    }"
    class="
        footer-shell
        max-w-[var(--content-focused-width)] mx-auto
        max-sm:backdrop-blur-lg
        overflow-clip
        max-sm:p-2 max-sm:px-2
        max-sm:right-0 sm:right-[360px]
        rounded-t-3xl py-3 h-auto 
        flex flex-col justify-between items-center
        {$$props.class??""}
    ">
    {#if !hideCollapsedView || collapsed}
        <div class="flex flex-row justify-between {align} w-full gap-2" transition:slide={{axis: 'y'}}>
            {#each buttons as button}
                <svelte:component this={button.Button} on:click={() => open(button.name)} {...button.buttonProps} />
            {/each}
            {#if mainView === 'editor' && onPublish}
                <div class="flex flex-row justify-between {align} w-full gap-2">
                    <Button variant="outline" on:click={cancelEditor}>
                        Cancel
                    </Button>
                    
                    <Button on:click={editorPublish}>
                        Publish
                    </Button>
                </div>
            {:else}
                <div class="flex flex-row justify-between {align} w-full gap-2">
                    <slot {collapsed} {open} {collapse} {mainView} />

                    {#if collapsed && onPublish}
                        <Input
                            {placeholder}
                            class="text-lg bg-background/50 rounded px-4 w-full text-muted-foreground"
                            on:focus={onEditorFocused}
                            bind:value={content}
                        />
                    {/if}
                </div>
            {/if}
            <Button
                class="
                    flex-none w-10 h-10 p-2
                    bg-opacity-50
                    transform-gpu transition-transform duration-300
                    {!collapsed ? 'rotate-180' : ''}
                "
                on:click={toggleCollapse}
            >
                <CaretUp class="w-full h-full" weight="bold" />
            </Button>
        </div>
    {/if}

    {#if !collapsed}
        <div class="flex flex-col gap-2 w-full mt-4 overflow-y-auto scrollbar-hide" transition:slide style="max-height: {maxHeight}">
            {#each buttons as button}
                {#if mainView === button.name}
                    <svelte:component this={button.View} {open} on:close={() => open(false)} {...button.props} />
                {/if}
            {/each}
            {#if mainView === 'editor'}
                <div class="bg-background/50 rounded p-4 text-lg overflow-y-auto flex flex-col">
                    <ContentEditor
                        autofocus={true}
                        bind:content
                        on:submit={editorPublish}
                        enableMarkdown={false}
                        toolbar={false}
                        class="text-lg min-h-[20vw]"
                        {placeholder}
                    />
                </div>
            {:else if !buttonViewNames.has(mainView)}
                <slot name="main" {open} />
            {/if}
        </div>
    {/if}
</div>
