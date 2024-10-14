<script lang="ts">
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
    use:inview
    on:inview_change={inViewChange}
>
    <slot />
</div>