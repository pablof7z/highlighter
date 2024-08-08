<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { Lightning } from "phosphor-svelte";

    export let open: OpenFn;
</script>

<Button
    variant="secondary"
    class="footer-button flex flex-col items-center gap-2 h-auto p-2"
    on:click={() => open('zap')}
>
    <Lightning size={40} weight="fill" class="text-gold" />
    Reward
</Button>