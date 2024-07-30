<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import * as Select from "$lib/components/ui/select";
	import { writable } from "svelte/store";

    const makePublicAfter = writable<number | false>(false);
    
    let makeFreeCheck = $makePublicAfter !== undefined && Number($makePublicAfter) > 0;

    $: if (!makeFreeCheck) $makePublicAfter = false;

    function updateMakePublic() {
        if ($makePublicAfter === undefined || $makePublicAfter === false) {
            makeFreeCheck = false;
        } else {
            makeFreeCheck = true;
        }
    }

    const opts = [
        { label: 'never', value: false },
        { label: '1 day', value: 1 },
        { label: '1 week', value: 7 },
        { label: '2 weeks', value: 14 },
        { label: '1 month', value: 30 },
    ]
    
    let selected = opts.find(o => o.value === $makePublicAfter) || opts[0]

    $: if (selected !== null) $makePublicAfter = selected.value as number | false;
</script>

<Checkbox
    bind:value={makeFreeCheck}
    button={true}
    on:change={() => {
        if (makeFreeCheck) $makePublicAfter = 7
        else $makePublicAfter = false
    }}
>
    Release full-version for free after

    <Select.Root loop slot="button" bind:selected  on:change={(e) => console.log(e)}>
        <Select.Trigger class="w-32">
            <Select.Item value={selected.value}>{selected.label}</Select.Item>
        </Select.Trigger>
        <Select.Content>
            <Select.Item class="text-nowrap" value={false}>never</Select.Item>
            <Select.Item class="text-nowrap" value={1}>1 day</Select.Item>
            <Select.Item class="text-nowrap" value={7}>1 week</Select.Item>
            <Select.Item class="text-nowrap" value={14}>2 weeks</Select.Item>
            <Select.Item class="text-nowrap" value={30}>1 month</Select.Item>
        </Select.Content>
    </Select.Root>
</Checkbox>