<script>
	import { page } from '$app/stores';
	import { fade } from 'svelte/transition';
</script>

<div class="w-screen h-screen top-0 left-0 fixed flex justify-center items-center" transition:fade>
	<div class="max-w-2xl">
		<h1 class="text-4xl font-bold text-center">Oops</h1>

			<p class="text-center">
			There was an error loading this page.
		</p>

		<p class="text-center">
			<a href="/" class="button button-primary">Go Home</a>
		</p>

		<pre class="text-center">
			{$page.error?.message}
			{JSON.stringify($page, null, 2)}
		</pre>
	</div>
</div>
