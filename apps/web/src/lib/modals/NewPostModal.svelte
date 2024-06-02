<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NavigationOption } from "../../app";
	import NewPostModalInner from "./NewPostModalInner.svelte";

    let title = "New Post";
    let wrapperClass = "";
    let actionButtons: NavigationOption[] = [];
</script>

<ModalShell {title}
    class={wrapperClass}
    {actionButtons}
>
    <NewPostModalInner bind:title bind:wrapperClass bind:actionButtons />
</ModalShell>