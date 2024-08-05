<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import type { NavigationOption } from "../../app";
	import NewPostModalInner from "./NewPostModalInner.svelte";
	import { appMobileView } from "$stores/app";

    export let group: NDKSimpleGroup | undefined = undefined;

    let title: string | undefined;
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