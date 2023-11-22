<script lang="ts">
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Pencil } from "phosphor-svelte";

    export let tier: NDKEvent;
    export let selected: boolean;
    export let term: string = "monthly";

    const name = tier.tagValue("title");
    const description = tier.content;
    const image = tier.tagValue("image") ?? "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573765/9d074162251943e5ab33aab20473401b/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=cv0bruLHhMqG8H2k18NhN0rjdHmfeOTTifNxVoRYRNw%3D";

    let amount: string | undefined;

    $: amount = tier.getMatchingTags("amount").find((tag) => tag[3] === term)![1];
</script>

<button on:click
    class="card card-compact full-image self-stretch !rounded-3xl border-2 justify-between items-start flex-col w-[300px] min-h-[300px] inline-flex h-full !bg-neutral-100"
    class:selected={selected}
>
    <figure>
        <img src={image} />
    </figure>
    <div class="card-body lex flex-col gap-4">
        <div class="flex-col justify-start items-start gap-2 flex w-full">
            <div class="text-black text-2xl font-medium w-full items-start flex group flex-row justify-between text-left">
                {name}
            </div>
                <div class="flex group flex-row justify-between items-center w-full">
                    <div class="text-center text-black text-[15px] font-medium">${amount}
                    /{term}</div>
                </div>
        </div>
        <div class="flex-col justify-start items-start gap-4 flex w-full text-black text-left">
            {description}
        </div>
    </div>
</button>

<style lang="postcss">
    button.selected {
        @apply  border-black;
    }
</style>