<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Lightning } from "phosphor-svelte";
	import { openModal } from '$utils/modal';
    import ZapModal from "$modals/ZapModal.svelte";
	import Button from "$components/ui/button/button.svelte";
    

    export let event: NDKEvent;
    export let showHelperText = false;

    function open() {
        console.log("Zap button clicked");
        openModal(ZapModal, { event });
    }
</script>

<Button variant="outline" class="gap-2 {$$props.class??""}" on:click={open}>
    <Lightning size={20} />
    Zap
    <span class="
        truncate transition-all duration-300 font-normal
        {!showHelperText ? "max-w-0 group-hover:max-w-[20rem]" : ""}
    ">
        Like what you see?
        Reward the creator!
    </span>
</Button>