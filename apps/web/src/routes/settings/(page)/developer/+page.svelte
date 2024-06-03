<script lang="ts">
    import { pageHeader } from "$stores/layout";
	import NDKCacheAdapterDexie, { db } from '@nostr-dev-kit/ndk-cache-dexie';
	import { ndk } from "$stores/ndk";
	import { browser } from '$app/environment';
	import { networkFollows, userFollows } from '$stores/session';
	import { minimumScore, wot } from '$stores/wot';
	import Checkbox from '$components/Forms/Checkbox.svelte';
	import { devMode } from '$stores/settings';

    $pageHeader = {
        title: "Highlighter",
        left: {
            label: "Back",
            url: "/settings",
        }
    };

    let lruProfileCount: number | undefined

    let cachedEventKinds: Record<number, number>;
    let cachedProfileCount: number | undefined;

    function updateCacheCounts() {
        db.events.each((row) => {
            cachedEventKinds[row.kind] = (cachedEventKinds[row.kind] || 0) + 1
        })
        db.users.count().then(c => cachedProfileCount = c);

        cachedEventKinds = cachedEventKinds;
    }

    $: if (browser && !cachedEventKinds) {
        cachedEventKinds = {};
        lruProfileCount = ($ndk.cacheAdapter as NDKCacheAdapterDexie).profiles?.size()

        setInterval(updateCacheCounts, 1000);
    }

    updateCacheCounts();
</script>

<section class="settings">
    <div class="field">
        <div class="title">
            Developer Mode
        </div>

        <Checkbox bind:value={$devMode}>
            Developer Mode
            <span class="text-sm" slot="description">
                Enable additional debugging information and tools.
            </span>
        </Checkbox>
    </div>
</section>
<section class="settings">
    <div class="title">
        Database
    </div>

    <div class="field">
        <div class="title">Web-of-trust</div>
        <table class="table">
            <tr>
                <td>Follows</td>
                <td>{$userFollows.size}</td>
            </tr>
            <tr>
                <td>Network size</td>
                <td>{$networkFollows.size}</td>
            </tr>
            <tr>
                <td>WOT size</td>
                <td>{$wot.size}</td>
            </tr>
            <tr>
                <td>WOT required score</td>
                <td>
                    <input type="number" bind:value={$minimumScore} class="input w-24" />
                </td>
            </tr>
        </table>
    </div>

    {#if lruProfileCount}
        <div class="field">
            <div class="title">Profiles in LRU</div>
            <div class="value">{lruProfileCount}</div>
        </div>
    {/if}

    {#if db}
        <div class="field">
            <div class="title">Cached events</div>
            <table class="table">
                <tbody>
                    {#if cachedProfileCount}
                        <tr>
                            <td>Profiles</td>
                            <td>{cachedProfileCount}</td>
                        </tr>
                    {/if}
                    {#each Object.entries(cachedEventKinds) as [kind, count]}
                        <tr>
                            <td>Event kind {kind}</td>
                            <td>{count}</td>
                        </tr>
                    {/each}
                </tbody>
            </table>
        </div>
    {/if}
</section>