<script lang="ts">
	import { Bell, DollarSign, Home } from 'lucide-svelte';
	import { Image, Link1, Timer } from 'svelte-radix';
	import { cubicInOut } from 'svelte/easing';
	import { crossfade } from 'svelte/transition';
	import { Button } from '../ui/button';
	import { cn } from '@/utils';

    const [send, receive] = crossfade({
		duration: 250,
		easing: cubicInOut,
	});
    
    let {
        selectedSetting = $bindable()
    } = $props();

    const data = {
		nav: [
			{ name: 'Media Servers', icon: Image },
			{ name: 'Relays', icon: Home },
            { name: 'Notifications', icon: Bell },
			{ name: 'Monetization', icon: DollarSign }
		]
	};
</script>

<div class="flex flex-col">
    {#each data.nav as item (item.name)}
        {@const isActive = selectedSetting === item.name}
    
        <Button
            variant="ghost"
            class={cn(
				"relative justify-start hover:bg-transparent"
			)}
			data-sveltekit-noscroll
            onclick={() => selectedSetting = item.name}
        >
            {#if isActive}
                <div
                    class="bg-muted absolute inset-0 rounded-md"
                    in:send={{ key: "active-sidebar-tab" }}
                    out:receive={{ key: "active-sidebar-tab" }}
                >
                </div>
            {/if}
            <div class="relative flex items-center gap-2">
				<item.icon />
                <span>{item.name}</span>
			</div>
        </Button>
    {/each}
</div>

<style lang="postcss">
    .active {
        @apply text-foreground bg-muted;
    }
</style>