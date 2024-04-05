<script lang="ts">
	import { mainWrapperMargin, sectionHeaderMargin } from "$stores/layout";
	import { afterUpdate } from "svelte";

    export let mobilePadded = true;
    export let paddingClass = "sm:p-4 pb-24";
    export let marginClass = "max-w-3xl mx-auto";
    export let el: HTMLElement | undefined = undefined;
    export let headerMarginClass: string | undefined = undefined;

    $mainWrapperMargin = marginClass;

    afterUpdate(() => {
        if (headerMarginClass) {
            $sectionHeaderMargin = headerMarginClass;
        } else {
            $sectionHeaderMargin = marginClass;
        }
    });

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
