<script lang="ts">
	import { TrashSimple } from "phosphor-svelte";
import { Button } from "../button";
	import Input from "./input.svelte";

    export let values: string[] = [];
</script>

{#each values as value, index}
    <li class="flex flex-row items-center gap-4 relative">
        <Input bind:value class="
            pl-16 focus-visible:ring-0
            {index === 0 ? "rounded-t-xl" : "rounded-t-none !border-t-0"}
            {index === values.length - 1 ? "rounded-b-xl" : "rounded-b-none"}
        " />

        <Button variant="ghost" class="w-fit absolute right-0 text-sm" on:click={() => {
            values = values.filter((i) => i !== value);
        }}>
            <TrashSimple />
        </Button>
    </li>
{/each}