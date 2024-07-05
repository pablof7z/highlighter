package main

import (
	"context"
	"fmt"
	"slices"

	"github.com/fiatjaf/khatru"
	"github.com/nbd-wtf/go-nostr"
)

func requireAuth(ctx context.Context, filter nostr.Filter) (reject bool, msg string) {
	pubkey := khatru.GetAuthed(ctx)

	if pubkey != "" {
		return false, ""
	}

	// run the query, if it only returns events that are not public, request auth
	queryChannel, _ := db.QueryEvents(ctx, filter)

	nonPublicEvents := 0

	for event := range queryChannel {
		eventTiers := getTiersFromEvent(event)

		if len(eventTiers) == 0 || slices.Contains(eventTiers, "Free") {
			// if we have a public event, we don't need to request auth
			fmt.Println("public event found")
			return false, ""
		} else {
			nonPublicEvents++
			fmt.Println("non-public event found")
		}
	}

	if nonPublicEvents > 0 {
		return true, "auth-required: authenticate please"
	}

	return false, ""
}

func requireKindAndSingleGroupID(ctx context.Context, filter nostr.Filter) (reject bool, msg string) {
	pubkey := khatru.GetAuthed(ctx)

	fmt.Println("pubkey:", pubkey)

	// if there is no pubkey, send back auth-required
	// if pubkey == "" {
	// 	return true, "auth-required: something"
	// }

	fmt.Println("pubkey:", pubkey)

	// isMeta := false
	isNormal := false
	for _, kind := range filter.Kinds {
		if kind < 10000 {
			isNormal = true
		} else if kind >= 30000 {
			// isMeta = true
		}
	}
	// if isNormal && isMeta {
	// 	return true, "cannot request both meta and normal events at the same time"
	// }
	// if !isNormal && !isMeta {
	// 	return true, "unexpected kinds requested"
	// }

	if isNormal {
		if tags, _ := filter.Tags["h"]; len(tags) == 0 {
			return true, "must have an 'h' tag"
		}
	}

	return false, ""
}
