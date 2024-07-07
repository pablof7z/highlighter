import { ndk } from "$stores/ndk";
import type { NDKEvent, NDKSimpleGroup, NDKUser } from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';
import { vanityUrlsByPubkey } from './const';
import { isMobileBuild } from './view/mobile';

export const EVENT_ID_SUFFIX_LENGTH = 999;

const BASE_URL = import.meta.env.VITE_BASE_URL;

export function getAuthorUrlSync(user: NDKUser) {
	if (vanityUrlsByPubkey[user.pubkey])
		return `/${vanityUrlsByPubkey[user.pubkey]}`;

	// todo add a sync function for getting nip05s from the cache

	return `/${user.npub}`;
}

export function getEventUrl(event: NDKEvent, authorUrl?: string, extraPath?: string) {
	const url = new URL("", window.location.href);

	authorUrl ??= getAuthorUrlSync(event.author);
	
	if (authorUrl.startsWith("/npub1")) authorUrl = undefined;

	if (!isMobileBuild()) {
		const path: string[] = [];

		if (event.isParamReplaceable() && authorUrl) {
			const dTag = event.tagValue("d");
			if (dTag && dTag.length > 0 && authorUrl) {
				path.push(authorUrl);
				path.push(dTag)
			} else {
				path.push("a")
				path.push(event.encode());
			}
		} else {
			path.push("a");
			path.push(event.encode());
		}
		
		if (extraPath) path.push(extraPath);

		url.pathname = path.join("/");
	} else {
		url.pathname = "/mobile/view";
		url.searchParams.set("eventId", event.encode());
		if (extraPath) url.searchParams.set("view", extraPath);
		else url.searchParams.delete("view");
	}

	return url.toString();
}

export function getGroupUrl(group: NDKSimpleGroup, extraPath?: string) {
	const url = new URL("", window.location.href);

	if (!isMobileBuild())
		url.pathname = `/communities/${group.groupId}/${extraPath ?? ""}`;
	else {
		url.pathname = "/mobile/community";
		url.searchParams.set("groupId", group.groupId);
		if (extraPath) url.searchParams.set("view", extraPath);
	}

	if (group.relaySet.size > 0) {
		url.searchParams.set("relays", Array.from(group.relaySet.relayUrls).join(","));
	}
	
	return url.toString();
}

export function getUserUrl(
	authorUrl: string,
	user: NDKUser,
	path: string
) {
	if (isMobileBuild()) {
		return `/mobile/profile?view=${encodeURI(path)}&userId=${user.npub}`;
	} else {
		return `/${authorUrl}/${path}`;
	}
}

export async function getAuthorUrl(user: NDKUser) {
	const $ndk = get(ndk);

	// prefer vanity urls
	if (vanityUrlsByPubkey[user.pubkey])
		return `/${vanityUrlsByPubkey[user.pubkey]}`;

	if (
		$ndk.cacheAdapter?.locking &&
		$ndk.cacheAdapter?.fetchProfile
	) {
		const profile = await $ndk.cacheAdapter!.fetchProfile(user.pubkey);

		if (profile && profile.nip05) {
			return `/${profile.nip05}`;
		}
	}

	return `/${user.npub}`;
}

export function urlFromEvent(
	event: NDKEvent,
	authorUrl?: string,
	fullUrl = false
): string {
	const url: string[] = [];

	// mobile builds use fixed URLs with arguments as parameters
	if (!fullUrl && isMobileBuild()) {
		if (event.isParamReplaceable()) {
			return `/a?eventId=${event.encode()}`;
		} else {
			return `/e?eventId=${event.encode()}`;
		}
	}

	authorUrl ??= getAuthorUrlSync(event.author);

	if (authorUrl.startsWith("/npub1")) authorUrl = undefined;

	if (fullUrl) url.push("https://highlighter.com");//BASE_URL);

	// strip prefix / from authorUrl
	if (authorUrl && authorUrl[0] === '/') authorUrl = authorUrl.slice(1);

	if (event.isParamReplaceable() && authorUrl) {
		const dTag = event.tagValue("d");
		if (dTag && dTag.length > 0 && authorUrl) {
			url.push(authorUrl);
			url.push(dTag)
		} else {
			url.push("a")
			url.push(event.encode());
		}
	} else {
		url.push("a");
		url.push(event.encode());
	}

	let u = url.join("/");

	if (!fullUrl) u = "/" + u;

	return u;
}

export function urlSuffixFromEvent(event: NDKEvent): string {
	if (event.isParamReplaceable()) {
		return encodeURIComponent(event.tagValue('d')!);
	} else {
		return event.encode();
	}

}

export function urlSuffixFromTagId(tagId: string): string {
	const dTag = tagId.split(':')[2];

	if (dTag) {
		return dTag;
	}

	return tagId;
}
