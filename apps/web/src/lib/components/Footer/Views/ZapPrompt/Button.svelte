<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import { scrollPercentage } from "$stores/layout";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { Writable } from "svelte/store";
	import { State } from ".";

    export let open: OpenFn;
    export let article: NDKArticle;
    export let stateStore: Writable<State>;

    $: if (!$stateStore.seen) {
        if ($scrollPercentage > 90) {
            $stateStore.seen = true;
            open('zap-prompt');
        } else {
            open(false);
        }
    }
</script>
