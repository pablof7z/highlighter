<script lang="ts">
	import { headerTouchFns } from "$stores/layout";
    import { inview } from "svelte-inview";

    export let isInView = false;

    function inViewChange(e: CustomEvent<{ inView: boolean }>) {
        isInView = e.detail?.inView;
    }
</script>

<div class="
    z-20 w-full flex flex-col overflow-clip
    {$$props.class??""}
"
    on:touchstart={$headerTouchFns.start}
    on:touchmove={$headerTouchFns.move}
    on:touchend={$headerTouchFns.end}
    use:inview
    on:inview_change={inViewChange}
>
    <slot />
</div>