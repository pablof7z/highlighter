<script lang="ts">
    import { draggable, type DragOptions } from '@neodrag/svelte';
	import { onMount, SvelteComponent } from 'svelte';

    type Option = {
        icon: SvelteComponent;
        cb: () => void;
    };

    export let leftOptions: Option[] = [];
    export let rightOptions: Option[] = [];
    export let handle: string | undefined = undefined;

    let position = { x: 0, y: 0 };
    let positionX = 0;

    let element: HTMLElement;

    let viewportWidth = window.innerWidth;
    let triggerActionRequirement = viewportWidth / 3;

    if (triggerActionRequirement > 100) { triggerActionRequirement = 100; }

    // function onDragStart({ offsetX, offsetY }) {
    //     // disable selection in the element
    //     document.body.style.userSelect = 'none';

    //     // disable click events on the element
    //     element.style.pointerEvents = 'none';

    //     // set z-index to 9999
    //     element.style.zIndex = '9999';

    //     // enable vertical scrolling on touch devices so that the user can scroll the page
    //     element.style.touchAction = 'pan-y';


        
    // }

    // function onDrag({ offsetX, offsetY }) {
    //     if (offsetX > triggerActionRequirement) {
    //         offsetX = triggerActionRequirement;
    //     } else if (offsetX < -triggerActionRequirement) {
    //         offsetX = -triggerActionRequirement;
    //     }

    //     position = { x: offsetX, y: 0 };
    // }

    // const resetPosition = (p = 0) => position = { x: p, y: 0 };

    // function onDragEnd({ offsetX, offsetY }) {
    //     document.body.style.userSelect = 'auto';
    //     element.style.pointerEvents = 'auto';
    //     element.style.zIndex = 'auto';
        
    //     const movingLeft = offsetX > 0;

    //     if (movingLeft) {
    //         const exactlyOneOption = leftOptions.length === 1;
    //         const somethingShouldTrigger = offsetX >= triggerActionRequirement;

    //         if (exactlyOneOption && somethingShouldTrigger) {
    //             leftOptions[0].cb();
    //             resetPosition();
    //         } else if (somethingShouldTrigger) {
    //             // set position so that all options are visible
    //             const lastOption = leftOptions[leftOptions.length - 1];
    //             const pos = triggerActionRequirement * leftOptions.length;
    //             resetPosition(pos);
    //         } else {
    //             resetPosition();
    //         }
    //     } else {
    //         const exactlyOneOption = rightOptions.length === 1;
    //         const somethingShouldTrigger = offsetX <= -triggerActionRequirement;

    //         if (exactlyOneOption && somethingShouldTrigger) {
    //             rightOptions[0].cb();
    //             resetPosition();
    //         } else if (somethingShouldTrigger) {
    //             // set position so that all options are visible
    //             const lastOption = rightOptions[rightOptions.length - 1];
    //             const pos = -triggerActionRequirement * rightOptions.length;
    //             resetPosition(pos);
    //         } else {
    //             resetPosition();
    //         }
    //     }
    // }

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
    
    let dragging = false;
    let startX = 0;
    let startY = 0;

    $: if (element) {
        if (positionX !== 0) {
            element.style.transform = `translateX(${positionX}px)`;
        } else {
            element.style.transform = "";
        }
    }
    
    function onTouchStart(event) {
        dragging = true;
        startX = event.touches[0].clientX;
        startY = event.touches[0].clientY;
    }

    function isValidDragging(offsetX, offsetY) {
        const goingLeft = offsetX > 0;
        let moduloDiff = Math.abs(offsetX) % Math.abs(offsetY);

        if (moduloDiff > 10) {
            offsetX = offsetX - (moduloDiff * 0.1);
        }

        if (goingLeft && offsetY > offsetX) {
            positionX = 0;
            return false;
        } else if (!goingLeft && offsetY < offsetX) {
            positionX = 0;
            return false;
        }

        return true;
    }

    const threshold = 20; // don't render the options if the user is scrolling

    function onTouchMove(event) {
        if (dragging) {
            let xOffset = event.touches[0].clientX - startX;
            let yOffset = event.touches[0].clientY - startY;
            const goingLeft = xOffset > 0;
            
            if (Math.abs(xOffset) < threshold) {
                positionX = 0;
                return;
            }

            if (!isValidDragging(xOffset, yOffset)) {
                return;
            }
            
            positionX = xOffset;

            // the larger the difference is in the y direction, the more x trends towards 0

            // limit the x offset to the triggerActionRequirement
            if (goingLeft && xOffset > triggerActionRequirement) {
                xOffset = triggerActionRequirement;
            } else if (!goingLeft && xOffset < -triggerActionRequirement) {
                xOffset = -triggerActionRequirement;
            }

            positionX = xOffset;
        }
    }

    function onTouchEnd(event) {
        dragging = false;
        const offsetX = event.changedTouches[0].clientX - startX;
        const offsetY = event.changedTouches[0].clientY - startY;
        const goingLeft = offsetX > 0;

        if (!isValidDragging(offsetX, offsetY)) {
            return;
        }

        if (goingLeft) {
            const exactlyOneOption = leftOptions.length === 1;
            const somethingShouldTrigger = offsetX >= triggerActionRequirement;

            if (exactlyOneOption && somethingShouldTrigger) {
                leftOptions[0].cb();
                positionX = 0;
            } else if (somethingShouldTrigger) {
                // set position so that all options are visible
                const lastOption = leftOptions[leftOptions.length - 1];
                const pos = triggerActionRequirement * leftOptions.length;
                positionX = pos;
            } else {
                positionX = 0;
            }
        } else {
            const exactlyOneOption = rightOptions.length === 1;
            const somethingShouldTrigger = offsetX <= -triggerActionRequirement;

            if (exactlyOneOption && somethingShouldTrigger) {
                rightOptions[0].cb();
                positionX = 0;
            } else if (somethingShouldTrigger) {
                // set position so that all options are visible
                const lastOption = rightOptions[rightOptions.length - 1];
                const pos = -triggerActionRequirement * rightOptions.length;
                positionX = pos;
            } else {
                positionX = 0;
            }
        }
    }
</script>

<div class="w-full relative">
    <div class="absolute left-0 top-0 bottom-0 flex flex-row overflow-clip" style={`
        width: ${positionX}px;
    `}>
        {#each leftOptions as opt, i}
            <div
                class="min-w-[5rem] min-h-10 h-full bg-accent2 text-white absolute left-0 top-0 bottom-0 flex flex-row items-center overflow-clip"
                style={`
                    opacity: ${0 + (positionX / triggerActionRequirement)};
                    width: ${triggerActionRequirement}px;
                    max-width: 5px !important
                `}
            >
                    <svelte:component this={opt.icon} class="m-4 w-32 h-32" />
            </div>
        {/each}
    </div>
    <div style="
        touch-action: pan-y;
    " bind:this={element} on:touchstart={onTouchStart} on:touchmove={onTouchMove} on:touchend={onTouchEnd}>
        <slot />
    </div>
    <!-- <div
        style="touch-action: pan-y;"
        bind:this={element}
        use:draggable={{
            position,
            onDragStart,
            onDrag,
            onDragEnd,
            axis: 'x'
        }}
    >
        <slot />
    </div> -->
    <div class="absolute right-0 top-0 bottom-0 flex flex-row overflow-clip" style={`
        width: ${-positionX}px;
    `}>
        {#each rightOptions as opt, i}
            <div
                class="min-w-[5rem] min-h-10 h-full bg-green-700 absolute right-0 top-0 bottom-0 flex flex-row items-center overflow-clip"
                style={`
                    opacity: ${0 - (positionX / triggerActionRequirement)};
                    width: ${triggerActionRequirement}px;
                    max-width: 5px !important
                `}
            >
                    <svelte:component this={opt.icon} class="m-4 w-32 h-32" />
            </div>
        {/each}
    </div>
</div>
