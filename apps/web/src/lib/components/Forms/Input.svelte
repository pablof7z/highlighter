<script lang="ts">
    export let value: string = "";
</script>

<input
    bind:value
    type="text"
    on:change
    on:blur
    on:focus
    on:keyup
    on:keydown
    {...$$props}
    class="
        {$$props.color === "black" ?
            "border-base-300 text-opacity-30 font-medium !bg-transparent focus:!border-neutral-700"
        :
            "!bg-white text-black !border-neutral-200 focus:!border-neutral-300 "
        }
        rounded-lg w-full px-4 py-2 shadow border justify-start items-center gap-2 placeholder:!text-neutral-400 flex !ring-none {$$props.class??""}
    "
/>
