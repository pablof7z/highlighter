<script lang="ts">
	import { mainWrapperMargin } from "$stores/layout";

    export let mobilePadded = true;
    export let paddingClass = "sm:p-4 pb-24";
    export let marginClass = "max-w-3xl mx-auto";
    export let el: HTMLElement | undefined = undefined;

    $mainWrapperMargin = marginClass;
</script>

<div class="
    {paddingClass}
    min-h-screen
    flex flex-col w-full {$$props.class??""}
    {marginClass}
"
    class:max-sm:p-3={mobilePadded}
    bind:this={el}
>
    <slot />
</div>
