<script lang="ts">
	import { Button } from "$components/ui/button";
	import { CaretUp } from "phosphor-svelte";
	import { ComponentType, createEventDispatcher, onMount, SvelteComponent } from 'svelte';
	import { Input } from '$components/ui/input';
	import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { footerMainView } from '$stores/layout';
    import { Keyboard } from '@capacitor/keyboard';
	import { isMobileBuild } from '$utils/view/mobile';
	import { ButtonView } from ".";

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let mainView: string | undefined = undefined;
    const initialMainView = mainView;
    export let maxHeight = "50vh";
    export let visibleHeight = 60;
    export let placeholder: string | undefined = "Reply";
    export let onPublish: ((content: string) => void) | undefined = undefined;
    export let collapse = () => {
        collapsed = true;
        mainView = undefined;
        dispatch("collapse");
    }

    $: mainView = $footerMainView;

    let kHeight = 0;

    if (isMobileBuild()) {
        Keyboard.addListener("keyboardWillHide", () => {
            kHeight = 0;
        });
        
        Keyboard.addListener('keyboardWillShow', info => {
            const { keyboardHeight } = info;
            kHeight = keyboardHeight;

            // el.style.setProperty('transform', 'translate3d(0, -' + keyboardHeight + 'px, 0)');
        });
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
        el.style.setProperty('transition', 'transform 0.3s');
        setTimeout(() => {
            dragged = 0;
        }, 100);
        setTimeout(() => {
            el.style.setProperty('transition', 'none');
        }, 300);
    }

    onMount(() => {
        if (openOnMount) {
            collapsed = false;
            mainView = initialMainView;
        }
    })

    const touchmove = (e: TouchEvent) => {
        if (dragging) {
            dragged = e.touches[0].clientY - position;

            if (collapsed && dragged > 0) dragged = 0;
            else if (!collapsed && dragged < 0) dragged = 0;

            el.style.setProperty('transform', 'translate3d(0, ' + dragged + 'px, 0)');

            if (collapsed && dragged < -100) {
                collapsed = false;
            } else if (!collapsed && dragged > 100) {
                el.style.setProperty('transform', 'translate3d(0, 0, 0)');
                collapse();
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

    let el: HTMLDivElement;
</script>

<div
    bind:this={el}
    on:touchstart|passive={touchstart}
    on:touchend={touchend}
    on:touchmove|passive={touchmove}
    class="
        footer-shell
        max-w-[var(--content-focused-width)] mx-auto
        max-sm:backdrop-blur-lg
        overflow-clip
        !pb-[calc(var(--safe-area-inset-bottom)+0.5rem)]
        max-sm:p-2 max-sm:px-3
        max-sm:right-0 sm:right-[360px]
        rounded-t-3xl py-3 h-auto 
        flex flex-col justify-between items-center
        {$$props.class??""}
    ">
    {#if !hideCollapsedView || collapsed}
        <div class="flex flex-row justify-between {align} w-full gap-2">
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
        <div
            class:pt-4={!hideCollapsedView}
            class="flex flex-col gap-2 w-full overflow-y-auto scrollbar-hide transition-all duration-1000"
            style="max-height: {maxHeight}"
        >
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
