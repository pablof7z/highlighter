<script lang="ts">
	import DvmListItem from '$components/dvms/DvmListItem.svelte';
	import JobRequestEditor from '$components/jobs/JobRequestEditor/JobRequestEditor.svelte';
	import Logo from '$icons/Logo.svelte';
	import { appHandlers } from '$stores/nip89';
</script>

<svelte:head>
	<title>Vendata - A client for Nostr Data Vending Machines (NIP-90)</title>
</svelte:head>

<div class="flex flex-col gap-12">
	<section
		class="mx-2 flex flex-col items-center justify-center gap-8 md:h-[50vh] md:flex-row lg:mx-auto">
		<img
			src="https://cdn.midjourney.com/bd588aed-e734-4043-99b3-352ee973de24/0_3.png"
			alt="cyperpunkImage"
			class="rounded-box h-full"
		/>

		<div class="flex flex-col items-start gap-3 lg:w-1/2 lg:gap-0">
			<h1
				class="text-center text-7xl font-extrabold tracking-wider sm:text-start sm:text-6xl lg:text-8xl"
			>
				<span class="bg">Money in,</span>
				<br class="hidden md:block" />
				<span class="bg">Data out</span>
			</h1>
			<h2 class="text-base-100-content text-center text-3xl font-thin sm:text-start">
				The freest market of data-processing AIs in the world
			</h2>
		</div>
	</section>

	<section class="flex flex-col gap-8">
		<h1 class="flex flex-col items-center gap-4 text-center text-3xl md:text-5xl font-black">
			<div class="text-2xl md:text-3xl font-bold opacity-80">Meet your</div>
			<span class="bg">Data Vending Machine</span>
		</h1>

		<div class="relative mx-auto flex flex-col gap-8 px-4 lg:flex-row">
			<div class="text-base-300-content prose rounded-box py-8 text-lg lg:w-2/3 lg:p-8">
				<div class="sticky top-20">
					<h1 class="text-3xl font-bold">What are Data Vending Machines?</h1>

					<p>
						Data Vending Machines are data-processing tools. You give them some data, a few sats,
						and they give you back some data.
					</p>

					<p>
						<a href="/magic" class="text-accent">The magic of DVMs</a>
						comes from a few key properties:
					</p>

					<div class="not-prose grid grid-flow-row gap-8">
						<div class="grid gap-6 sm:grid-cols-2">
							<div class="card card-compact !rounded-xl">
								<div class="card-body">
									<span class="block text-2xl font-bold text-accent">Discoverable</span>
									<p class="text-lg">
										Jobs don't need to be specifically directed to any DVM; users simply request a
										certain job to be done and available DVMs pick it up.
									</p>
								</div>
							</div>

							<div class="card card-compact !rounded-xl">
								<div class="card-body">
									<span class="block text-2xl font-bold text-accent">Composable</span>
									<p class="text-lg">
										Jobs don't need to be specifically directed to any DVM; users simply request a
										certain job to be done and available DVMs pick it up.
									</p>
								</div>
							</div>
						</div>

						<div class="card card-compact !rounded-xl">
							<div class="card-body">
								<span class="block text-2xl font-bold text-accent">Ruthless Competition</span>
								<p class="text-lg">
									The fact that there is no registration, no signups or approvals, the fact
									<span class="text-base-100-content">
										that
										<mark>anyone can create a DVM</mark> and immediately monetize it with zero-intermediaries
									</span>, in an ever-growing marketplace that is beaming with new users coming from
									all types of use cases in mind, means that the DVM market is the freest market of
									data-processing AIs in the world.
								</p>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="lg:w-1/3">
				<div class="mx-auto grid max-w-5xl grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-1 xl:w-96">
					{#each $appHandlers as dvm (dvm.id)}
						<DvmListItem {dvm} />
					{/each}
				</div>
			</div>
		</div>
	</section>

	<section class="max-w-5xl mx-auto relative">
        <div class="flex flex-col gap-8 justify-around absolute top-0 left-0 w-full h-full items-center text-base-100-content z-50">
            <h1 class="text-7xl sm:text-8xl font-extrabold tracking-wider text-center mt-24">
                <span class="bg">Start Exploring</span>
            </h1>

            <div class="flex flex-row w-full mb-24">
                <div class="w-1/2 flex flex-row items-center justify-center">
                    <a href="/dvms" class="btn bg-gradient-to-r from-gradient3 to-gradient4 text-white !rounded-full btn-lg">
                        Explore DVMs
                    </a>
                </div>
                <div class="w-1/2 flex flex-row items-center justify-center">
                    <button class="btn bg-gradient-to-l from-gradient3 to-gradient4 text-white !rounded-full btn-lg">
                        Submit a job
                    </button>
                </div>
            </div>
        </div>
        <div class="card opacity-20">
            <JobRequestEditor
            />
        </div>
    </section>
</div>

<style>
	h1 span.bg {
		background: linear-gradient(50deg, #fff 0%, #817eff 100%);
		background-clip: text;
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
	}
</style>
