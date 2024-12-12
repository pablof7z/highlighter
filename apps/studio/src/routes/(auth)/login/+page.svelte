<script lang="ts">
	import { goto } from '$app/navigation';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import { Label } from '$lib/components/ui/label/index.js';
	import type { ButtonStatus } from '@/components/ui/button/button.svelte';
	import { Textarea } from '@/components/ui/textarea';
	import { ndk } from '@/state/ndk';
	import NDK, { NDKEvent, NDKNip46Signer, NDKPrivateKeySigner, type NDKSigner, type NostrEvent } from '@nostr-dev-kit/ndk';
	import { toast } from 'svelte-sonner';

	let name = $state('');

    let payload = $state<string>("");

    let status = $state<ButtonStatus>("initial");

	async function login() {
        let signer: NDKSigner;
        
        if (payload.startsWith('nsec1')) {
            signer = new NDKPrivateKeySigner(payload);
        } else if (payload.startsWith('bunker://')) {
            status = "loading";
            const key = NDKPrivateKeySigner.generate();
            ndk.signer = key;
            signer = new NDKNip46Signer(ndk, payload, key);
            const u = await signer.blockUntilReady();
            if (u) status = 'success';
            else status = 'error';
        } else {
            toast.error('Invalid payload');
            return;
        }

		// ndk.once('signer:ready', () => {
        //     console.log("signer:ready on login");
        //     // goto('/');
		// });
        ndk.signer = signer;
	}
</script>

<div class="min-h-screen w-full lg:grid lg:grid-cols-2">
	<div class="flex items-center justify-center py-12">
		<div class="mx-auto grid w-[350px] gap-6">
			<div class="grid gap-2 text-center">
				<h1 class="text-3xl font-bold">Login</h1>
				<p class="text-muted-foreground text-balance">Login to your nostr account</p>
			</div>
			<div class="grid gap-4">
				<div class="grid gap-2">
					<Textarea id="name" placeholder="nsec or bunker:// URI" required bind:value={payload} autofocus />
				</div>
				<Button type="submit" class="w-full" onclick={login} {status}>Login</Button>
			</div>
			<div class="mt-4 text-center text-sm">
				New to nostr?   
				<a href="/signup" class="underline"> Sign up </a>
			</div>
		</div>
	</div>
	<div class="bg-muted hidden lg:block"></div>
</div>
