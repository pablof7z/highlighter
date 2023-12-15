import {sequence} from "@sveltejs/kit/hooks";
import * as Sentry from "@sentry/sveltekit";
import { redirect, type Handle } from "@sveltejs/kit";
import { authenticateUser } from "$lib/utils/authentication";

Sentry.init({
    dsn: "https://a63e57721efe045140239736daf0d675@o317830.ingest.sentry.io/4506382142799872",
    tracesSampleRate: 1
})

const AUTH_PATHS = [
    "/api/user/nwc",
    "/api/user/pay",
    "/api/user/create-zap-request",
    "/api/user/pay-zap-request",
];

export const handle: Handle = sequence(Sentry.sentryHandle(), async ({ event, resolve }) => {
    // check if path is in AUTH_PATHS
    if (!AUTH_PATHS.some(path => event.url.pathname.startsWith(path))){
        return await resolve(event);
    }

    event.locals.session = await authenticateUser(event);

    if (!event.locals.session) {
        throw redirect(301, "/")
    }

    return await resolve(event);
});
export const handleError = Sentry.handleErrorWithSentry();