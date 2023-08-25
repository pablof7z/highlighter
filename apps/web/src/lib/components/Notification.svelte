<script lang="ts">
    export let title: string;
    export let notifications: number = 0;
</script>

<div class="flex flex-col items-center">
    <div class="relative w-11 h-11 btn-circle bg-base-300 mb-2">
        {#if notifications}
        <div class="absolute top-0 right-0 h-4 w-4 bg-orange-400 rounded-full flex items-center justify-center text-white text-[8px] leading-1">
            <span>
                {notifications}
            </span>
        </div>
        {/if}
    </div>
    <span class="text-[8px] font-normal leading-tight">
        {title}
    </span>
</div>