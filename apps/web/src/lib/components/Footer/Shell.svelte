<script lang="ts">
	import { Button } from "$components/ui/button";
	import { CaretUp, X } from "phosphor-svelte";
	import { createEventDispatcher, onMount, SvelteComponent } from 'svelte';
	import ContentEditor from '$components/Forms/ContentEditor.svelte';
	import { footerMainView, layout } from '$stores/layout';
	import type { FooterView } from ".";
	import { Writable } from "svelte/store";
	import { slide } from "svelte/transition";

    export let collapsed = true;
    export let dragging = false;
    export let align = "items-center";
    export let mainView: string | undefined = undefined;
    const initialMainView = mainView;
    export let maxHeight = "50vh";
    export let visibleHeight = 60;
    export let padding = "calc(var(--safe-area-inset-bottom) + 0.5rem)";
    export let placeholder: string | undefined = "Reply";
    export let onPublish: ((content: string) => void) | undefined = undefined;
    export let collapse = () => {
        collapsed = true;
        $footerMainView = mainView = activeView = undefined;
        dispatch("collapse");
    }

    $: if ($footerMainView !== mainView) {
        open($footerMainView);
    }
    
    export let views: FooterView[] = [];

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
        if (view === false || view === undefined) {
            collapse();
            return;
        }
        
        collapsed = false;
        if (typeof view !== "string")
            view = "main"

        mainView = view;
        $footerMainView = view;
    }

	function toggleCollapse() {
        if (collapsed) {
            open('main');
        } else {
            collapse();
        }
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

    let viewNames = new Set<string>();

    $: if (views) {
        viewNames = new Set(views.map(b => b.name));
    }

    let el: HTMLDivElement;

    // record height of el height as footer-height
    $: if (el && (collapsed || !collapsed)) {
        document.documentElement.style.setProperty('--footer-height', el.clientHeight + 'px');
    }

    let activeView: FooterView | undefined;
    let viewStores: Record<string, Writable<any>> = {};
    
    $: if (mainView && viewNames.has(mainView)) {
        activeView = views.find(v => v.name === mainView);
    }

    $: for (const view of views) {
        if (!viewStores[view.name] && view.createStateStore) {
            viewStores[view.name] = view.createStateStore();
        }
    }

    $: if (!collapsed && activeView && !activeView.View) {
        collapsed = true;
    }

</script>

<div
    bind:this={el}
    on:touchstart|passive={touchstart}
    on:touchend={touchend}
    on:touchmove|passive={touchmove}
    class="
        footer-shell
        max-sm:backdrop-blur-lg
        overflow-clip
        max-sm:p-2 max-sm:px-3
        max-sm:right-0 sm:right-[360px]
        py-3
        flex flex-col justify-between items-center
        !pb-[calc(var(--bottom-padding)+0.5rem)]

        { !$layout.sidebar && !$layout.fullWidth ? "max-w-[var(--content-focused-width)] mx-auto" : "" }
        
        {$$props.class??""}
    ">
    {#if activeView}
        <div class="flex flex-row justify-between {align} w-full gap-2">
            {#if activeView.Toolbar}
                <svelte:component this={activeView.Toolbar} {open} stateStore={viewStores[mainView]} {...activeView.props} {mainView} />
            {:else}
                <div class="grow"></div>
            {/if}

            <Button
                size="icon"
                variant="secondary"
                class="
                rounded-full
                    flex-none w-10 h-10 p-2
                    transform-gpu transition-transform duration-300
                    {!collapsed ? 'rotate-180' : ''}
                "
                on:click={() => open(false)}
            >
                <X class="w-full h-full" weight="bold" />
            </Button>
        </div>
    {:else if !hideCollapsedView || collapsed}
        <div class="flex flex-row justify-between {align} w-full gap-2">
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
                {#if views}
                    {#each views as view}
                        {#if view.Button}
                            <svelte:component
                                this={view.Button}
                                on:click={() => open(view.name)}
                                {...view.props}
                                {...view.buttonProps}
                                {open}
                                {mainView}
                                stateStore={viewStores[view.name]}
                            />
                        {/if}
                    {/each}
                {/if}
                <slot {collapsed} {open} {collapse} {mainView} />
            {/if}
            <Button
                size="icon"
                variant="secondary"
                class="
                rounded-full
                    flex-none w-10 h-10 p-2
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
            style="max-height: {maxHeight};"
        >
            <div class="flex flex-col">
                {#if activeView?.View}
                    <svelte:component
                        this={activeView.View}
                        bind:hideCollapsedView
                        {open}
                        on:close={() => open(false)}
                        {...$$props}
                        {...activeView.props}
                        stateStore={viewStores[mainView]}
                    />
                {:else if mainView === 'editor'}
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
                {:else}
                    <slot name="main" {open} />
                {/if}
            </div>
        </div>
    {/if}
</div>
