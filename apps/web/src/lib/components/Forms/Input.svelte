<script lang="ts">
    export let value: string = "";
</script>

<input
    bind:value
    type="text"
    on:change
    on:keyup
    {...$$props}
    class="
        {$$props.color === "black" ? "border border-neutral-800 text-white text-opacity-30" : ""}
        w-full px-4 py-3 rounded-full shadow border border-neutral-200 justify-start items-center gap-2 inline-flex {$$props.class??""}
    "
/>

<style lang="postcss">
    input {
        @apply bg-white text-black;
    }
</style>