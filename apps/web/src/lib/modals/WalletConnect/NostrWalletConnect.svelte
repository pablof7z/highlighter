<script lang="ts">
	import { Textarea } from '$components/ui/textarea';

	export let pairingCode: string = '';
</script>

<div class="flex flex-col gap-6">
	<div>Enter your pairing code</div>

	<Textarea bind:value={pairingCode} placeholder="nostr+walletconnect://..." class="font-mono" />
</div>
