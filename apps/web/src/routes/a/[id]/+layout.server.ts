import { fetchEvent } from '$utils/ssr.js';

export async function load({ params }) {
    const { id } = params;

    console.log('trying to fetch '+id);

    return fetchEvent(id);
}