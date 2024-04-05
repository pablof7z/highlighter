package main

import (
	"fmt"
	"net/http"

	"github.com/nbd-wtf/go-nostr/nip19"
	"github.com/theplant/htmlgo"
)

func handleHomepage(w http.ResponseWriter, r *http.Request) {
	htmlgo.Fprint(w, homepageHTML(), r.Context())
}

func handleCreateGroup(w http.ResponseWriter, r *http.Request) {
	pubkey := r.PostFormValue("pubkey")
	if pfx, value, err := nip19.Decode(pubkey); err == nil && pfx == "npub" {
		pubkey = value.(string)
	}

	// id := make([]byte, 8)
	// binary.LittleEndian.PutUint64(id, uint64(time.Now().Unix()))
	// groupId := hex.EncodeToString(id[0:4])

	log.Info().Str("id", pubkey).Str("owner", pubkey).Msg("making group")

	res := createGroup(pubkey, pubkey, r.Context())

	if res == "" {
	} else {
		http.Error(w, res, 403)
	}

	naddr, _ := nip19.EncodeEntity(s.RelayPubkey, 39000, pubkey, []string{"wss://" + s.Domain})
	fmt.Fprintf(w, "group created!\n\n%s", naddr)
}
