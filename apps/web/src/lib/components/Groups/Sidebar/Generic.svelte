<script lang="ts">
    import * as Groups from "$components/Groups";
    import * as Chat from "$components/Chat";
	import { groupsList } from "$stores/session";
</script>

{#if $groupsList && $groupsList.items.length > 0}
    <div class="divide-y divide-border flex flex-col border-b">
        <Groups.RootList tags={$groupsList.items} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    </div>
{/if}