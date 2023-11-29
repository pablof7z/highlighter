import "websocket-polyfill";

import { json } from "@sveltejs/kit"
import createDebug from "debug";
import type { Session } from "../../../../app.js";
import { sendPayment } from "$lib/backend/pay.js";


const log = createDebug("shipyard:/api/posts");

type Payload = {
    nwc: string;
}



export async function POST({request, locals}) {
    const {pubkey} = locals.session as Session;
    const payload = await request.json();
    const { invoice } = payload as Payload;

    try {
        const payment = await sendPayment(invoice, pubkey);
        return json(payment);
    } catch (error: any) {
        console.log('err', {error});
        log(error);
        return json(error, { status: 400 });
    }
}
