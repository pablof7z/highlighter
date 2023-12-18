<script lang="ts">
    export let value: boolean;
    export let button: boolean = false;
</script>

<label class="text-white text-base font-medium flex flex-row gap-2 items-center justify-between">
    <div class="flex flex-row items-start">
        <input type="checkbox" class="checkbox mr-3" bind:checked={value} />
        <div class="flex flex-col sm:flex-row gap-2 items-stretch justify-stretch">
            <div class="flex flex-col items-start">
                <slot />
                <div class="text-neutral-500">
                    <slot name="description" />
                </div>
            </div>

            {#if button}
                <div class="flex flex-grow items-stretch w-full">
                    <slot name="button" />
                </div>
            {/if}
        </div>
    </div>
</label>

<style lang="postcss">
    label {
        @apply border border-base-300 p-4 rounded-xl;
    }
</style>