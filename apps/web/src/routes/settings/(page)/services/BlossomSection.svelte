<script lang="ts">
    import { activeBlossomServer, userBlossom } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
	import { NDKList } from "@nostr-dev-kit/ndk";
	import { Input } from "$components/ui/input";
	import Button from "$components/ui/button/button.svelte";

    const URL_REGEX = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;

    if (!$userBlossom) {
        $userBlossom = new NDKList($ndk);
        $userBlossom.kind = 10063;
        $userBlossom.created_at = 0;
        $userBlossom.addItem([ "r", "https://blossom.primal.net"])
    }

    let items: string[] = [];

    let eventCreatedAt;

    $: if (eventCreatedAt !== $userBlossom.created_at) {
        items = $userBlossom.items.map((item) => item[1]);
        eventCreatedAt = $userBlossom.created_at;
    }

    async function save() {
        $userBlossom!.removeTag("r");
        $userBlossom!.removeTag("server");
        
        $userBlossom.tags = [
            ...$userBlossom.tags,
            ...items.map((item) => ["server", item])
        ];
        $userBlossom.kind = 10063;
        $userBlossom.created_at = Math.floor(Date.now() / 1000);
        $userBlossom.id = "";
        $userBlossom.sig = "";
        await $userBlossom.publish();
    }

    function makeDefault(item: string) {
        $activeBlossomServer = item;
        items = items.filter((i) => i !== item);
        items = [item, ...items];
    }
</script>

{#if $userBlossom}
    <ul class="flex flex-col">
        {#key $activeBlossomServer}
        {#each items as item, index}
            <li class="flex flex-row items-center gap-4 relative">
                <!-- try to display favicon -->
                {#if item.match(URL_REGEX)}
                    <img
                        src={`https://www.google.com/s2/favicons?domain=${item}`}
                        alt="favicon"
                        class="w-8 h-8 absolute left-5"
                    />
                {/if}
                <Input bind:value={item} class="
                    pl-16 focus-visible:ring-0
                    {index === 0 ? "rounded-t-xl" : "rounded-t-none !border-t-0"}
                    {index === items.length - 1 ? "rounded-b-xl" : "rounded-b-none"}
                " />

                {#if item.match(URL_REGEX)}
                    {#if index === 0}
                        <span class="absolute right-5 text-green-500">Default</span>
                    {:else}
                        <Button variant="outline" class="w-fit absolute right-5 font-normal" size="xs" on:click={() => makeDefault(item)}>
                            Make Default
                        </Button>
                    {/if}
                {:else}
                    <Button class="w-fit absolute right-5 text-sm" on:click={() => {
                        items = items.filter((i) => i !== item);
                    }}>
                        Remove
                    </Button>
                {/if}
                
            </li>
        {/each}
        {/key}
    </ul>
{/if}

<div class="flex flex-row items-center gap-4">
    <Button size="lg" on:click={save}>
        Save
    </Button>

    <Button variant="secondary" class="w-fit px-6" on:click={() => {
        items = [...items, ""];
    }}>
        Add New Server
    </Button>
</div>
