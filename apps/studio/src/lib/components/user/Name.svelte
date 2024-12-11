<script lang="ts">
	import { ndk } from '@/state/ndk.js';

	import { Name } from '@nostr-dev-kit/ndk-svelte-components';
	import { onMount } from 'svelte';
	import { Profile } from './profile.svelte';

	let {
		of = undefined,
		profile = undefined,
		npubMaxLength = 8,
		class: className = undefined,
		loadingClass = undefined,
		loadingStyle = undefined
	} = $props();

	$inspect({ of });

	if (of) {
		profile ??= new Profile(of);
	}

	let timedout = $state(false);

	onMount(() => {
		setTimeout(() => {
			timedout = true;
		}, 1500);
	});

	const randSkeletonWidth = Math.max(Math.floor(Math.random() * 100) + 120, 190);

	const defaultLoadingClass = 'skeleton h-[15px]';
	const defaultLoadingStyle = `width: ${randSkeletonWidth}px; height: 15px;`;
</script>

{#if !profile}
	<div
		style={loadingStyle ? loadingStyle : defaultLoadingStyle}
		class={loadingClass ? loadingClass : defaultLoadingClass}
	></div>
{:else if profile?.user}
	<Name {ndk} {npubMaxLength} user={profile?.user} {profile} class={className || ``} on:click />
{/if}
