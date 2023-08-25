<script lang="ts">
	import { NDKDVMJobResult } from '@nostr-dev-kit/ndk';
	import { NDKDVMJobFeedback } from '@nostr-dev-kit/ndk';
	import { unseenEvents } from "$stores/notifications";
	import CollapsableDropdown from "./CollapsableDropdown.svelte";
	import JobFeedbackRow from "./jobs/JobFeedbackRow.svelte";
	import JobResultRow from "./jobs/JobResultRow.svelte";
	import JobStatusLabel from './jobs/JobStatusLabel.svelte';

</script>

{#if $unseenEvents}
    <CollapsableDropdown>
        <div class="badge rounded-full w-10 h-10 bg-gradient-to-r from-gradient1 to-gradient2 text-white font-semibold text-normal" slot="dropdown-button">
            <span class="badge bg-base-100 w-8 h-8 text-base-100-content">
                {$unseenEvents.length}
            </span>
        </div>

        <div class="max-h-96 overflow-y-auto overflow-x-hidden">
            <ul class="menu rounded-box">
                {#each $unseenEvents as unseenEvent (unseenEvent.id)}
                    <li class="max-w-lg w-screen">
                        <div class="flex flex-row justify-between">
                            {#if unseenEvent.kind === 7000}
                                <div class="shrink">
                                    {unseenEvent.content}
                                </div>
                                <JobStatusLabel
                                    event={new NDKDVMJobFeedback(undefined, unseenEvent.rawEvent())}
                                />
                            {/if}
                        </div>
                    </li>
                {/each}
            </ul>
        </div>
    </CollapsableDropdown>
{/if}