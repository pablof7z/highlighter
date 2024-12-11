<script lang="ts">
	import { goto } from '$app/navigation';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import { Label } from '$lib/components/ui/label/index.js';
	import { ndk } from '@/state/ndk';
	import { NDKEvent, NDKPrivateKeySigner, type NostrEvent } from '@nostr-dev-kit/ndk';

	let name = $state('');

	function signup() {
		const signer = NDKPrivateKeySigner.generate();
		const kind0 = new NDKEvent(ndk, {
			kind: 0,
			content: JSON.stringify({ name: name })
		} as NostrEvent);
		const kind3 = new NDKEvent(ndk, {
			kind: 3,
			tags: [['p', 'fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52']]
		} as NostrEvent);
		kind0.sign(signer).then(() => kind0.publish());
		kind3.sign(signer).then(() => kind3.publish());

		ndk.signer = signer;
		ndk.once('signer:ready', () => {
			goto('/');
		});
	}
</script>

<div class="min-h-screen w-full lg:grid lg:grid-cols-2">
	<div class="flex items-center justify-center py-12">
		<div class="mx-auto grid w-[350px] gap-6">
			<div class="grid gap-2 text-center">
				<h1 class="text-3xl font-bold">Signup</h1>
				<p class="text-muted-foreground text-balance">Create a new nostr account</p>
			</div>
			<div class="grid gap-4">
				<div class="grid gap-2">
					<Label for="name">Name</Label>
					<Input id="name" type="text" placeholder="Max" required bind:value={name} autofocus />
				</div>
				<Button type="submit" class="w-full" onclick={signup}>Signup</Button>
			</div>
			<div class="mt-4 text-center text-sm">
				Already have an account?
				<a href="/login" class="underline"> Sign in </a>
			</div>
		</div>
	</div>
	<div class="bg-muted hidden lg:block"></div>
</div>
