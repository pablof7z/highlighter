<script lang="ts">
	import { Button } from "$components/ui/button";

    export let icon: any;
    export let title: string;
    export let href: string | undefined = "#";
</script>

<Button forceNonMobile variant="outline" {href} on:click class="
    rounded-2xl justify-center items-center inline-flex
    flex-col
    flex-none
    h-auto
    py-4 sm:px-0 sm:py-6
    gap-4 sm:gap-2
    max-sm:mb-4
    relative
    focus:outline-none
">
    <div class="bg w-16 h-16 rounded-lg backdrop-blur-lg justify-center items-center gap-2.5 inline-flex p-2">
        <svelte:component this={icon} class="w-full h-full" weight="fill" />
    </div>
    <div class="text-base font-medium">
        {title}
    </div>
</Button>
