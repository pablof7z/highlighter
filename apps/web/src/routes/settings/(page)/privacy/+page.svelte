<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk.js";

    $layout = {
        title: "Privacy",
        back: { url: '/settings' }
    };

    let announceClient = !!$ndk.clientNip89;

    $: if (announceClient === false) {
        $ndk.clientNip89 = undefined;
        $ndk.clientName = undefined;
    } else {
        $ndk.clientName = 'highlighter';
        $ndk.clientNip89 = '31990:73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63:1704502265408';
    }
</script>

<Checkbox
    bind:value={announceClient}

>
    Enable client identity
    <span class="text-sm" slot="description">
        If this is turned on, public notes you create will have a "client" tag added. This helps with troubleshooting, and allows others to know about different nostr clients.
    </span>
</Checkbox>
