<script lang="ts">
    import { createEventDispatcher, onMount } from 'svelte';
	import { appMobileView } from '$stores/app';
	import { isMobileBuild } from '$utils/view/mobile';
	import { NavigationOption } from '../../app';

    const dispatch = createEventDispatcher();

    export let leftOptions: NavigationOption[] = [];
    export let rightOptions: NavigationOption[] = [];
    // export let preview: boolean = false;

    // onMount(() => {
    //     if (preview) {
    //         setTimeout(() => {
    //             element.style.transition = "all 0.5s";
    //             leftWrapper.style.transition = "all 0.3s";
    //             goingLeft = true;
    //             updatePosition(100);
    //         }, 1500);

    //         setTimeout(() => {
    //             goingLeft = false;
    //             updatePosition(0);
    //         }, 2500);

    //         setTimeout(() => {
    //             element.style.transition = "";
    //         }, 3000);
    //     }
    // })

    let positionX = 0;

    let element: HTMLElement;
    let leftWrapper: HTMLElement;

    let viewportWidth = window.innerWidth;
    let triggerActionRequirement = viewportWidth / 4;

    if (triggerActionRequirement > 100) { triggerActionRequirement = 100; }

    // Is the user dragging the element?
    let dragging: boolean | undefined = undefined;

    // The x position of the touch start
    let startX = 0;

    // The y position of the touch start
    let startY = 0;

    let absOffsetX = 0;

    // Is the user swiping left?
    let goingLeft = false;

    let leftOptionWidth = 0;
    let rightOptionWidth = 0;

    // Whether one of the sides is fully opened
    let fullyOpened = false;

    $: if (element) {
        if (positionX !== 0) {
            element.style.transform = `translateX(${positionX}px)`;
        } else {
            element.style.transform = "";
        }
    }

    const maxSwipe = {
        left: leftOptions.length * triggerActionRequirement,
        right: rightOptions.length * triggerActionRequirement
    }

    function onTouchStart(event: TouchEvent) {
        startX = event.touches[0].clientX - positionX;
        startY = event.touches[0].clientY;

        dragging = undefined;
    }

    function isValidDragging(offsetX: number, offsetY: number) {
        let moduloDiff = Math.abs(offsetX) % Math.abs(offsetY);

        if (moduloDiff > 10) {
            offsetX = offsetX - (moduloDiff * 0.1);
        }

        if (goingLeft && offsetY > offsetX) {
            updatePosition(0);
            return false;
        } else if (!goingLeft && offsetY < offsetX) {
            updatePosition(0);
            return false;
        }

        return true;
    }

    const threshold = 30; // don't render the options if the user is scrolling

    function onTouchMove(event: TouchEvent) {
        let xOffset = event.touches[0].clientX - startX;
        let yOffset = event.touches[0].clientY - startY;

        // if we've already determined that this is a scroll, don't do anything
        if (dragging === false) return;
        
        if (dragging === undefined) {
            // detect if this is dragging or scrolling
            if (Math.abs(yOffset) > threshold) {
                dragging = false;
                return;
            }

            if (Math.abs(xOffset) > threshold) {
                dragging = true;
            }
        }
        
        goingLeft = xOffset > 0;
        absOffsetX = Math.abs(xOffset);
        
        if (absOffsetX < threshold) {
            positionX = 0;
            return;
        }

        if (!isValidDragging(xOffset, yOffset)) {
            return;
        }

        // event.preventDefault();

        // limit the x offset to the triggerActionRequirement
        updatePosition(xOffset);
    }

    function updatePosition(xOffset: number) {
        absOffsetX = Math.abs(xOffset);
        if (goingLeft && absOffsetX > maxSwipe.left) {
            absOffsetX = maxSwipe.left;
        } else if (!goingLeft && absOffsetX > maxSwipe.right) {
            absOffsetX = maxSwipe.right;
        }

        if (goingLeft) {
            leftOptionWidth = absOffsetX;
            rightOptionWidth = 0;
            positionX = absOffsetX;
        } else {
            rightOptionWidth = absOffsetX;
            leftOptionWidth = 0;
            positionX = -absOffsetX;
        }

        // if we were fully opened and now we're closing, dispatch close
        if (fullyOpened && absOffsetX === 0) {
            fullyOpened = false;
            dispatch('close');
        }
    }

    function onTouchEnd(event: TouchEvent) {
        if (!dragging) {
            dragging = undefined;
            return;
        }
        
        dragging = undefined;
        
        const offsetX = event.changedTouches[0].clientX - startX;
        const offsetY = event.changedTouches[0].clientY - startY;
        goingLeft = offsetX > 0;
        absOffsetX = Math.abs(offsetX);

        if (!isValidDragging(offsetX, offsetY)) {
            return;
        }

        const somethingShouldTrigger = absOffsetX >= triggerActionRequirement;

        if (goingLeft) {
            const exactlyOneOption = leftOptions.length === 1;
            const closerToFullThanZero = absOffsetX > maxSwipe.left / 2;

            if (exactlyOneOption && somethingShouldTrigger) {
                if (leftOptions[0].fn?.() !== true) updatePosition(0);
            } else if (closerToFullThanZero) {
                const pos = triggerActionRequirement * leftOptions.length;
                updatePosition(pos);
                fullyOpened = true;
            } else {
                updatePosition(0);
            }
        } else {
            const exactlyOneOption = rightOptions.length === 1;
            const closerToFullThanZero = absOffsetX > maxSwipe.right / 2;

            if (exactlyOneOption && somethingShouldTrigger) {
                if (rightOptions[0].fn?.() !== true) updatePosition(0);
            } else if (closerToFullThanZero) {
                const pos = -triggerActionRequirement * rightOptions.length;
                updatePosition(pos);
                fullyOpened = true;
            } else {
                updatePosition(0);
            }
        }
    }
</script>

{#if isMobileBuild() || $appMobileView}
    <div class="w-full relative"
        style="
            touch-action: pan-y;
        " on:touchstart|passive={onTouchStart} on:touchmove|passive={onTouchMove} on:touchend|passive={onTouchEnd}
    >
        <div class="options-wrapper left-0" style={`
            width: ${leftOptionWidth}px;
            opacity: ${(absOffsetX / triggerActionRequirement)};
        `} bind:this={leftWrapper}>
            {#each leftOptions as opt, i}
                <button
                    on:click={() => { if (opt.fn?.() !== true) setTimeout(() => updatePosition(0), 500); }}
                    class="focus:brightness-50 option {opt.class??""}"
                    style={`width: ${triggerActionRequirement}px;`}
                >
                    <svelte:component this={opt.icon} class="w-10 h-10 !text-foreground" {...opt.iconProps} />
                    {#if opt.name}
                        <span class="text-foreground">{opt.name}</span>
                    {/if}
                </button>
            {/each}
        </div>
        <div class={$$props.class??""} bind:this={element}>
            <slot swapActive={true} />
        </div>
        <div class="options-wrapper right-0" style={`
            width: ${rightOptionWidth}px;
            opacity: ${(absOffsetX / triggerActionRequirement)};
        `}>
            {#each rightOptions as opt, i}  
                <button
                    on:click={() => { if (opt.fn?.() !== true) setTimeout(() => updatePosition(0), 500); }}
                    class="focus:brightness-50 option {opt.class??""}"
                    style={`width: ${triggerActionRequirement}px;`}
                >
                    <svelte:component this={opt.icon} class="w-10 h-10" {...opt.iconProps} />
                    {#if opt.name}
                        <span class="text-foreground">{opt.name}</span>
                    {/if}
                </button>
            {/each}
        </div>
    </div>
{:else}
    <slot swapActive={false} />
{/if}

<style lang="postcss">
    .options-wrapper {
        @apply absolute top-0 bottom-0 flex flex-row items-stretch overflow-clip text-foreground;
        min-height: 32px;
    }

    button.option {
        @apply h-full flex-none flex flex-col gap-4 items-center justify-center overflow-clip;
        min-width: 5rem;
    }
</style>