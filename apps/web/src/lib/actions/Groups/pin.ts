import getList from "./get-list"

export default function pinGroup(groupId: string, relays: string[]) {
    const list = getList();
    list.addItem(
        [ "group", groupId, ...relays ]
    );
    list.publishReplaceable();
}