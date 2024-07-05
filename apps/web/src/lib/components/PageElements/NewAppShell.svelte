<script lang="ts">
    import { Badge } from "$lib/components/ui/badge/index.js";
    import { Button } from "$lib/components/ui/button/index.js";
    import * as Card from "$lib/components/ui/card/index.js";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import { Input } from "$lib/components/ui/input/index.js";
    import * as Sheet from "$lib/components/ui/sheet/index.js";
	import { Bell, BoxArrowDown, BoxArrowUp, CardsThree, CaretCircleDoubleDown, ChartLine, Hamburger, House, MagnifyingGlass, Package, UserCircle, Users } from "phosphor-svelte";
	import LayoutHeader from "./AppShell/LayoutHeader.svelte";
	import { layout } from "$stores/layout";
	import WalletState from "$components/Layout/Headers/WalletState.svelte";
  </script>
  
  <div class="grid min-h-screen w-full md:grid-cols-[360px_1fr] lg:grid-cols-[360px_1fr]">
    <div class="hidden border-r md:block">
      <div class="flex h-full max-h-screen flex-col gap-2">
        <div class="flex h-14 items-center border-b px-4 lg:h-[60px]">
            <WalletState />
        </div>
        <div class="flex-1 overflow-x-auto scrollbar-hide">
            {#if $layout?.sidebar}
                <svelte:component this={$layout.sidebar.component} {...$layout.sidebar.props} />
            {/if}
        </div>
        <div class="mt-auto">
            {#if $layout?.footer}
                <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
            {/if}
        </div>
      </div>
    </div>
    <div class="flex flex-col">
        {#if $layout?.header}
            <header class="flex h-14 items-center gap-4 border-b px-4 lg:h-[60px] lg:px-6">
                <LayoutHeader />
            </header>
        {/if}
        <main class="flex flex-1 flex-col gap-4 p-4 lg:gap-6 lg:p-6">
                <slot />
        </main>
    </div>
  </div>
  