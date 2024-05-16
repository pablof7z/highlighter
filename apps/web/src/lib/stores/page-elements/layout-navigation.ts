import { derived } from "svelte/store";
import { NavigationOption } from "../../../app";
import { Bell, BookmarkSimple, House } from "phosphor-svelte";
import currentUser, { isGuest } from "$stores/currentUser";
import { hasUnreadNotifications, unreadNotifications } from "$stores/notifications";

export const options = derived(
    [ currentUser, isGuest, hasUnreadNotifications!, unreadNotifications!], ([
        $currentUser,
        $isGuest,
        $hasUnreadNotifications,
        $unreadNotifications
    ]) => {
    const options: NavigationOption[] = [];

    options.push({ name: "Home", icon: House, href: "/home" })
    options.push({ name: "Bookmarks", icon: BookmarkSimple, href: "/bookmarks" })

    if ($currentUser && (!$isGuest || $hasUnreadNotifications)) {
        options.push(
            { name: "Notifications", icon: Bell, href: "/notifications", badge: $hasUnreadNotifications ? $unreadNotifications?.toString() : undefined }
        );
    }
    
    return options;
});