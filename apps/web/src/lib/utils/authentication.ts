import type { User } from "@prisma/client";
import type { RequestEvent } from "@sveltejs/kit"
import { JWT_ACCESS_SECRET } from "$env/static/private"
import jwt from "jsonwebtoken";

const { verify } = jwt;

export async function authenticateUser(event: RequestEvent): Promise<User | null> {
    const authCookie = event.cookies.get("jwt");

    if (!authCookie) {
        return null
    }

    let jwtUser: User;
    try {
        jwtUser = verify(authCookie, JWT_ACCESS_SECRET) as User
    } catch (error) {
        console.log(error)
        return null
    }

    // const user = db.user.findUnique({
    //     where: { id: jwtUser.id }
    // })

    return jwtUser
}