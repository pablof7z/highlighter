<script lang="ts">
    export let value: string = "";
</script>

<input
    bind:value
    type="text"
    on:change
    on:blur
    on:keyup
    {...$$props}
    class="
        {$$props.color === "black" ? "border border-neutral-800 !text-white text-opacity-30 text-base font-medium" : "!bg-white text-black"}
        rounded-lg w-full px-4 py-2 shadow border !border-neutral-200 focus:!border-neutral-300 justify-start items-center gap-2 transition-colors placeholder:!text-neutral-400 text-[15px] duration-200 flex {$$props.class??""}
    "
/>

<style lang="postcss">
    input {
    }
</style>
<!-- <div class="w-[300px] h-[43px] px-4 py-3 bg-white rounded-lg shadow border border-neutral-200 justify-start items-center gap-2 inline-flex">
    <div class="grow shrink basis-0 text-black text-opacity-30 text-[15px] font-normal font-['Inter Variable'] leading-[19px]">Recovery email</div>
</div> -->