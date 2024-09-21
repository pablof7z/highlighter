<script lang="ts">
	import { layout, setLayout } from "$stores/layout";
    import * as Session from "$components/Session";
	import { onDestroy, onMount } from "svelte";
	import { goto } from "$app/navigation";
	import currentUser from "$stores/currentUser";
    import Illustration from "$lib/illustrations/schedule.svelte";
	import { Button } from "$components/ui/button";

    let title = "Welcome!"

    setLayout({
        title,
        navSidebar: false,
        fullWidth: true,
        header: undefined,
        back: { url: "/"  }
    })

    $: $layout.title = title;

    $: if ($currentUser) {
        goto("/");
    }

    let mode: 'signup' | 'login' | 'welcome';

    function next() {

    }

    onMount(() => {
        if (!!window.nostr) {
            mode ??= 'login';
        } else {
            mode = 'signup';
        }
    })

    
</script>

<div
	class="container relative hidden h-[calc(100dvh-80px)] flex-col items-center justify-center md:grid lg:max-w-none lg:grid-cols-2 lg:px-0"
>
	<div class="bg-muted relative hidden h-full flex-col p-10 text-white lg:flex dark:border-r">
		<div
			class="absolute inset-0 bg-cover"
			style="
				background-image:
					url(https://images.unsplash.com/photo-1590069261209-f8e9b8642343?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1376&q=80);"
		/>
		<div class="relative z-20 mt-auto">
			<blockquote class="space-y-2">
				<p class="text-lg">
					&ldquo;This library has saved me countless hours of work and helped me deliver
					stunning designs to my clients faster than ever before. Highly
					recommended!&rdquo;
				</p>
				<footer class="text-sm">Sofia Davis</footer>
			</blockquote>
		</div>
	</div>
	<div class="lg:p-8">
		<div class="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
			{#if mode === 'signup'}
                <Session.Signup bind:mode bind:title on:signed-up={next} />
            {:else if mode === 'login'}
                <div class="w-full flex flex-col gap-5">
                    <Session.Login bind:mode bind:title on:logged-in={next} />
                </div>
            {:else if mode === 'welcome'}
                <div class="w-full flex flex-col gap-5">
                    <!-- <Session.Welcome /> -->
                </div>
            {/if}
		</div>
	</div>
</div>