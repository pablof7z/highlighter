<script lang="ts">
	import * as Groups from "$components/Groups";
	import { layout } from "$stores/layout";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
	
	$layout.sidebar = undefined;
	
	let group = getContext("group") as Readable<Groups.Group>;
</script>

<Groups.Views.Home {group} />