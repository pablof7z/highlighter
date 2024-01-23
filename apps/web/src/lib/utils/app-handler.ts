import { get } from 'svelte/store';
import { userAppHandlers } from '$stores/session';
import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
import { ndk } from '@kind0/ui-common';

export async function writeAppHandler(kind: NDKKind, force = false) {
	if (!force) {
		const $userAppHandlers = get(userAppHandlers);

		// check if the user already has an app handler for this kind
		const kindIsAlreadyHandled = $userAppHandlers.get(kind);

		if (kindIsAlreadyHandled) return;
	}

	const $ndk = get(ndk);

	if (!$ndk.clientNip89) {
		throw new Error('Cannot write app handler without clientNip89');
	}

	const appHandlerEvent = new NDKEvent($ndk);
	appHandlerEvent.kind = NDKKind.AppRecommendation;
	let alt = `Event of kind ${kind} can be opened with this application`;
	if ($ndk.clientName) alt += `: ${$ndk.clientName}`;
	appHandlerEvent.alt = alt;
	appHandlerEvent.dTag = kind.toString();

	appHandlerEvent.tag(['a', $ndk.clientNip89]);

	await appHandlerEvent.publish();
}
