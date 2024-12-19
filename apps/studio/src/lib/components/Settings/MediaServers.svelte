<script lang="ts">
	import { currentUserBlossomServers } from '@/state/current-user.svelte';
	import { ndk } from '@/state/ndk';
	import InputList from '../ui/InputList.svelte';
	import { Separator } from '../ui/separator';
	import { Button } from '../ui/button';
	import { NDKKind, NDKList } from '@nostr-dev-kit/ndk';
	import { toast } from 'svelte-sonner';
	import type { ButtonStatus } from '../ui/button/button.svelte';

    const blossomServers = $derived.by(currentUserBlossomServers);
    let list = $state(blossomServers);
    let status = $state<ButtonStatus>('initial');

    function save() {
        status = 'loading';
        const servers = new NDKList(ndk);
        servers.kind = NDKKind.BlossomList;
        list.forEach(server => {
            servers.addItem(["server", server]);
        });
        servers.publishReplaceable()
            .then(() => {
                toast.success("Media servers updated");
                status = 'success';
            })
            .catch(error => {
                toast.error("Failed to update media servers");
                status = 'error';
            });
    }

    function makeDefault(server: string) {
        const newList = [server, ...list.filter(s => s !== server)];
        list = newList;
    }
</script>

<h1 class="text-lg font-bold">
    🌸
    Media Servers</h1>
<h2 class="text-sm text-muted-foreground">
    Nostr uses media servers called Blossom, to provide censorship-resistant media storage.
</h2>

<InputList
    bind:value={list}
    prefix="https://"
    placeholder="New Blossom Server"
>
    {#snippet children(data)}
        <Button variant="link" class="text-xs p-0 group-hover:opacity-100 opacity-10 transition-opacity duration-100" onclick={() => makeDefault(data.value)}>
            Make default
        </Button>
    {/snippet}
</InputList>

<Separator class="my-6" />

<div class="flex flex-row items-center justify-center gap-2">
    <Button variant="default" class="px-10" onclick={save} {status}>
        Save
    </Button>

    <Button variant="outline" class="px-10" onclick={() => list = blossomServers}>
        Reset
    </Button>
</div>