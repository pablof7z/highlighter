import { redirect, type Handle } from '@sveltejs/kit';
import { authenticateUser } from '$lib/utils/authentication';

const AUTH_PATHS = [
	'/api/user',
	'/api/user/nwa',
	'/api/user/nwc',
	'/api/user/wallet/balance',
	'/api/user/pay',
	'/api/user/subscribe',
	'/api/user/upload',
	'/api/stripe'
];

export const handle: Handle = async ({ event, resolve }) => {
	// Convert strings to regular expressions and check if path matches
	const isAuthPath = AUTH_PATHS.some((path) => {
		const regex = typeof path === 'string' ? new RegExp(`^${path}$`) : path;
		return event.url.pathname.match(regex);
	});

	if (isAuthPath) {
		event.locals.session = await authenticateUser(event);

		if (!event.locals.session) {
			redirect(301, '/');
		}
	}

	const response = await resolve(event, {
		preload: ({ type, path }) => type === 'font'
	});
	// response.headers.delete('link');
	return response;
};
