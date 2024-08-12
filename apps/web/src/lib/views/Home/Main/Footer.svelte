<script lang="ts">
	import { MagnifyingGlass } from "phosphor-svelte";
	import Input from "$components/ui/input/input.svelte";
	import { goto } from "$app/navigation";
    import * as Footer from "$components/Footer";
    import Explore from "$components/Footer/Views/Explore";

    import NewItem from "$components/Footer/Views/NewItem";
	import Search from "$views/Search.svelte";

    export let placeholder: string | undefined = "Explore";
    export let value: string = "";
    let mainView: string = 'search';

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
    {views}
>
</Footer.Shell>