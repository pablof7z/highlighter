<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { Button } from "$components/ui/button";
    import * as Drawer from "$lib/components/ui/drawer";
	import Login from "$modals/Login.svelte";
	import { openModal } from "$utils/modal";
</script>

<ModalShell>
    <div class="flex flex-col gap-4">
        <h3 class="text-foreground text-lg font-bold">Are you a content creator?</h3>

        <div class="text-serif">
            Read about how you can build your audience, community and make your work
            sustainable.
        </div>

        <Button class="w-full" size="lg" href="/mobile/onboarding/creators">
            Setup your creator profile
        </Button>

        <Button on:click={() => openModal(Login)}>
            Open
        </Button>
    </div>
</ModalShell>
