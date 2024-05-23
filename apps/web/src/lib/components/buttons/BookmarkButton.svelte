<script lang="ts">
	import AnimatedToggleButton from "$components/PageElements/AnimatedToggleButton.svelte";
    import { BookmarkSimple } from "phosphor-svelte";

    export let active: boolean;
</script>

<AnimatedToggleButton
    {active}
    icon={BookmarkSimple}
    buttonClass="hover:bg-red-400/20"
    bgClass="bg-red-500"
    iconClass={active ? "text-red-500" : "text-red-400/30 group-hover:text-red-500"}
    on:click
/>
