<script lang="ts">
    import GenericEventCard from '$lib/components/events/generic/card.svelte';
    import Name from '$lib/components/Name.svelte';
    import { parseContent } from '$lib/nip27';
    export let note: string;
    export let tags: any[];
    export let addNewLines: boolean = true;
    export let kind: number | undefined = undefined;
    let notePrev: string;

    const links = []
    const entities = []
    const ranges = []

    let anchorId;
    let content;

    $: if (note && note !== notePrev) {
        notePrev = note;

        content = parseContent(note||"", tags);

        // Find links and preceding whitespace
        for (let i = 0; i < content.length; i++) {
            const {type, value} = content[i]

            if (
                (type === "link" && !value.startsWith("ws")) ||
                ["nostr:note", "nostr:nevent"].includes(type)
            ) {
                if (type === "link") {
                    links.push(value)
                } else if (value.id !== anchorId) {
                    entities.push({type, value})
                }

                const prev = content[i - 1]
                const next = content[i + 1]

                if ((!prev || prev.type === "newline") && (!next || next.type === "newline")) {
                let n = 1
                for (let j = i - 1; ; j--) {
                    if (content[j]?.type === "newline") {
                        n += 1
                    } else {
                        break
                    }
                }

                ranges.push({i: i + 1, n})
            }
        }
    }
}
</script>

<!-- text-black -->
<div class="
    leading-normal
    h-full flex flex-col sm:text-justify
    overflow-auto
">
    <div>
        {#each content as { type, value }}
            {#if type === "newline"}
                {#each value as _}
                    {#if addNewLines}
                        <br />
                    {/if}
                {/each}
            {:else if type === "link"}
                {value.replace(/https?:\/\/(www\.)?/, "")}
                <!-- <img src="{value}" /> -->
            {:else if type.startsWith("nostr:")}
                {#if value.pubkey || value.entity.startsWith('npub')}
                    <a href="/p/{value.id||value.pubkey}" class="text-purple-600">
                        <Name pubkey={value.id||value.pubkey} />
                    </a>
                {:else}
                    <div class="embedded-card text-sm">
                        <GenericEventCard id={value.entity} skipReplies={true} />
                    </div>
                {/if}
            {:else if type === "topic"}
                <b>#{value}</b>

            {:else}
                {@html value}
            {/if}
        {/each}
    </div>
</div>

