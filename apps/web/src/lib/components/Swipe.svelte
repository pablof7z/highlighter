<script lang="ts">
    import { draggable, type DragOptions } from '@neodrag/svelte';
	import { Chat } from 'phosphor-svelte';
	import { onMount, SvelteComponent } from 'svelte';

    type Option = {
        icon: SvelteComponent;
        cb: () => void;
    };

    export let leftOptions: Option[] = [];

    let position = { x: 0, y: 0 };

    let element: HTMLElement;

    let viewportWidth = window.innerWidth;
    let triggerActionRequirement = viewportWidth / 3;

    if (triggerActionRequirement > 100) { triggerActionRequirement = 100; }

    function onDragStart({ offsetX, offsetY }) {
        // disable selection in the element
        document.body.style.userSelect = 'none';

        // disable click events on the element
        element.style.pointerEvents = 'none';

        // set z-index to 9999
        element.style.zIndex = '9999';
    }

    function onDrag({ offsetX, offsetY }) {
        if (offsetX > triggerActionRequirement) {
            offsetX = triggerActionRequirement;
        }

        position = { x: offsetX, y: offsetY };
    }

    const resetPosition = (position = 0) => position = { x: position, y: 0 };

    function onDragEnd({ offsetX, offsetY }) {
        document.body.style.userSelect = 'auto';
        element.style.pointerEvents = 'auto';
        element.style.zIndex = 'auto';
        
        const movingLeft = offsetX > 0;

        if (movingLeft) {
            const exactlyOneOption = leftOptions.length === 1;
            const somethingShouldTrigger = offsetX >= triggerActionRequirement;

            if (exactlyOneOption && somethingShouldTrigger) {
                leftOptions[0].cb();
                resetPosition();
            } else if (somethingShouldTrigger) {
                // set position so that all options are visible
                const lastOption = leftOptions[leftOptions.length - 1];
                const pos = triggerActionRequirement * leftOptions.length;
                resetPosition(pos);
            } else {
                resetPosition();
            }
        }
    }

            // if (offsetX < triggerActionRequirement) {
                // return to original position
                // element.classList.add('animate-transform', 'duration-100');
                // element.style.transform = 'translateX(0)';
                // setTimeout(() => {
                    // element.classList.remove('animate-transform', 'duration-100');
                    // position = { x: 0, y: offsetY };
                // }, 100);
            // } else {
            //     offset = triggerActionRequirement;
            // }
</script>

<div class="w-full relative h-64">
    <div class="absolute left-0 top-0 bottom-0 flex flex-row overflow-clip" style={`
        width: ${position.x}px;
    `}>
        {#each leftOptions as opt, i}
            <div
                class="min-w-[5rem] min-h-10 h-full bg-base-300 absolute left-0 top-0 bottom-0 flex flex-row items-center overflow-clip"
                style={`
                    background-opacity: ${1 - (position.x / triggerActionRequirement)};
                    width: ${triggerActionRequirement}px;
                    max-width: 5px !important
                `}
            >
                    <svelte:component this={opt.icon} class="m-4 w-32 h-32" />
            </div>
        {/each}
    </div>
    <div
        bind:this={element}
        use:draggable={{
            position,
            axis: 'x',
            onDragStart,
            onDrag,
            onDragEnd,
        }}
    >
    {viewportWidth}
    triggerActionRequirement = {triggerActionRequirement}
        {JSON.stringify(position)}
        <slot />
    </div>
</div>