<script lang="ts">
    export let title: string;
    export let buttonActive = false
    export let onClick = async () => {return}
</script>

<div class="flex flex-col items-center">
    <button on:click={onClick} class="w-11 h-11 btn-circle bg-base-300 mb-2 grid place-items-center { buttonActive ? 'text-accent border border-accent hover:bg-accent hover:bg-opacity-20' : 'text-zinc-400 hover:border hover:border-zinc-400 hover:bg-opacity-30'} {$$props.class || ``} ">
        <slot />
    </button>
    <span class="text-xs font-normal text-base-100-content">
        {title}
    </span>
</div>