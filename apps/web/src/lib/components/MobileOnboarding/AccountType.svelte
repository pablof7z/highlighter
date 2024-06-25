<script lang="ts">
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { Button } from "$components/ui/button";
	import { Input } from "$components/ui/input";
	import { pageHeader } from "$stores/layout";
    import { createEventDispatcher } from "svelte";

    const dispatcher = createEventDispatcher();

    function skip() {

    }

    $pageHeader ??= {};
    $pageHeader.right = {
        label: "Skip",
        fn: skip
    }

    let name: string;
</script>

<div class="flex flex-col items-start justify-stretch responsive-padding w-full h-full pt-safe mt-14">
    <Button class="h-1/2 w-full">
        I'm a content creator
    </Button>
</div>