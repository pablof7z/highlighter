package main

var contentKinds = []int{30023, 34235}

// func applyFilterOverwrite(ctx context.Context, filter *nostr.Filter) {
// 	pubkey := khatru.GetAuthed(ctx)

// 	if pubkey == "" {
// 		if contains(filter.Kinds, contentKinds) {
// 			fmt.Println("adding Free tag", pubkey, filter)
// 			return db.QueryEvents(ctx, filter)
// 		}

// 	if pubkey == "" {
// 		return
// 	}

// 	vrelay := eventstore.RelayWrapper{Store: db}

// 	// if the kinds in query are for content, add the subscribed tiers
// 	// if all
// 	if containsAll(filter.Kinds, contentKinds) {
// 		// Get the tiers this pubkey is subscribed to
// 		res, _ := vrelay.QuerySync(ctx, nostr.Filter{
// 			Tags: nostr.TagMap{
// 				"kinds": []string{"39002"},
// 				"#p":    []string{pubkey},
// 			},
// 		},
// 		)

// 		// Add the tiers to the filter
// 		for _, event := range res {
// 			// get the tag that has "p" as the first element and the pubkey as the second
// 			var tierTag *nostr.Tag
// 			for _, tag := range event.Tags {
// 				if tag[0] == "p" && tag[1] == pubkey {
// 					tierTag = &tag
// 					break
// 				}
// 			}

// 			if tierTag != nil {
// 				tierName := (*tierTag)[2]

// 				// add
// 			}
// 		}
// 	}

// 	res, _ := vrelay.QuerySync(ctx, nostr.Filter{Tags: nostr.TagMap{"#h": []string{groupId}}, Limit: 1})
// 	if len(res) > 0 {
// 		return "group already exists"
// 	}

// 	fmt.Println("apply", filter)
// 	fmt.Println("context", ctx)
// 	fmt.Println("pubkey", pubkey)
// }
