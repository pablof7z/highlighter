<script lang="ts">
    export let paddingClass = "p-4 pt-0 pb-24 sm:p-6 max-sm:px-0";
    export let marginClass = "max-w-3xl mx-auto";
</script>

<div class="
    {paddingClass}
    flex flex-col w-full {$$props.class??""}
    {marginClass}
">
    <slot />
</div>
