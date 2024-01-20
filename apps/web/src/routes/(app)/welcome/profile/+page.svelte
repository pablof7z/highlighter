<script>
	import { goto } from "$app/navigation";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import Step3 from "../creators/Step3.svelte";
</script>

<MainWrapper class="p-4 pt-0 pb-24 sm:p-6">
	<div class="max-w-3xl">
		<Step3 on:saved={() => goto("/welcome")} />
	</div>
</MainWrapper>