<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKKind } from "@nostr-dev-kit/ndk";
    import * as DVM from "$components/DVM";

    export let kind: NDKKind;
    export let title = "Data Vending Machines";

    console.log('list', DVM.List);
</script>

<ModalShell
    {title}
    class="max-h-[50dvh] flex flex-col"
>
    <DVM.List.Container {kind} let:dvm>
        <DVM.List.Item {dvm} />
    </DVM.List.Container>
</ModalShell>