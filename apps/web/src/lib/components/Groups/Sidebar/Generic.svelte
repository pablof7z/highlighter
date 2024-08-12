<script lang="ts">
    import * as Groups from "$components/Groups";
	import { groupsList } from "$stores/session";
</script>

{#if $groupsList && $groupsList.items.length > 0}
    <div class="divide-y divide-border flex flex-col border-b">
        <Groups.RootList tags={$groupsList.items} let:group>
            <Groups.ListItem {group} />
        </Groups.RootList>
    </div>
{/if}