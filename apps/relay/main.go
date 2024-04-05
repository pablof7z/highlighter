package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/fiatjaf/eventstore/lmdb"
	"github.com/fiatjaf/khatru"
	"github.com/fiatjaf/khatru/policies"
	"github.com/kelseyhightower/envconfig"
	"github.com/nbd-wtf/go-nostr"
	"github.com/rs/zerolog"
)

type Settings struct {
	Port             string `envconfig:"PORT" default:"5577"`
	Domain           string `envconfig:"DOMAIN" required:"true"`
	RelayName        string `envconfig:"RELAY_NAME" required:"true"`
	RelayPrivkey     string `envconfig:"RELAY_PRIVKEY" required:"true"`
	RelayDescription string `envconfig:"RELAY_DESCRIPTION"`
	RelayContact     string `envconfig:"RELAY_CONTACT"`
	RelayIcon        string `envconfig:"RELAY_ICON"`
	RelayUrl         string `envconfig:"RELAY_URL"`
	DatabasePath     string `envconfig:"DATABASE_PATH" default:"./db"`

	RelayPubkey string `envconfig:"-"`
}

var (
	s     Settings
	db    = &lmdb.LMDBBackend{}
	log   = zerolog.New(os.Stderr).Output(zerolog.ConsoleWriter{Out: os.Stdout}).With().Timestamp().Logger()
	relay = khatru.NewRelay()
)

func main() {
	err := envconfig.Process("", &s)
	if err != nil {
		log.Fatal().Err(err).Msg("couldn't process envconfig")
		return
	}
	s.RelayPubkey, _ = nostr.GetPublicKey(s.RelayPrivkey)

	// load db
	db.Path = s.DatabasePath
	if err := db.Init(); err != nil {
		log.Fatal().Err(err).Msg("failed to initialize database")
		return
	}
	log.Debug().Str("path", db.Path).Msg("initialized database")

	// init relay
	relay.Info.Name = s.RelayName
	relay.Info.PubKey = s.RelayPubkey
	relay.Info.Description = s.RelayDescription
	relay.Info.Contact = s.RelayContact
	relay.Info.Icon = s.RelayIcon
	relay.ServiceURL = s.RelayUrl

	relay.StoreEvent = append(relay.StoreEvent, db.SaveEvent)
	relay.QueryEvents = append(relay.QueryEvents,
		// db.QueryEvents,
		metadataQueryHandler,
		membersQueryHandler,
		// adminsQueryHandler,
		contentQueryHandler,
	)
	relay.CountEvents = append(relay.CountEvents, db.CountEvents)
	relay.DeleteEvent = append(relay.DeleteEvent, db.DeleteEvent)
	relay.OverwriteDeletionOutcome = append(relay.OverwriteDeletionOutcome,
		blockDeletesOfOldMessages,
	)
	// relay.OverwriteFilter = append(
	// 	relay.OverwriteFilter,
	// )
	// policies.RemoveAllButKinds(9, 11, 9000, 9001, 9002, 9003, 9004, 9005, 9006, 9021, 30023, 39000, 39001),
	// applyFilterOverwrite,

	relay.RejectFilter = append(
		relay.RejectFilter,
		// func(ctx context.Context, filter nostr.Filter) (reject bool, msg string) {
		// 	fmt.Println("FILTER", filter)
		// 	return false, ""
		// },
		// require
		// requireKindAndSingleGroupID,
		requireAuth,
	)
	relay.RejectEvent = append(relay.RejectEvent,
		func(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
			fmt.Println("EVENT", event)
			return false, ""
		},
		policies.PreventTooManyIndexableTags(10, []int{39002}, nil),
		// func(ctx context.Context, event *nostr.Event) (reject bool, msg string) {
		// 	if event.Kind != 0 {
		// 		policies.PreventTimestampsInThePast(60)
		// 		policies.PreventTimestampsInTheFuture(30)
		// 	}
		// 	return false, ""
		// },
		// requireHTag,

		enforceGroupEvents,
		// restrictGroupWritesToMembers,
		// restrictWritesBasedOnGroupRules,
		restrictInvalidModerationActions,
		rateLimit,
	)
	relay.OnEventSaved = append(relay.OnEventSaved,
		applyModerationAction,
		reactToJoinRequest,
	)
	relay.OnConnect = append(
		relay.OnConnect,
		func(ctx context.Context) {
			fmt.Println("connected, requesting auth")
			// sleep for 2 seconds to test something
			time.Sleep(2 * time.Second)
			fmt.Println("requesting auth now")
			khatru.RequestAuth(ctx)
		},
	)

	// http routes
	// relay.Router().HandleFunc("/create", handleCreateGroup)
	// relay.Router().HandleFunc("/", handleHomepage)

	log.Info().Msg("running on http://0.0.0.0:" + s.Port)
	if err := http.ListenAndServe(":"+s.Port, relay); err != nil {
		log.Fatal().Err(err).Msg("failed to serve")
	}
}
