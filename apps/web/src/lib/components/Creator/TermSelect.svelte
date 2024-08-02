<script lang="ts">
    import * as Select from "$lib/components/ui/select";
    import { possibleTerms } from "$utils/term";
	import type { NDKIntervalFrequency } from "@nostr-dev-kit/ndk";

    export let term: NDKIntervalFrequency;
</script>

<Select.Root portal={null} onSelectedChange={(e) => term = e.value}>
    <Select.Trigger class="w-32 w-fit {$$props.class??""}">
        <Select.Value placeholder={term} />
    </Select.Trigger>
    <Select.Content>
        {#each possibleTerms as term}
            <Select.Item value={term}>{term}</Select.Item>
        {/each}
    </Select.Content>
</Select.Root>
