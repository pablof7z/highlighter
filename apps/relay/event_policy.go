package main

import (
	"context"
	"fmt"
	"slices"

	"github.com/nbd-wtf/go-nostr"
)

var kindsRequireHTag = []int{9, 11, 12}

func requireHTag(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	gtag := event.Tags.GetFirst([]string{"h", ""})

	if gtag == nil && slices.Contains(kindsRequireHTag, event.Kind) {
		return true, "missing group (`h`) tag"
	}
	return false, ""
}

/**
 * Events must tag an event that
 */
func onlyMembersCanWrite(ctx context.Context, event *nostr.Event, groupId string, eTags nostr.Tags) (reject bool, msg string) {
	// get the tiers this user has on this group
	activeTiers := getTiersForPubkeyOnGroup(ctx, event.PubKey, groupId)

	fmt.Println("activeTiers: ", activeTiers)

	// get the tagged events
	taggedEvents, _ := getTaggedEvents(ctx, event, groupId, eTags)

	for taggedEvent := range taggedEvents {
		// get the tier of the tagged events
		eventTiers := getTiersFromEvent(taggedEvent)

		// if it doesn't have a tier, allow
		if len(eventTiers) == 0 {
			continue
		}

		eventCanBeTagged := false

		for _, tier := range eventTiers {
			if tier == "Free" || slices.Contains(activeTiers, tier) {
				eventCanBeTagged = true
				break
			}
		}

		if !eventCanBeTagged {
			return true, "insufficient permissions"
		}
	}

	return false, ""
}

func getTaggedEvents(ctx context.Context, event *nostr.Event, groupId string, eTags nostr.Tags) (chan *nostr.Event, error) {
	// get tagged events
	ids := make([]string, 0, len(eTags))
	for _, tag := range eTags {
		ids = append(ids, tag[1])
	}

	return db.QueryEvents(ctx, nostr.Filter{
		IDs:  ids,
		Tags: nostr.TagMap{"h": []string{groupId}},
	})
}

/**
 * Events that tag other events within a group must tag at least one event that exists
 * in the group
 */
func nonRootEventsMustTagExistingEvents(ctx context.Context, event *nostr.Event, groupId string, eTags nostr.Tags) (reject bool, msg string) {
	// get tagged events
	ids := make([]string, 0, len(eTags))
	for _, tag := range eTags {
		ids = append(ids, tag[1])
	}

	// if there are no tagged events, allow
	if len(ids) == 0 {
		return false, ""
	}

	// at least one must be in the database
	existingEvents, _ := db.CountEvents(ctx, nostr.Filter{
		IDs:  ids,
		Tags: nostr.TagMap{"h": []string{groupId}},
	})

	// if there are no events, reject
	if existingEvents == 0 {
		return true, "unknown parent event"
	}

	return false, ""
}

func enforceGroupEvents(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	groupId := getGroupIdFromEvent(event, "")
	eTags := event.Tags.GetAll([]string{"e", ""})

	// if we don't have an h tag, allow
	if groupId == "" {
		return false, ""
	}

	var checks []func(context.Context, *nostr.Event, string, nostr.Tags) (bool, string)

	if groupId != event.PubKey {
		checks = append(checks,
			nonRootEventsMustTagExistingEvents,
			onlyMembersCanWrite,
		)
	}

	for _, check := range checks {
		res, msg := check(ctx, event, groupId, eTags)
		if res {
			return res, msg
		}
	}

	return false, ""
}

/**
 * Ensures that the h tag matches the event.pubkey if there are no e tags, and ensures
 * that the e-tagged event exists and its h tag matches the h tag of the event.
 */
func onlyCreatorCanWriteRootEvents(ctx context.Context, event *nostr.Event, groupId string, eTags nostr.Tags) (reject bool, msg string) {
	if groupId != event.PubKey {
		return true, "only the creator can write root events"
	}

	return false, ""
}

func restrictGroupWritesToMembers(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	gtag := event.Tags.GetFirst([]string{"h", ""})

	// if there is no group, allow
	if gtag == nil {
		return false, ""
	}

	groupId := (*gtag)[1]
	group := loadGroup(ctx, groupId, true)

	// if there is no group, allow
	if group == nil {
		return false, ""
	}

	// owner can write
	if groupId == event.PubKey {
		return false, ""
	}

	// only members can write
	// if _, isMember := group.Members[event.PubKey]; !isMember {
	// 	return true, "unknown member"
	// }

	return false, ""
}

func restrictWritesBasedOnGroupRules(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	// check it only for normal write events
	if event.Kind == 9 || event.Kind == 11 {
		gtag := event.Tags.GetFirst([]string{"h", ""})
		groupId := (*gtag)[1]
		// group := loadGroup(ctx, groupId)

		// owner can write
		if groupId == event.PubKey {
			return false, ""
		}

		// members can write to events tagged with the member's tier

		// only members can write
		// if _, isMember := group.Members[event.PubKey]; !isMember {
		// 	return true, "unknown member"
		// }
	}

	return false, ""
}

func restrictInvalidModerationActions(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	if event.Kind < 9000 || event.Kind > 9020 {
		return false, ""
	}
	makeModerationAction, ok := moderationActionFactories[event.Kind]
	if !ok {
		return true, "unknown moderation action"
	}
	action, err := makeModerationAction(event)
	if err != nil {
		return true, "invalid moderation action: " + err.Error()
	}

	gtag := event.Tags.GetFirst([]string{"h", ""})
	groupId := (*gtag)[1]
	group := loadGroup(ctx, groupId, true)

	fmt.Println("groupId: ", groupId, group)

	// if h tag is the same as the event.pubkey, allow
	if groupId == event.PubKey || event.PubKey == s.RelayPubkey {
		fmt.Println("groupId == event.PubKey: allow moderation action")
		return false, ""
	}

	fmt.Println("groupId != event.PubKey: ", groupId, event.PubKey)
	if groupId != event.PubKey {
		role, ok := group.Members[event.PubKey]
		if !ok || role == emptyRole {
			return true, "unknown admin2"
		}

		if _, ok := role.Permissions[action.PermissionName()]; !ok {
			return true, "insufficient permissions"
		}
	}

	return false, ""
}

func rateLimit(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
	gtag := event.Tags.GetFirst([]string{"h", ""})
	if gtag == nil {
		return
	}

	groupId := (*gtag)[1]
	group := loadGroup(ctx, groupId, true)

	if rsv := group.bucket.Reserve(); rsv.Delay() != 0 {
		rsv.Cancel()
		return true, "rate-limited"
	} else {
		rsv.OK()
		return
	}
}

func applyModerationAction(ctx context.Context, event *nostr.Event) {
	if event.Kind < 9000 || event.Kind > 9020 {
		return
	}
	makeModerationAction, ok := moderationActionFactories[event.Kind]
	if !ok {
		return
	}
	action, err := makeModerationAction(event)
	if err != nil {
		return
	}
	gtag := event.Tags.GetFirst([]string{"h", ""})
	groupId := (*gtag)[1]
	group := loadGroup(ctx, groupId, true)
	action.Apply(group)
}

func reactToJoinRequest(ctx context.Context, event *nostr.Event) {
	if event.Kind != 9021 {
		return
	}
	gtag := event.Tags.GetFirst([]string{"h", ""})
	groupId := (*gtag)[1]
	group := loadGroup(ctx, groupId, true)

	if !group.Closed {
		// immediatelly add the requester
		addUser := &nostr.Event{
			CreatedAt: nostr.Now(),
			Kind:      9000,
			Tags: nostr.Tags{
				nostr.Tag{"p", event.PubKey},
			},
		}
		if err := addUser.Sign(s.RelayPrivkey); err != nil {
			log.Error().Err(err).Msg("failed to sign add-user event")
			return
		}
		if err := relay.AddEvent(ctx, addUser); err != nil {
			log.Error().Err(err).Msg("failed to add user who requested to join")
			return
		}
	}
}

func blockDeletesOfOldMessages(ctx context.Context, target, deletion *nostr.Event) (acceptDeletion bool, msg string) {
	if target.CreatedAt < nostr.Now()-60*60*2 /* 2 hours */ {
		return false, "can't delete old event, contact relay admin"
	}

	return true, ""
}
