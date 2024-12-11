<script lang="ts">
	import * as Avatar from '@components/ui/avatar/index.js';
	import type { NDKUserProfile } from '@nostr-dev-kit/ndk';

	export type Size = 'small' | 'medium' | 'large';
	interface Props {
		profile?: NDKUserProfile;
		of?: string;
		size?: Size;
	}

	let { profile = undefined, of = undefined, size = 'medium' }: Props = $props();

	const style = $derived.by(() => {
		switch (size) {
			case 'small':
				return { width: '20px', height: '20px' };
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
