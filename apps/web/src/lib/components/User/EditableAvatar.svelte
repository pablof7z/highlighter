<script lang="ts">
	import { Avatar } from "@kind0/ui-common";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
	import type { UserProfile } from "../../../app";
	import { Pen } from "phosphor-svelte";

    export let user: NDKUser;
    export let userProfile: UserProfile | undefined | null = undefined;
    export let fetching: boolean;
</script>

<button class="group {$$props.class??""} relative border-none">
    <div class="absolute top-0 w-full transition-all duration-200 opacity-0 group-hover:opacity-100 flex items-center justify-center z-50 h-full bg-black/50 rounded-full">
        <Pen class="text-white/80 w-full h-full max-h-[32px]" />
    </div>
    <Avatar {userProfile} {user} class="{$$props.class??""}" {fetching} />
</button>