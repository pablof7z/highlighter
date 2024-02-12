/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unused-vars */
import "websocket-polyfill";
import NDK, { NDKArticle, NDKEvent, NDKKind, NDKPrivateKeySigner, NDKRelay, NDKRelayAuthPolicies, NDKRelaySet, NDKSigner, NDKSimpleGroup, NDKSubscriptionStart, NDKSubscriptionTier, NDKTag, NDKUser, NostrEvent, PublishError } from "@nostr-dev-kit/ndk";
import { spawn } from 'child_process';
import { tmpdir } from 'os';
import { addGroupMember, createGroup } from "./nip29";
import { publishSubscriptionReceipt } from "./utils/nip88";

const relaySigner = NDKPrivateKeySigner.generate();

const ownerSigner = NDKPrivateKeySigner.generate();
const memberSigner = NDKPrivateKeySigner.generate();
const nonMemberSigner = NDKPrivateKeySigner.generate();

let relayUser: NDKUser;
let ownerUser: NDKUser;
let memberUser: NDKUser;
let nonMemberUser: NDKUser;

const START_RELAY=true;
const RELAY_PORT=START_RELAY ? 5588 : 5577;

const RELAY=`ws://localhost:${RELAY_PORT}`;
const RELAY_PK=relaySigner.privateKey!;
const RELAY_DATABASE_PATH=tmpdir();

const RELAY_DIR="/Users/pablofernandez/work/projects/highlighter/apps/relay/relay29";

let relayProcess: any | undefined;
let relaySet: NDKRelaySet;

const relayNdk = createNdk(relaySigner);
const ownerNdk = createNdk(ownerSigner);
const memberNdk = createNdk(memberSigner);
const nonMemberNdk = createNdk(nonMemberSigner);

const ownerTier = new NDKSubscriptionTier(ownerNdk);

beforeAll(async () => {
    if (START_RELAY) {
        relayProcess = spawn(
            `${RELAY_DIR}/relay29`, [], {
                detached: true,
                stdio: 'ignore',
                env: {
                    RELAY_URL: `ws://localhost:${RELAY_PORT}`,
                    PORT: RELAY_PORT.toString(),
                    RELAY_PRIVKEY: RELAY_PK,
                    RELAY_NAME: "Test relay",
                    DOMAIN: 'localhost',
                    DATABASE_PATH: RELAY_DATABASE_PATH
                }
            }
        )

        process.stdout.on('data', (data) => console.log(`RELAY: ${data}`));
        process.stderr.on('data', (data) => console.error(`RELAY: ${data}`));
    }

    relayUser = await relaySigner.user();
    ownerUser = await ownerSigner.user();
    memberUser = await memberSigner.user();
    nonMemberUser = await nonMemberSigner.user();

    await connectNdks([
        relayNdk,
        ownerNdk,
        memberNdk,
        nonMemberNdk
    ]);

    try {
        await createOwnerTiers();
        await subscribeMember();
    } catch (e: any) {
        console.log(e.relayErrors);
    }
})

async function createOwnerTiers() {
    ownerTier.addAmount(1000, "msats", "daily");
    ownerTier.title = "full-tier";
    await ownerTier.publish()
}

async function subscribeMember() {
    const subStart = new NDKSubscriptionStart(memberNdk);
    subStart.tier = ownerTier;
    subStart.amount = { amount: 1000, term: "daily", currency: "msats" };
    await subStart.sign();
    await subStart.publish();

    await publishSubscriptionReceipt(relayNdk, subStart);
}

afterAll(() => {
    relayProcess?.unref();
    relayProcess?.kill();
})

let creatorUser: NDKUser;
let groupId: string;

async function getGroup(ndk: NDK, groupId: string): Promise<NDKEvent | null> {
    const event = await ndk.fetchEvent({
        kinds: [NDKKind.GroupMetadata],
        "#d": [groupId]
    }, { groupable: false, closeOnEose: true });

    return event;
}

beforeEach(async () => {
    creatorUser = await ownerSigner.user();
    groupId = creatorUser.pubkey;
});


describe('nip29', () => {
    describe('createGroup', () => {
        it('creates a new group', async () => {
            // check there is no group
            let group = await getGroup(relayNdk, creatorUser.pubkey);
            expect(group).toBeNull();

            await createGroup(relayNdk, creatorUser, undefined, undefined, undefined, ownerSigner);

            group = await getGroup(relayNdk, creatorUser.pubkey);
            expect(group).not.toBeNull();
        })
    })

    describe('addGroupMember', () => {
        it('adds a member to the group', async () => {
            const group = new NDKSimpleGroup(ownerNdk, creatorUser.pubkey, relaySet);
            const membersBefore = await group.getMembers();
            const user = await NDKPrivateKeySigner.generate().user();

            await addGroupMember(ownerNdk, groupId, user.pubkey, relaySet);

            const membersAfter = await group.getMembers();

            expect(membersBefore.length+1).toEqual(membersAfter.length);
        })
    })

    describe('chat', () => {
        it ('owner can write chat messages', async () => {
            const chatEvent = new NDKEvent(ownerNdk, {
                kind: NDKKind.GroupChat,
                content: 'this should be accepted',
                tags: [ [ "h", groupId ] ]
            } as NostrEvent);
            await chatEvent.sign(ownerSigner);
            await chatEvent.publish();
            const fetchedEvent = await ownerNdk.fetchEvent(chatEvent.encode());
            expect(fetchedEvent).not.toBeNull();
        })

        it ('members can write chat messages', async () => {
            await addGroupMember(ownerNdk, groupId, memberUser.pubkey, relaySet);
            await sleep(500);

            const chatEvent = new NDKEvent(memberNdk, {
                kind: NDKKind.GroupChat,
                content: 'this should be accepted',
                tags: [ [ "h", groupId ] ]
            } as NostrEvent);
            await chatEvent.sign(memberSigner);

            try {
                await chatEvent.publish();
            } catch (e) {
                if (e instanceof PublishError)
                    console.log(e.relayErrors)
            }

            await sleep(1000);
            const fetchedEvent = await memberNdk.fetchEvent(chatEvent.encode());
            expect(fetchedEvent).not.toBeNull();
        })

        it ('non-members cant write chat messages', async () => {
            const chatEvent = new NDKEvent(nonMemberNdk, {
                kind: NDKKind.GroupChat,
                content: 'this should not be accepted',
                tags: [ [ "h", groupId ] ]
            } as NostrEvent);
            await chatEvent.sign(nonMemberSigner);
            await expect(chatEvent.publish()).rejects.toThrow();
            const fetchedEvent = await nonMemberNdk.fetchEvent(chatEvent.encode());
            expect(fetchedEvent).toBeNull();
        })
    })

    describe("requests", () => {
        it("non-subscribers receive only Free events", async () => {
            const {random} = await createArticleWithPreview();

            const fetchedEvents = await nonMemberNdk.fetchEvents({
                kinds: [NDKKind.Article],
                "#h": [groupId],
                "#T": [random]
            });

            expect(fetchedEvents.size).toEqual(1);
            expect(Array.from(fetchedEvents)[0].content).toEqual('preview article');
        })

        it("subscribers receive only events marked for their tier", async () => {
            const {random} = await createArticleWithPreview();

            const fetchedEvents = await memberNdk.fetchEvents({
                kinds: [NDKKind.Article],
                "#h": [groupId],
                "#T": [random]
            });

            expect(fetchedEvents.size).toEqual(1);
            expect(Array.from(fetchedEvents)[0].content).toEqual('full article');
        })

        it("when not specified, owners receive tiered events only", async () => {
            const {random} = await createArticleWithPreview();

            const fetchedEvents = await ownerNdk.fetchEvents({
                kinds: [NDKKind.Article],
                "#h": [groupId],
                "#T": [random]
            });

            expect(fetchedEvents.size).toEqual(1);
            expect(Array.from(fetchedEvents)[0].content).toEqual('full article');
        })

        it("when specified, owners can fetch Free events", async () => {
            const {random, preview} = await createArticleWithPreview();

            const fetchedEvents = await ownerNdk.fetchEvents({
                kinds: [NDKKind.Article],
                "#h": [groupId],
                "#d": [preview.dTag!],
                "#T": [random]
            });

            expect(fetchedEvents.size).toEqual(1);
            expect(Array.from(fetchedEvents)[0].content).toEqual('preview article');
        })

        describe("signatures", () => {
            it("owner gets signatures of tiered events", async () => {
                const {random} = await createArticleWithPreview();

                const fetchedEvents = await ownerNdk.fetchEvents({
                    kinds: [NDKKind.Article],
                    "#h": [groupId],
                    "#T": [random]
                });

                const event = Array.from(fetchedEvents)[0];
                expect(event.sig).not.toBe("");
            })

            it("members dont get signatures of tiered events", async () => {
                const {random} = await createArticleWithPreview();

                const fetchedEvents = await memberNdk.fetchEvents({
                    kinds: [NDKKind.Article],
                    "#h": [groupId],
                    "#T": [random]
                });

                const event = Array.from(fetchedEvents)[0];
                expect(event.sig).toBe("");
            })

            it("events with free always have signatures including for non-members", async () => {
                const {random} = await createArticleWithPreview();

                const fetchedEvents = await nonMemberNdk.fetchEvents({
                    kinds: [NDKKind.Article],
                    "#h": [groupId],
                    "#T": [random]
                });

                const event = Array.from(fetchedEvents)[0];
                expect(event.sig).not.toBe("");
            })
        })
    })

    describe('publishing', () => {
        it('owner can write content', async () => {
            const article = new NDKArticle(ownerNdk, {
                content: 'do accept it',
                tags: [['h', groupId]]
            } as NostrEvent);
            await article.sign(ownerSigner)
            try {
                await article.publish();
            } catch (e: any) {
                console.log(e.relayErrors);
            }

            const fetchedEvent = await ownerNdk.fetchEvent(article.encode());
            expect(fetchedEvent).not.toBeNull();
        })

        it('group members cant write content', async () => {
            await addGroupMember(ownerNdk, groupId, memberUser.pubkey, relaySet);
            await sleep(500);

            const article = new NDKArticle(memberNdk, {
                content: 'dont accept it',
                tags: [['h', groupId]]
            } as NostrEvent);
            await article.sign(memberSigner)
            await expect(article.publish()).rejects.toThrow();
            const fetchedEvent = await memberNdk.fetchEvent(article.encode());
            expect(fetchedEvent).toBeNull();
        })

        it('non-members cant write content', async () => {
            const article = new NDKArticle(nonMemberNdk, {
                content: 'dont accept it',
                tags: [['h', groupId]]
            } as NostrEvent);
            await article.sign(nonMemberSigner);
            await expect(article.publish()).rejects.toThrow();
            const fetchedEvent = await nonMemberNdk.fetchEvent(article.encode());
            expect(fetchedEvent).toBeNull();
        })
    })
})

async function sleep(ms: number) {
    await new Promise(resolve => setTimeout(resolve, ms));
}

function createNdk(signer: NDKSigner) {
    const ndk = new NDK({
        enableOutboxModel: false,
        signer
    });
    const relay = new NDKRelay(RELAY, NDKRelayAuthPolicies.signIn({ ndk }));
    relay.authRequired = true;
    relay.trusted = true;
    ndk.addExplicitRelay(relay, undefined, false);

    return ndk;
}

function connectNdks(ndks: NDK[]) {
    return Promise.all(ndks.map(ndk => {
        let connectedResolve: any;
        let connectInterval: any;

        const tryToConnect = async () => {
            try {
                await ndk.connect(500);
            } catch (e) {
                console.log(`error: `, e);
            }
        }

        ndk.pool.on("relay:ready", () => {
            relaySet = NDKRelaySet.fromRelayUrls([RELAY], ndk);
            connectedResolve();
            clearInterval(connectInterval);
        })

        return new Promise((resolve) => {
            connectedResolve = resolve;
            connectInterval = setInterval(tryToConnect, 500);
        });
    }));
}

/**
 * Creates article with a preview, adds a random tag to make it easy to fetch on the
 * precise test case
 */
async function createArticleWithPreview() {
    const random = Math.random().toString();
    const full = new NDKArticle(ownerNdk, {
        content: 'full article',
        tags: [
            ['h', groupId],
            ["f", ownerTier.dTag]
        ]
    } as NostrEvent);
    const preview = new NDKArticle(ownerNdk, {
        content: 'preview article',
        tags: [
            ['h', groupId],
            ["f", "Free"],
            ["tier", ownerTier.dTag]
        ]
    } as NostrEvent);

    full.tags.push(["T", random]);
    preview.tags.push(["T", random]);

    await Promise.all([
        full.publish(),
        preview.publish(),
    ]);

    return {random, full, preview};
}