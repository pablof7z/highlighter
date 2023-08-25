<script lang="ts">
    export let amount: number = 1000;

    let value = amount.toString();

    $: amount = +value;
</script>

<div class="flex flex-row items-center gap-2">
    <input type="range" min="0" max="100000" class="range range-neutral h-[12px] flex-grow" bind:value />
    <div class="relative flex flex-row items-center">
        <input type="text" class="input input-bordered shrink w-36 !bg-transparent pr-14" bind:value />
        <span class="absolute right-3">sats</span>
    </div>
</div>