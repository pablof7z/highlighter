<script lang="ts">
	import { Button } from "$components/ui/button";

    export let message: string;
    export let devMessage: string | undefined = undefined;

    function clicked() {
        window.location.href = "/";
    }
</script>

<div class="fixed max-w-lg top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-center">
    <h1>
        Whoops!
    </h1>

    <h2>
        We've encountered an error.
    </h2>

    <h4 class="text-muted-foreground">
        {message}
    </h4>

    {#if process.env.NODE_ENV === "development"}
        {#if devMessage}
            <p>{devMessage}</p>
        {/if}
    {/if}

    <Button variant="accent" on:click={clicked}>
        Continue
    </Button>
</div>