import type { User } from '@prisma/client';
import type { RequestEvent } from '@sveltejs/kit';
import { JWT_ACCESS_SECRET } from '$env/static/private';
import jwt from 'jsonwebtoken';
import createDebug from 'debug';

const d = createDebug('HL:auth');

const { verify } = jwt;

export async function authenticateUser(event: RequestEvent): Promise<User | null> {
	d(`authenticateUser`);
	const authCookie = event.cookies.get('jwt');

	if (!authCookie) {
		d(`No auth cookie`);
		return null;
	}

	let jwtUser: User;
	try {
		jwtUser = await verify(authCookie, JWT_ACCESS_SECRET) as User;
	} catch (error) {
		d(`Error verifying jwt`);
		console.log(error);
		return null;
	}

	// const user = db.user.findUnique({
	//     where: { id: jwtUser.id }
	// })

	return jwtUser;
}
