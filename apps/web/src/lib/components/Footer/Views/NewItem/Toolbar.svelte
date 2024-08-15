<script lang="ts">
	import { goto } from "$app/navigation";
	import { OpenFn } from "$components/Footer";
	import { Button } from "$components/ui/button";

    export let open: OpenFn;

    function go(path: string) {
        return () => {
            open(false);
            goto(path);
        }
    }

</script>

<div class="flex flex-row gap-2 items-center w-full">
    <Button variant="secondary" class="grow" on:click={go('/schedule')}>
        ⏱️ Scheduled Posts
    </Button>

    <Button variant="secondary" class="grow" on:click={go('/studio/drafts')}>
        🖋️ Drafts
    </Button>
</div>