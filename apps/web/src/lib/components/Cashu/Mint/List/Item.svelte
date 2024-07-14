<script lang="ts">
	import Checkbox from "$components/ui/checkbox/checkbox.svelte";
	import Avatar from "$components/User/Avatar.svelte";
import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { ndk } from "$stores/ndk";
import { CashuMint } from "@cashu/cashu-ts";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    export let url: string;
    export let checked: boolean = false;

    let info: any;
    let user: NDKUser;
    try {
        const mint = new CashuMint(url)
    mint.getInfo().then((res) => {
        if (!res) return;
        info = res;
        const nostr = info.contact?.find((c: any) => c[0] === 'nostr');
        if (nostr) {
            try {
                console.log(nostr);
                const u = $ndk.getUser({npub: nostr[1]});
                console.log('user', user.pubkey);
                u.pubkey
                user = u;
            } catch { }
        }
    }).catch(() => {});
} catch {}
</script>

<button on:click={() => checked = !checked} class="flex flex-row items-center justify-between w-full">
    <div class="flex flex-col gap-2 text-left">
        {#if info}
            {#if user}
                <Avatar {user}>
                    <span class="text-xs">{url}</span>
                </Avatar>
            {:else}
                <!-- <h3 class="font-bold text-foreground">{info.name}</h3> -->
            {/if}
            <div class="text-sm text-muted-foreground">
                {info.description}
            </div>
            <div class="text-sm text-muted-foreground">
                {Object.keys(info.nuts).join(', ')}
            </div>
        {:else}
            {url}
        {/if}
    </div>

    <Checkbox bind:checked />
</button>