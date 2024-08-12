<script lang="ts">
	import { getContext } from "svelte";
    import * as Groups from "$components/Groups";
	import { layout } from '$stores/layout';
	import { Readable } from "svelte/store";

    export let group = getContext('group') as Readable<Groups.Group>;
    
    $layout.footerInMain = true;
    $layout.title = $group?.name;
    $layout.event = undefined;
    $layout.fullWidth = false;
    $: if ($group.isMember) {
        console.log('setting footer')
        $layout.footer = {
            component: Groups.Footers.Home,
            props: { group }
        }
    }
</script>

<Groups.Header
    {group}
/>
