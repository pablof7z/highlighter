package main

import (
	"context"
	"time"

	"github.com/fiatjaf/eventstore"
	"github.com/nbd-wtf/go-nostr"
	"golang.org/x/exp/maps"
	"golang.org/x/exp/slices"
	"golang.org/x/time/rate"
)

type Group struct {
	ID      string
	Name    string
	Picture string
	About   string
	Members map[string]*Role
	Private bool
	Closed  bool

	bucket *rate.Limiter
}

type Role struct {
	Name        string
	Permissions map[Permission]struct{}
}

type Membership struct {
	Pubkey string
	Tier   []string
}

type Permission = string

const (
	PermAddUser          Permission = "add-user"
	PermEditMetadata     Permission = "edit-metadata"
	PermDeleteEvent      Permission = "delete-event"
	PermRemoveUser       Permission = "remove-user"
	PermAddPermission    Permission = "add-permission"
	PermRemovePermission Permission = "remove-permission"
	PermEditGroupStatus  Permission = "edit-group-status"
)

var availablePermissions = map[Permission]struct{}{
	PermAddUser:          {},
	PermEditMetadata:     {},
	PermDeleteEvent:      {},
	PermRemoveUser:       {},
	PermAddPermission:    {},
	PermRemovePermission: {},
	PermEditGroupStatus:  {},
}

var (
	groups = make(map[string]*Group)

	// used for the default role, the actual relay, hidden otherwise
	masterRole *Role = &Role{"master", map[Permission]struct{}{
		PermAddUser:          {},
		PermEditMetadata:     {},
		PermDeleteEvent:      {},
		PermRemoveUser:       {},
		PermAddPermission:    {},
		PermRemovePermission: {},
		PermEditGroupStatus:  {},
	}}

	// used for normal members without admin powers, not displayed
	emptyRole *Role = nil
)

func createGroup(groupId string, ownerPubkey string, ctx context.Context) string {
	vrelay := eventstore.RelayWrapper{Store: db}
	res, _ := vrelay.QuerySync(ctx, nostr.Filter{Tags: nostr.TagMap{"#h": []string{groupId}}, Limit: 1})
	if len(res) > 0 {
		return "group already exists"
	}

	ownerPermissions := &nostr.Event{
		CreatedAt: nostr.Now(),
		Kind:      9003,
		Tags: nostr.Tags{
			nostr.Tag{"h", groupId},
			nostr.Tag{"p", ownerPubkey},
			nostr.Tag{"permission", PermAddUser},
			nostr.Tag{"permission", PermRemoveUser},
			nostr.Tag{"permission", PermEditMetadata},
			nostr.Tag{"permission", PermAddPermission},
			nostr.Tag{"permission", PermRemovePermission},
			nostr.Tag{"permission", PermDeleteEvent},
			nostr.Tag{"permission", PermEditGroupStatus},
		},
	}

	if err := ownerPermissions.Sign(s.RelayPrivkey); err != nil {
		log.Error().Err(err).Msg("error signing group creation event")
		return "error signing group creation event: " + err.Error()
	}

	if err := relay.AddEvent(ctx, ownerPermissions); err != nil {
		log.Error().Err(err).Stringer("event", ownerPermissions).Msg("failed to save group creation event")
		return "failed to save group creation event"
	}

	return ""
}

// loadGroup loads all the group metadata from all the past action messages
func loadGroup(ctx context.Context, id string, createGroup bool) *Group {
	if group, ok := groups[id]; ok {
		return group
	}

	group := &Group{
		ID: id,
		Members: map[string]*Role{
			s.RelayPubkey: masterRole,
		},

		// very strict rate limits
		bucket: rate.NewLimiter(rate.Every(time.Minute*2), 15),
	}
	ch, _ := db.QueryEvents(ctx, nostr.Filter{
		Limit: 5000, Kinds: maps.Keys(moderationActionFactories), Tags: nostr.TagMap{"h": []string{id}},
	})

	events := make([]*nostr.Event, 0, 5000)
	for event := range ch {
		events = append(events, event)
	}
	if len(events) == 0 {
		if !createGroup {
			// Check if we have a kind:37001 event for this pubkey
			// If we don't and createGroup is false return nil
			existingEvents, _ := db.CountEvents(ctx, nostr.Filter{
				Kinds: []int{37001}, Authors: []string{id},
			})
			if existingEvents == 0 {
				return nil
			}
		}

		// create group here
		return group
	}
	for i := len(events) - 1; i >= 0; i-- {
		evt := events[i]
		act, _ := moderationActionFactories[evt.Kind](evt)
		act.Apply(group)
	}

	groups[id] = group
	return group
}

func loadGroupMemberships(ctx context.Context, groupId string) []Membership {
	ch, _ := db.QueryEvents(ctx, nostr.Filter{
		Kinds: []int{39002}, Tags: nostr.TagMap{"d": []string{groupId}},
	})
	memberships := make([]Membership, 0, 5000)

	for event := range ch {
		for _, tag := range event.Tags {
			if tag[0] == "p" {
				memberships = append(memberships, Membership{tag[1], tag[2:]})
			}
		}
	}

	return memberships
}

func loadMemberships(ctx context.Context, userPubkey string) []Membership {
	ch, _ := db.QueryEvents(ctx, nostr.Filter{
		Kinds: []int{39002},
		Tags:  nostr.TagMap{"p": []string{userPubkey}},
	})

	memberships := make([]Membership, 0, len(ch))

	for event := range ch {
		var tierName *string

		groupId := getGroupIdFromEvent(event, "d")
		if groupId == "" {
			continue
		}
		for _, tag := range event.Tags {
			// fmt.Println("tag", tag, "userPubkey", userPubkey)
			if tag[0] == "p" && tag[1] == userPubkey {
				if len(tag) >= 3 {
					tierName = &tag[2]
				} else {
					tier := "Free"
					tierName = &tier
				}

				// add to memberships, if there is already a membership with this group, add the tier if it's new
				added := false
				for i, membership := range memberships {
					if membership.Pubkey == groupId {
						if !slices.Contains(membership.Tier, *tierName) {
							memberships[i].Tier = append(membership.Tier, *tierName)
						}

						added = true
					}
				}

				// if no membership was found, add a new one
				if !added {
					memberships = append(memberships, Membership{groupId, []string{*tierName}})
				}
			}
		}
	}

	return memberships
}

/**
 * Gets the tiers a pubkey has on a group.
 */
func getTiersForPubkeyOnGroup(ctx context.Context, userPubkey string, groupId string) []string {
	ch, _ := db.QueryEvents(ctx, nostr.Filter{
		Kinds: []int{39002},
		Tags:  nostr.TagMap{"p": []string{userPubkey}},
	})

	tiers := make([]string, 0, len(ch))

	for event := range ch {
		for _, tag := range event.Tags {
			if tag[0] == "p" && tag[1] == userPubkey {
				if len(tag) >= 3 {
					tiers = append(tiers, tag[2])
				} else {
					tiers = append(tiers, "Free")
				}
			}
		}
	}

	return tiers
}

func getTiersFromMemberships(memberships []Membership, groupId string) []string {
	tiers := make([]string, 0, len(memberships))

	for _, membership := range memberships {
		if membership.Pubkey == groupId {
			tiers = append(tiers, membership.Tier...)
		}
	}

	// if no tier was found, add the Free tier
	if len(tiers) == 0 {
		tiers = append(tiers, "Free")
	}

	return tiers
}

func getGroupIdFromEvent(event *nostr.Event, tagName string) string {
	if tagName == "" {
		tagName = "h"
	}

	gtag := event.Tags.GetFirst([]string{tagName, ""})
	if gtag == nil {
		return ""
	}
	return (*gtag)[1]
}
