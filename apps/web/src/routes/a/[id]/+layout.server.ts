import { ssrFetchEventFromCache } from '$utils/ssr.js';
import createDebug from 'debug';

const d = createDebug('HL:/a/[id]/+layout.server.ts');

// export async function load({ params }) {
//     const { id } = params;
//     d(`Loading event ${id}`);
//     const { event } = await ssrFetchEventFromCache(id);
//     d("returning", !!event)
//     if (event) return { event: event.rawEvent() };
//     return {};
// }