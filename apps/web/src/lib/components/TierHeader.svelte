<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
</script>

<div class="justify-start items-center gap-3 inline-flex">
    <div class="w-10 h-10 relative">
        <div class="w-10 h-10 left-0 top-0 absolute bg-white rounded-full"></div>
        <Avatar {user} class="w-10 h-10 left-0 top-0 absolute" />
        <div class="w-10 h-10 left-0 top-0 absolute rounded-full border-2 border-black"></div>
    </div>
    <div class="text-black text-lg font-medium">
        <Name {user} />
    </div>
</div>