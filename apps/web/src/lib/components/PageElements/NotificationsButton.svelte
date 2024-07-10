<script lang="ts">
	import { Button } from "$components/ui/button";
	import { Bell } from "phosphor-svelte";
	import NotificationIndicator from "./NotificationIndicator.svelte";
	import { longpress } from "$actions/long-press";

</script>

<NotificationIndicator class="flex-none shrink basis-0">
    <Button href="/notifications" variant="outline">
        <Bell size={24} />
    </Button>
</NotificationIndicator>