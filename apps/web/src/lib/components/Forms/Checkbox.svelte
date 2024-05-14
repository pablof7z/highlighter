<script lang="ts">
    export let value: boolean | undefined = undefined;
    export let type: "check" | "switch" = "check";
</script>

<label class="text-white text-base font-medium flex flex-row gap-2 items-center justify-between {$$props.class??""}">
    <div class="flex flex-row items-center w-full">
        {#if type === 'check'}
            <input type="checkbox" class="checkbox mr-3" bind:checked={value} on:change />
        {/if}

        <div class="flex flex-col sm:flex-row gap-2 justify-stretch items-center w-full">
            <div class="flex flex-col items-start grow w-full">
                <slot />
                <div class="text-neutral-500">
                    <slot name="description" />
                </div>
            </div>

            {#if type === 'switch'}
                <input type="checkbox" class="toggle [--tglbg:gray] ml-3" bind:checked={value} on:change on:focus={(e) => e.target.blur()} />
            {/if}

            <div class="flex shrink items-stretch max-sm:w-full whitespace-nowrap"
                class:opacity-50={!value}
                class:pointer-events-none={!value}
            >
                <slot name="button" />
            </div>
        </div>
    </div>
</label>

<style lang="postcss">
    label {
        @apply border border-base-300 p-4 rounded-xl;
    }
</style>