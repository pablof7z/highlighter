import { redirect, type Handle } from "@sveltejs/kit";
import { authenticateUser } from "$lib/utils/authentication";

const AUTH_PATHS = [
    "/api/user/nwc",
    "/api/user/pay",
    "/api/user/create-zap-request",
];

export const handle: Handle = async ({ event, resolve }) => {
    // check if path is in AUTH_PATHS
    if (!AUTH_PATHS.some(path => event.url.pathname.startsWith(path))){
        return await resolve(event);
    }

    event.locals.session = await authenticateUser(event);

    if (!event.locals.session) {
        throw redirect(301, "/")
    }

    return await resolve(event);
};
