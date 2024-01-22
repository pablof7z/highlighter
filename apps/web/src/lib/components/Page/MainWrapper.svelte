<script lang="ts">
    export let mobilePadded = true;
    export let paddingClass = "p-4 pt-0 pb-24 sm:px-3";
    export let marginClass = "max-w-3xl mx-auto";
</script>

<div class="
    {paddingClass}
    flex flex-col w-full {$$props.class??""}
    {marginClass}
"
    class:max-sm:p-3={mobilePadded}
>
    <slot />
</div>
