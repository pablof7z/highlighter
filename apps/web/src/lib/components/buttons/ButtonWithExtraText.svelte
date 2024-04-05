<script lang="ts">
    export let text: string;
</script>

<button class="group h-fit transitiona-all duration-300 {$$props.class??""}" on:click>
    <slot />
    <span class="max-w-0 truncate group-hover:max-w-[20rem] transition-all duration-300 font-normal {$$props.textClass??""}">
        {text}
    </span>
</button>