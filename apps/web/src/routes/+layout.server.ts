import 'websocket-polyfill';
import { configureBeNDK } from '$utils/ndk';
import { ndk } from "$stores/ndk";
import { get } from 'svelte/store';
import { RELAY_PRIVATE_KEY } from '$env/static/private';
import { NDKEvent, NDKKind, NDKList, NDKPublishError, NDKRelaySet, NDKSimpleGroupMemberList, NDKSubscription, NDKSubscriptionStart } from '@nostr-dev-kit/ndk';
import createDebug from "debug";
import { defaultRelays } from '$utils/const';

const d = createDebug('HL:sub-monitor');

export const ssr = false;

if (!RELAY_PRIVATE_KEY) {
	throw new Error('No private key provided');
}

// define load function
const $ndk = get(ndk);

if (!$ndk.explicitRelayUrls || $ndk.explicitRelayUrls.length === 0) {
	if (!$ndk.explicitRelayUrls || $ndk.explicitRelayUrls.length === 0) {
		await configureBeNDK(RELAY_PRIVATE_KEY, fetch);
	}
}

let eosed = false;
const myPubkey = import.meta.env.VITE_CREATOR_RELAY_PUBKEY;
const groupIds = new Set<string>();
const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
let groupsWhereRelayIsAdmin: NDKSubscription;
let subscribes: NDKSubscription;

d("myPubkey", myPubkey);


/**
 * Monitors for payments to each group the relay is an admin for
 */
async function updateSubscription() {
	d("updating subscription", groupIds);
	if (subscribes) subscribes.stop();

	const memberLists = await $ndk.fetchEvents([
		{ kinds: [ NDKKind.GroupMembers ], "#d": Array.from(groupIds) }
	], { subId: 'group-members' }, relaySet);
	const memberListByGroupId = new Map<string, NDKSimpleGroupMemberList>();
	for (const event of memberLists) {
		const groupId = event.dTag!;
		if (memberListByGroupId.has(groupId)) {
			const prevValue = memberListByGroupId.get(groupId);
			d("already have member list for %s, prev %o, new %o", groupId, prevValue!.rawEvent(), event.rawEvent());
		}

		// add the mmember list to the map
		const list = NDKSimpleGroupMemberList.from(event);
		memberListByGroupId.set(groupId, list);
	}

	const table: Record<string, string> = {};
	for (const [groupId, memberList] of memberListByGroupId) {
		table[groupId] = memberList.members.map(k => k.slice(0, 6)).join(',');
	}
	console.table(table);
	// d("memberListByGroupId", memberListByGroupId);
	
	subscribes = $ndk.subscribe([
		{ kinds: [7001, 9021], "#h": Array.from(groupIds) }
	], { groupable: false, subId: 'join-reqs' }, relaySet);
	subscribes.on("event", async (event) => {
		const groupId = event.tagValue("h");
		if (!groupId) {
			d("no groupId", event.rawEvent());
			return;
		}
		const memberList = memberListByGroupId.get(groupId);
		if (!memberList) d("no memberList for", groupId);
		
		if (memberList?.hasMember(event.pubkey)) {
			d("already have member", event.pubkey, "in group", groupId);
			return;
		}

		d("new request for group %s from %s", groupId, event.pubkey);

		// this is a subscription start request, which is what we want to focus on
		if (event.kind === 7001) {
			const subStart = NDKSubscriptionStart.from(event);
			processSubscriptionStart(subStart);
		}
	});
}

function processSubscriptionStart(subStart: NDKSubscriptionStart) {
	const _ = d.extend("sub["+subStart.id.slice(0,6)+"]");
	_("Processing subscription start %o", subStart.tags);
	// wait for zap event
	const zaps = $ndk.subscribe([
		{ kinds: [NDKKind.Nutzap], ...subStart.filter() },
		{ kinds: [NDKKind.Zap], ...subStart.filter() }
	], { groupable: false })
	zaps.on("event", async (event) => {
		_("Found a zap for subscription %o", event.rawEvent());

		processZap(event, subStart);
		
	});
	zaps.on("eose", () => {
		_("Zap subscription EOSED");
	});
}

/**
 * Monitors the groups this relay is an admin of
 */
function startGroupMembershipMonitor() {
	if (groupsWhereRelayIsAdmin) groupsWhereRelayIsAdmin.stop();
	eosed = false;
	d("starting group membership monitor for %s", myPubkey);
	groupsWhereRelayIsAdmin = $ndk.subscribe([
		{ kinds: [ NDKKind.GroupAdmins ], "#p": [ myPubkey ]}
	], { subId: 'group-admin', groupable: false }, relaySet);
	groupsWhereRelayIsAdmin.on("eose", () => { eosed = true; updateSubscription(); })
	groupsWhereRelayIsAdmin.on("event", (event) => {
		const groupId = event.dTag!;
		groupIds.add(groupId);
		d("adding group %s to relay monitor", groupId);
		if (eosed) updateSubscription();
	})
}

let monitorStarted = false;
if (!monitorStarted) {
	monitorStarted = true;
	startGroupMembershipMonitor();
} else {
	d("monitor already started");
}

async function validateZap(zap: NDKEvent, subStart: NDKSubscriptionStart) {
	return true;
}


async function processZap(zap: NDKEvent, subStart: NDKSubscriptionStart) {
	if (await validateZap(zap, subStart)) {
		await addMemberToGroup(zap, subStart);
		await ackZap(zap, subStart);
	} else {

	}
}

async function addMemberToGroup(zap: NDKEvent, subStart: NDKSubscriptionStart) {
	const groupId = subStart.tagValue("h")!;
	const addMember = new NDKEvent($ndk);
	addMember.kind = 9000;
	addMember.tags.push(["h", groupId]);
	addMember.tags.push(["p", subStart.pubkey]);
	try {
		await addMember.publish(relaySet);
	} catch (e: NDKPublishError) {
		console.error('failed to add member to group', e.relayErrors);
	}
}

async function ackZap(zap, subStart) {

}