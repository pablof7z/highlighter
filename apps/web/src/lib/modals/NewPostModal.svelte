<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../app";
	import NewPostModalInner from "./NewPostModalInner.svelte";

    export let group: NDKSimpleGroup | undefined = undefined;

    let title = "New Post";
    let wrapperClass = "max-w-3xl w-full";
    let actionButtons: NavigationOption[] = [];
</script>

<ModalShell {title}
    containerClass={wrapperClass}
    {actionButtons}
>
    <NewPostModalInner
        bind:title
        bind:wrapperClass
        bind:actionButtons
        {...$$props}
    />
</ModalShell>