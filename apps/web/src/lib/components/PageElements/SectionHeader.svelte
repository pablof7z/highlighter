<script lang="ts">
    export let title: string;
</script>

<div class="
    w-full
    h-full
    bg-base-100 max-sm:mobile-navfixed
    sm:rounded-3xl
    flex-col justify-start items-start gap-6 inline-flex shrink-0 {$$props.class??""}
">
        <div class="
            self-stretch justify-between items-center gap-6 inline-flex
            py-4 w-full px-4
            border-b border-base-300
            overflow-clip truncate
        ">
            <h1 class="
                grow shrink basis-0 text-white font-semibold
                flex flex-row items-center gap-2
                max-sm:text-lg
                sm:text-2xl
                whitespace-nowrap
            "
            >
                {title}
            </h1>
        </div>

        <div
            class:max-sm:hidden={!open}
            class="
            max-sm:max-h-[50dvh]
            h-full
            overflow-y-auto
            flex-col justify-start items-start gap-3 flex w-full
            px-4
            {$$props.innerClass??""}
        ">
            <slot />
        </div>
</div>