<script lang="ts">
    export let icon: string;
    export let title: string;
    export let href: string | undefined = "#";
</script>

<a {href} on:click class="
    w-full
    bg-black bg-opacity-[0.33]
    rounded-2xl justify-center items-center inline-flex
    flex-col
    flex-none
    py-2
    sm:px-0
    gap-0
    relative
    focus:outline-none
    {$$props.class??""}
">
    <div class="justify-center items-center text-[42px]">
        {icon}
    </div>
    <div class="text-base font-medium text-white">
        {title}
    </div>
</a>
