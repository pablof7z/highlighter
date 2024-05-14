import { userFollows } from '$stores/session';
import { searchUser } from '$utils/search/user';
import {ndk} from '@kind0/ui-common';
import { get } from 'svelte/store';



export default async function(searchTerm, renderList) {
    const $ndk = get(ndk);
    const $userFollows = get(userFollows);
    const result = await searchUser(searchTerm, $ndk, $userFollows);
    renderList(result);
}