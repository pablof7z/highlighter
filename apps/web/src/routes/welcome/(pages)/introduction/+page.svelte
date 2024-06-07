<script lang="ts">
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import { HandWaving } from "phosphor-svelte";
</script>

<BlankState
    cta="Write your introduction"
    class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
>
    <p>You walk into a new place and you do... <em>what?</em></p>

    <p>Well, introduce yourself, of course.</p>

    <p>
        This is your chance to make an impression here, put up a bat-signal to
        tell people what you care about.
    </p>
</BlankState>

<NewPost
    kind={1}
    placeholder="Write your introduction..."
/>