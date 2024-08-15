<script lang="ts">
	import { Door, MagnifyingGlass, Wall, Wallet } from "phosphor-svelte";
	import { goto } from "$app/navigation";
    import * as Footer from "$components/Footer";
    import Explore from "$components/Footer/Views/Explore";

    import NewItem from "$components/Footer/Views/NewItem";
	import ToggleDark from "$components/buttons/ToggleDark.svelte";
	import { Button } from "$components/ui/button";
	import { logout } from "$utils/login";
	import CurrentUser from "$components/CurrentUser.svelte";

    export let placeholder: string | undefined = "Explore";
    export let value: string = "";
    let mainView: string;

    function onkeydown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            goto('/search?q=' + encodeURIComponent(value));
        }
    }

    let open: Footer.OpenFn;

    let views: Footer.FooterView[] = [
        NewItem,
        Explore
    ];
    
</script>

<Footer.Shell
    bind:open
    bind:mainView
    {views}
>
    <div slot="main">
        {#if mainView === 'main'}
            <div class="flex flex-col gap-2">
                <Button variant="outline" class="w-full text-left items-center justify-start py-4 h-auto">
                    <Wallet class="w-6 h-6 mr-2" />

                    Setup Wallet
                </Button>
                
                <ToggleDark variant="outline" class="w-full text-left items-center justify-start py-4 h-auto">
                    Toggle light/dark
                </ToggleDark>

                <div class="flex max-sm :flex-col flex-row gap-4 items-stretch w-full">
                    <Button href="/settings/profile" variant="outline" class="w-full text-left items-center justify-start py-4 h-auto">
                        Edit Profile
                    </Button>
                    <Button variant="outline" on:click={logout} class="w-full text-left items-center justify-start py-4 h-auto">
                        <Door class="w-6 h-6 mr-2" />
                        Logout
                    </Button>
                </div>
            </div>
        {/if}
    </div>
</Footer.Shell>