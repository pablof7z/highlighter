<script lang="ts">
    import {Lightbox} from 'svelte-lightbox';

    export let links: string[] = [];
    const id = Math.random().toString(36).substring(7);

    let currentI = 0;

    function updateI(e) {
        const i = parseInt(e.target.href.split("#item")[1]);
        currentI = i;
    }
</script>

<div class="carousel w-full max-h-[15rem] lg:max-h-[30rem]">
    {#each links as link, i}
        <div id="item{i}" class="carousel-item w-full">
            <Lightbox>
                <img src={link} class="w-full object-contain" />
            </Lightbox>
        </div>
    {/each}
</div>
<div class="flex justify-center w-full py-2 gap-2">
    {#each links as link, i}
        <a href="#item{i}" on:click={updateI} class="
            flex-none !text-white/60 h-2 w-2 rounded-full
            {currentI === i ? 'bg-white/100' : 'bg-white/40'}
        ">
        </a>
    {/each}
</div>
