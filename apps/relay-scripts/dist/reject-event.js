// src/reject-event.ts
var activeSubscriptions = {
  "e869cdc5114a2b067a99bbcdb6cbd1e80696efd0c352f1c1e6d0be8fc440f807": [
    "85c3d32d805fa222a51379b42d4e9483b1bda8f24ed1362b59503784f30edf98"
  ]
};
function allowAuthorOnTheirOwnGroup(event, hTag) {
  const author = event.pubkey;
  if (author === hTag)
    return true;
}
function allowActiveMembersToReply(event, hTag) {
  const author = event.pubkey;
  console.log(JSON.stringify({ hTag, activeSubscriptions: activeSubscriptions[hTag] }));
  if (activeSubscriptions[hTag].includes(author))
    return true;
}
function allowReactionsFromAnyone(event, hTag) {
  if (event.kind === 7)
    return true;
}
export default function reject_event_default(event, relay, connection) {
  var _a;
  console.log(JSON.stringify({ event, relay, connection }));
  if (!connection.pubkey) {
    console.log("Authentication required");
    return "Authentication required";
  }
  const hTag = (_a = event.tags.find((tag) => tag[0] === "h")) == null ? void 0 : _a[1];
  const eventCount = relay.query({}).length;
  console.log(JSON.stringify({ hTag, eventCount }));
  if (hTag) {
    try {
      if (allowReactionsFromAnyone(event, hTag))
        return;
      if (allowAuthorOnTheirOwnGroup(event, hTag))
        return;
      if (allowActiveMembersToReply(event, hTag))
        return;
    } catch (e) {
      console.trace(e);
      return e.message;
    }
    return "Not allowed";
  }
}
