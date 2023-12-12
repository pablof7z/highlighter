// src/reject-filter.ts
var subscriptions = {
  "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52": {
    "82fbb08c8ef45c4d71c88368d0ae805bc62fb92f166ab04a0b7a0c83d8cbc29a": [
      "White Rabbit"
    ]
  }
};
function allowAuthorOnTheirOwnGroup(filter, groups, pubkey) {
  if ((groups == null ? void 0 : groups.length) === 1 && groups[0] === pubkey)
    return true;
}
function allowQueryingForFreeItems(filter, groups, pubkey) {
  var _a;
  if (((_a = filter["#f"]) == null ? void 0 : _a.length) === 1 && filter["#f"][0] === "Free")
    return true;
}
function allowQueryingForInformativeItems(filter, groups, pubkey) {
  const onlyAllowedKinds = [17001, 7001, 0, 37777, 30023];
  const requestedKinds = filter.kinds;
  if (requestedKinds == null ? void 0 : requestedKinds.every((kind) => onlyAllowedKinds.includes(kind)))
    return true;
}
function allowActiveSubscribers(filter, groups, pubkey) {
  var _a, _b;
  const tiers = filter["#f"];
  if (!tiers)
    return;
  for (const group of groups) {
    for (const tier of tiers) {
      const tierSubs = (_b = (_a = subscriptions[pubkey]) == null ? void 0 : _a[group]) == null ? void 0 : _b.includes(tier);
      if (!tierSubs)
        return;
    }
  }
  return true;
}
function test(filter, relay, connection) {
  if (!connection.pubkey) {
    console.log("Authentication required");
    return "auth-required: Authentication required";
  }
  const groups = filter["#h"];
  try {
    if (allowQueryingForFreeItems(filter, groups, connection.pubkey))
      return;
    if (allowQueryingForInformativeItems(filter, groups, connection.pubkey))
      return;
    if (groups) {
      if (allowAuthorOnTheirOwnGroup(filter, groups, connection.pubkey))
        return;
      if (allowActiveSubscribers(filter, groups, connection.pubkey))
        return;
    }
  } catch (e) {
    console.trace(e);
    return e.message;
  }
  console.log("Would not have allowed", JSON.stringify(filter), connection.pubkey);
}
export {
  test as default
};
