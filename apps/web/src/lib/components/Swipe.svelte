<script lang="ts">
	import { type SvelteComponent } from 'svelte';
    import Device from 'svelte-device-info';

    type Option = {
        icon: typeof SvelteComponent;
        class?: string;
        cb: () => void;
    };

    export let leftOptions: Option[] = [];
    export let rightOptions: Option[] = [];
    export let handle: string | undefined = undefined;

    let positionX = 0;

    let element: HTMLElement;

    let viewportWidth = window.innerWidth;
    let triggerActionRequirement = viewportWidth / 4;

    if (triggerActionRequirement > 100) { triggerActionRequirement = 100; }

    // Is the user dragging the element?
    let dragging = false;

    // The x position of the touch start
    let startX = 0;

    // The y position of the touch start
    let startY = 0;

    let absOffsetX = 0;

    // Is the user swiping left?
    let goingLeft = false;

    let leftOptionWidth = 0;
    let rightOptionWidth = 0;

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
        dragging = true;
        startX = event.touches[0].clientX - positionX;
        startY = event.touches[0].clientY;
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

    const threshold = 20; // don't render the options if the user is scrolling

    function onTouchMove(event: TouchEvent) {
        if (dragging) {
            let xOffset = event.touches[0].clientX - startX;
            let yOffset = event.touches[0].clientY - startY;
            goingLeft = xOffset > 0;
            absOffsetX = Math.abs(xOffset);
            
            if (absOffsetX < threshold) {
                positionX = 0;
                return;
            }

            if (!isValidDragging(xOffset, yOffset)) {
                return;
            }
            
            // the larger the difference is in the y direction, the more x trends towards 0

            // limit the x offset to the triggerActionRequirement
            updatePosition(xOffset);
        }
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
    }

    function onTouchEnd(event: TouchEvent) {
        dragging = false;
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
                leftOptions[0].cb();
                updatePosition(0);
            } else if (closerToFullThanZero) {
                const pos = triggerActionRequirement * leftOptions.length;
                updatePosition(pos);
            } else {
                updatePosition(0);
            }
        } else {
            const exactlyOneOption = rightOptions.length === 1;
            const closerToFullThanZero = absOffsetX > maxSwipe.right / 2;

            if (exactlyOneOption && somethingShouldTrigger) {
                rightOptions[0].cb();
                updatePosition(0);
            } else if (closerToFullThanZero) {
                const pos = -triggerActionRequirement * rightOptions.length;
                updatePosition(pos);
            } else {
                updatePosition(0);
            }
        }
    }
</script>

{#if Device.isPhone}
<div class="w-full relative">
    <div class="options-wrapper left-0" style={`
        width: ${leftOptionWidth}px;
        opacity: ${(absOffsetX / triggerActionRequirement)};
    `}>
        {#each leftOptions as opt, i}
            <button
                on:click={() => { updatePosition(0); opt.cb() }}
                class="option {opt.class??""}"
                style={`width: ${triggerActionRequirement}px;`}
            >
                <svelte:component this={opt.icon} class="w-12 h-12 !text-white" />
            </button>
        {/each}
    </div>
    <div style="
        touch-action: pan-y;
    " bind:this={element} on:touchstart={onTouchStart} on:touchmove|passive={onTouchMove} on:touchend|passive={onTouchEnd}>
        <slot />
    </div>
    <div class="options-wrapper right-0" style={`
        width: ${rightOptionWidth}px;
        opac_ity: ${(absOffsetX / triggerActionRequirement)};
    `}>
        {#each rightOptions as opt, i}  
            <button
                on:click={() => { updatePosition(0); opt.cb() }}
                class="option {opt.class??""}"
                style={`width: ${triggerActionRequirement}px;`}
            >
                <svelte:component this={opt.icon} class="w-12 h-12 !text-white" />
            </button>
        {/each}
    </div>
</div>
{:else}
    <slot />
{/if}

<style lang="postcss">
    .options-wrapper {
        @apply absolute top-0 bottom-0 flex flex-row items-stretch overflow-clip;
        min-height: 32px;
    }

    button.option {
        @apply h-full flex-none flex flex-row items-center justify-center overflow-clip;
        min-width: 5rem;
    }
</style>