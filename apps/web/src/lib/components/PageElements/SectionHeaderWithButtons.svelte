<script lang="ts">
	import { mainWrapperMargin } from "$stores/layout";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
    import HeaderRightButton from "./HeaderRightButton.svelte";

    export let title: string;
    export let innerMxClass = $mainWrapperMargin?.includes("mx-auto") ? "sm:-ml-12" : "";
</script>

<div class="
    w-full z-50 fixed h-16
    bg-base-100 max-sm:mobile-nav
    p-4
    flex-row justify-between items-center inline-flex shrink-0 {$$props.class??""}
">
    <div class="{$mainWrapperMargin??""} w-full">
        <div class="{innerMxClass} w-full flex items-center justify-between">
            <HeaderLeftButton />

            <h1 class="
                text-white font-semibold
                flex flex-row items-center gap-2
                max-sm:text-lg
                sm:text-2xl
                whitespace-nowrap
            "
            >
                {title}
            </h1>

            <HeaderRightButton />
        </div>
    </div>
</div>

<div class="h-16" />