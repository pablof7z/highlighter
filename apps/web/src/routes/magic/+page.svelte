<script lang="ts">
    import Logo from '$icons/Logo.svelte';
</script>

<div class="max-w-5xl mx-auto flex flex-col gap-8">
    <div class="flex flex-row gap-6 items-center">
        <Logo />
        <div class="flex flex-col gap-2">
            <h1 class="text-7xl font-black tracking-wide">Magic</h1>
            <div class="text-lg text-accent">
                There are many things that make using and working with DVMs a bit of a magical experience.
            </div>
        </div>
    </div>

    <div class="grid grid-cols-2 gap-6">
        <div class="card card-compact rounded-box">
            <div class="card-body !text-base">
                <div class="card-title text-base-100-content font-bold">
                    Global improvements
                </div>

                <p>Once a Nostr app supports DVMs that means that they get immediate access to all features,
                    algorithms, and crazy inventions all DVMs support.</p>

                <p>
                    Don't like your client's default <em>Trending</em> algorithm? Pick from hundreds of different
    algorithms. Your Highlighter client doesn't work well when trying to read an obscure PDF?
    Use a DVM that has better support for it.
                </p>

                <p>
                    You say the spam filtering in your client is too aggressive? or not aggressive enough? Just choose
    from a different spam-filtering DVM!
                </p>
            </div>
        </div>

        <div class="card card-compact rounded-box">
            <div class="card-body !text-base">
                <div class="card-title text-base-100-content font-bold">
                    Long-tail
                </div>

                <p>Because discoverability of these algorithms is solved by the very use of Nostr, we can easily imagine
                    a future where there are thousands of very specific, very niche and abundantly weird DVMs providing all
                    kinds of obscure functionalities.</p>

                <p>
                    Even if a DVM only had a handful of users, it would still be worth it for its users and for the DVM.
                </p>
            </div>
        </div>

        <div class="card card-compact rounded-box">
            <div class="card-body !text-base">
                <div class="card-title text-base-100-content font-bold">
                    Reusable results
                </div>

                <p>
                    Every time a Nostr client autotranslates a note, it pings a specific API ndpoint to get the
                    result translated.
                </p>

                <p>
                    Over, and over. The same text being translated by each user.
                </p>

                <p>
                    Since Data Vending Machine results are public by default, once a note has been ranslated,
                    all clients can choose to reuse the same translation.
                </p>
            </div>
        </div>
    </div>
</div>
