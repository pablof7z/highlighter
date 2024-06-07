<script lang="ts">
	import { privateKey } from '$stores/currentUser';
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import CopyButton from "$components/buttons/CopyButton.svelte";
    import { pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk.js";
	import { nip19 } from "nostr-tools";
	import { NDKPrivateKeySigner } from '@nostr-dev-kit/ndk';

    $pageHeader = {
        title: "Keys",
        left: {
            label: 'Back',
            url: '/settings',
        }
    };

    let nsec: string;

    $: if ($ndk.signer instanceof NDKPrivateKeySigner) {
        try {
            nsec = nip19.nsecEncode(Buffer.from($ndk.signer!.privateKey!))
        } catch { nsec = $ndk.signer!.privateKey!; }
    }
</script>

<div class="max-w-3xl px-6">
    <PageTitle title="Keys" defaultTitle="Keys" />

    {#if nsec}
        <div class="flex flex-col gap-2">
            <div class="text-foreground">Private Key</div>
            <CopyButton data={nsec} />
        </div>
    {/if}
</div>
