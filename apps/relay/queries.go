package main

import (
	"context"
	"fmt"

	"github.com/fiatjaf/khatru"
	"github.com/nbd-wtf/go-nostr"
	"golang.org/x/exp/slices"
)

func groupIdFromEvent(event *nostr.Event) string {
	hTag := event.Tags.GetFirst([]string{"h", ""})
	if hTag == nil {
		return ""
	}
	return (*hTag)[1]
}

func getTiersFromEvent(event *nostr.Event) []string {
	fTags := event.Tags.GetAll([]string{"f", ""})
	eventTiers := make([]string, 0, len(fTags))
	for _, fTag := range fTags {
		eventTiers = append(eventTiers, fTag[1])
	}
	return eventTiers
}

/**
 * Sends the event to the channel. If this is a members-only
 * event, it strips the signature
 */
func sendEvent(ch chan *nostr.Event, event *nostr.Event, requesterPubkey string) {
	tiers := getTiersFromEvent(event)
	if len(tiers) > 0 {
		if !slices.Contains(tiers, "Free") {
			if requesterPubkey == event.PubKey {
				fmt.Println("event is members-only, but requester is the author, not stripping signature")
			} else {
				fmt.Println("stripping signature from event")
				event.Sig = ""
			}
		} else {
			fmt.Println("event is free, not stripping signature", tiers)
		}
	}

	ch <- event
}

func contentQueryHandler(ctx context.Context, filter nostr.Filter) (chan *nostr.Event, error) {
	pubkey := khatru.GetAuthed(ctx)

	var memberships []Membership

	fmt.Println("filter", filter)

	if pubkey != "" {
		memberships = loadMemberships(ctx, pubkey)
	}

	queryChannel, err := db.QueryEvents(ctx, filter)

	if err != nil {
		fmt.Println("error querying events", err)
	}

	retChannel := make(chan *nostr.Event, 500)

	go func() {
		defer close(retChannel)

		for event := range queryChannel {
			eventTiers := getTiersFromEvent(event)

			// if there are no f tags, send the event
			if len(eventTiers) == 0 {
				sendEvent(retChannel, event, pubkey)
				continue
			}

			groupId := groupIdFromEvent(event)

			// if there is no h tag, send the event
			if groupId == "" {
				sendEvent(retChannel, event, pubkey)
			}

			tiers := getTiersFromMemberships(memberships, groupId)

			// if the groupId is the pubkey, send the event
			if groupId == pubkey {
				fmt.Println("groupid is pubkey", event.Tags)

				// if the tier has a "full" tag
				if event.Tags.GetFirst([]string{"full", ""}) != nil {
					dTag := event.Tags.GetFirst([]string{"d", ""})
					// fmt.Println("event has full tag", "filter.Tags[d]", filter.Tags["d"], "dTag", dTag)

					// only send the event if the d tag is in the filter
					if dTag != nil && slices.Contains(filter.Tags["d"], (*dTag)[1]) {
						// fmt.Println("d tag is in filter, sending event", event.Tags, "filter.Tags[d]", filter.Tags["d"])
						sendEvent(retChannel, event, pubkey)
						continue
					} else {
						// fmt.Println("d tag is not in filter, not sending event", event.Tags, "filter.Tags[d]", filter.Tags["d"])
						continue
					}
				} else {
					// if it does not have a "full" tag, send the event
					// fmt.Println("event does not have full tag, sending it")
					sendEvent(retChannel, event, pubkey)
					continue
				}
			}

			// if any tier is among the f tags, send the event
			for _, tier := range tiers {
				// fmt.Println("compare tier", tier, "with eventTiers", eventTiers)
				if slices.Contains(eventTiers, tier) {
					fmt.Println("tier is among eventTiers, sending event", tier, event.Tags)
					sendEvent(retChannel, event, pubkey)
					continue
				}
			}

			// otherwise, don't send the event
			// fmt.Println("not sending event", event.Tags.GetFirst([]string{"title"}), "subscribedTiers", tiers, "eventTiers", eventTiers, "pubkey = ", pubkey, "groupId =", groupId)
		}
	}()

	return retChannel, nil
}

func metadataQueryHandler(ctx context.Context, filter nostr.Filter) (chan *nostr.Event, error) {
	ch := make(chan *nostr.Event, 1)
	if slices.Contains(filter.Kinds, 39000) {
		for _, groupId := range filter.Tags["d"] {
			fmt.Println("loading group", groupId)
			group := loadGroup(ctx, groupId, false)

			if group == nil {
				continue
			}

			evt := &nostr.Event{
				Kind:      39000,
				CreatedAt: nostr.Now(),
				Content:   group.About,
				Tags: nostr.Tags{
					nostr.Tag{"d", group.ID},
				},
			}
			if group.Name != "" {
				evt.Tags = append(evt.Tags, nostr.Tag{"name", group.Name})
			}
			if group.Picture != "" {
				evt.Tags = append(evt.Tags, nostr.Tag{"picture", group.Picture})
			}

			// status
			if group.Private {
				evt.Tags = append(evt.Tags, nostr.Tag{"private"})
			} else {
				evt.Tags = append(evt.Tags, nostr.Tag{"public"})
			}
			if group.Closed {
				evt.Tags = append(evt.Tags, nostr.Tag{"closed"})
			} else {
				evt.Tags = append(evt.Tags, nostr.Tag{"open"})
			}

			// sign
			evt.Sign(s.RelayPrivkey)
			ch <- evt
		}
	}
	close(ch)
	return ch, nil
}

func adminsQueryHandler(ctx context.Context, filter nostr.Filter) (chan *nostr.Event, error) {
	ch := make(chan *nostr.Event, 1)
	if slices.Contains(filter.Kinds, 39001) {
		for _, groupId := range filter.Tags["d"] {
			group := loadGroup(ctx, groupId, false)

			if group == nil {
				continue
			}

			evt := &nostr.Event{
				Kind:      39001,
				CreatedAt: nostr.Now(),
				Content:   "list of admins for group " + groupId,
				Tags: nostr.Tags{
					nostr.Tag{"d", group.ID},
				},
			}
			for pubkey, role := range group.Members {
				if role != emptyRole && role != masterRole {
					tag := nostr.Tag{pubkey, "admin"}
					for permName := range role.Permissions {
						tag = append(tag, permName)
					}
					evt.Tags = append(evt.Tags, tag)
				}
			}
			evt.Sign(s.RelayPrivkey)
			ch <- evt
		}
	}
	close(ch)
	return ch, nil
}

func membersQueryHandler(ctx context.Context, filter nostr.Filter) (chan *nostr.Event, error) {
	ch := make(chan *nostr.Event, 1)

	if slices.Contains(filter.Kinds, 39002) {
		go func() {
			defer close(ch)
			for _, groupId := range filter.Tags["d"] {
				group := loadGroup(ctx, groupId, false)

				if group == nil {
					continue
				}

				evt := &nostr.Event{
					Kind:      39002,
					CreatedAt: nostr.Now(),
					Content:   "list of members of " + groupId,
					Tags: nostr.Tags{
						nostr.Tag{"d", group.ID},
					},
				}
				for pubkey, role := range group.Members {
					if pubkey == s.RelayPubkey {
						continue
					}

					tag := nostr.Tag{"p", pubkey}
					if role != emptyRole && role != masterRole {
						for permName := range role.Permissions {
							tag = append(tag, permName)
						}
					}
					evt.Tags = append(evt.Tags, tag)
				}
				evt.Sign(s.RelayPrivkey)
				ch <- evt
			}
		}()
	} else {
		close(ch)
	}

	return ch, nil
}
