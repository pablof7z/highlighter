import type { Session, UserUploadQuota } from "../../../app";
import { json } from "@sveltejs/kit";
import createDebug from "debug";

const debug = createDebug("highlighter:/api/user");

async function getUserUploadQuota(pubkey: string): Promise<UserUploadQuota> {
    debug('getUserUploadQuota', {pubkey});
    return {
        used: 0,
        total: 100000000,

    }
}

export async function GET({locals}) {
    const {pubkey} = locals.session as Session;

    return json({
        uploads: {
            quota: await getUserUploadQuota(pubkey),
        }
    })
}