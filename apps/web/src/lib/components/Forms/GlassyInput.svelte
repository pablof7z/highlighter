b<script lang="ts">
    import {startTyping} from "@sveu/actions"

    export let value: string = "";
    export let captureTyping = false;

    function fn(element, event){
        if (!captureTyping) return;
        if (element !== document.activeElement) element.focus()
    }
</script>

<input
    bind:value
    type="text"
    tabindex={$$props.tabindex ?? undefined}
    on:change
    on:blur
    on:focus
    on:keyup
    on:keydown
    {...$$props}
    class="
        !bg-black/30 !border-opacity-20 rounded-full text-lg py-3 px-6 text-white/80
        w-full border justify-start items-center gap-2 placeholder:!text-zinc-400 flex !ring-none
        border-white
        {$$props.class??""}
    "
    use:startTyping="{fn}"
/>