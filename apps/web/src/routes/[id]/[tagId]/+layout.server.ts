import { EVENT_ID_SUFFIX_LENGTH } from '$utils/url';
import type { NDKFilter } from '@nostr-dev-kit/ndk';
import { getUserFromUrlId } from '$utils/user/from-url-id.js';
import { ssrFetchEventFromCache } from '$utils/ssr.js';
import createDebug from 'debug';

const d = createDebug('HL:/[id]/[tagId]/+layout.server.ts');

// export async function load({ params }) {
// 	const { id } = params;
// 	let { tagId } = params;

// 	tagId = decodeURIComponent(tagId);

// 	d(`Loading event ${tagId} for user ${id}`);
// 	const {user} = await getUserFromUrlId(id);
// 	if (user) {
// 		const filters: NDKFilter[] = [{ authors: [user.pubkey], '#d': [tagId] }];
// 		const regex = new RegExp(`^[0-9a-fA-F]{${EVENT_ID_SUFFIX_LENGTH}}$`);
// 		if (tagId.match(regex)) {
// 			filters.push({ ids: [tagId] });
// 		}
// 		d("fetching", filters)
// 		const {event} = await ssrFetchEventFromCache(filters);
// 		d("returning", !!event)
// 		if (event) return { event: event.rawEvent() };
// 	}
// 	d(`No event found for ${tagId}`);

// 	return {};
// }
