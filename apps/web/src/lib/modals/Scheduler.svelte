<script lang="ts">
import ModalShell from "$components/ModalShell.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { ndk } from "$stores/ndk.js";
import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import { NDKEvent, dvmSchedule } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";
	import { closeModal } from '$utils/modal';
	import ScheduleModal from "./ScheduleModal.svelte";

    export let event: NDKEvent;

    // make this configurable
    const dvmUser = $ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});

    let publishAtVal: string | undefined;
    let publishAt: number | undefined = Date.now() + 1000 * 60 * 60;
    publishAtVal = new Date(publishAt).toISOString().slice(0, 16);

    $: if (publishAtVal) {
        try {
            const date = new Date(publishAtVal);
            if (date.getTime() > Date.now()) { publishAt = date.getDate(); }
        } catch(e) { publishAt = undefined }
    }

    function setTime(minutes: number) {
        return () => {
            publishAt = Date.now() + minutes * 60 * 1000;
            // publishAtVal = new Date(publishAt).toISOString().slice(0, 16);
        }
    }

    function setRelativeTime(inXDays: number, atYHour: number) {
        return () => {
            const date = new Date();
            date.setDate(date.getDate() + inXDays);
            date.setHours(atYHour, 0, 0, 0);
            publishAt = date.getTime();
            // publishAtVal = date.toISOString().slice(0, 16);
        }
    }

    let disabled = false;

    $: disabled = !publishAt || publishAt < Date.now();

    let scheduling = false;
    let scheduled = false;

    async function schedule(time: number) {
        scheduling = true;
        try {
            if (!time) return;
            const repost = await event.repost(false);
            repost.created_at = Math.floor(time / 1000);
            repost.id = "";
            repost.sig = "";
            await repost.sign();

            const confirm = await dvmSchedule(repost, dvmUser, undefined, true, 3000);
            console.log(confirm);
            scheduled = true;
            setTimeout(() => closeModal(), 1500);
        } finally {
            scheduling = false;
        }
    }
</script>

<ScheduleModal
    title="Schedule Boost"
    onSchedule={schedule}
    action="Repost will be published&nbsp;"
/>
