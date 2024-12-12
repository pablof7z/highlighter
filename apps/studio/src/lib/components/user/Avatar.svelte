<script lang="ts">
	import * as Avatar from '@components/ui/avatar/index.js';
	import type { NDKUser, NDKUserProfile } from '@nostr-dev-kit/ndk';
	import { Profile } from './profile.svelte';

	export type Size = 'small' | 'medium' | 'large';
	interface Props {
		profile?: NDKUserProfile | null;
		of?: string | NDKUser;
		size?: Size;
	}

	let { profile = undefined, of = undefined, size = 'medium' }: Props = $props();

	if (of) {
		profile ??= new Profile(of);
	}

	const style = $derived.by(() => {
		switch (size) {
			case 'small':
				return { width: '28px', height: '28px' };
			case 'medium':
				return { width: '32px', height: '32px' };
			case 'large':
				return { width: '64px', height: '64px' };
		}
	});
</script>

<Avatar.Root {style}>
	<Avatar.Image src={profile?.image} alt={profile?.name} />
	<Avatar.Fallback>SC</Avatar.Fallback>
</Avatar.Root>
