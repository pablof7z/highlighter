<script lang="ts">
	import Avatar, { type Size as AvatarSize } from "./Avatar.svelte";
	import Name from "./Name.svelte";
	import { Profile } from "./profile.svelte";

    type Props = {
        profile?: Profile;
        of?: string;
        avatarClass?: string;
        avatarSize?: AvatarSize;
		nameClass?: string;
	};

	let { profile, of, avatarClass, nameClass, avatarSize }: Props = $props();

    if (!profile && of) {
        profile = new Profile(of);
    }
</script>

<div class="flex flex-row items-center gap-2">
    <Avatar {profile} class={avatarClass} size={avatarSize} />
    <Name {profile} class={nameClass} />
</div>
