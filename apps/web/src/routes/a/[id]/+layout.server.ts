import { fetchEvent } from '$utils/ssr.js';

export async function load({ params }) {
    const { id } = params;

    return fetchEvent(id);
}