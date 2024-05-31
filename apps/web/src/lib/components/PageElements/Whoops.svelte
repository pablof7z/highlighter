<script lang="ts">
    export let message: string;
    export let devMessage: string | undefined = undefined;

    function clicked() {
        window.location.href = "/";
    }
</script>

<div class="fixed max-w-lg top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-center">
    <h1>
        Whoops! We've encountered an error.
    </h1>

    <h2>
        {message}
    </h2>

    {#if process.env.NODE_ENV === "development"}
        {#if devMessage}
            <p>{devMessage}</p>
        {/if}
    {/if}

    <button class="button button-primary" on:click={clicked}>
        Continue
    </button>
</div>