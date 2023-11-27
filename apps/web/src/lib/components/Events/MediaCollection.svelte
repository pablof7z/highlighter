<script lang="ts">
    export let links: string[] = [];
    const id = Math.random().toString(36).substring(7);
</script>

<div class="carousel w-full max-h-[15rem]">
    {#each links as link, i}
        <div id="item{i}" class="carousel-item w-full">
            <img src={link} class="w-full object-contain" />
        </div>
    {/each}
</div>
<div class="flex justify-center w-full py-2 gap-2">
    {#each links as link, i}
        <a href="#item{i}" class="btn btn-xs btn-neutral btn-circle !text-white/60">{i+1}</a>
    {/each}
</div>
