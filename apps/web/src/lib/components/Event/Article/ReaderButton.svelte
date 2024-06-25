<script lang="ts">
	import { NDKRelaySet, NDKSubscription, NostrEvent } from "@nostr-dev-kit/ndk";
	import { toast } from "svelte-sonner";
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
    import { TextToSpeech } from '@capacitor-community/text-to-speech';
	import { onMount } from "svelte";
	import { Button } from "$components/ui/button";
	import { appMobileView } from "$stores/app";
	import { Actions, ActionsGroup, ActionsButton } from "konsta/svelte";
	import { Play, Stop } from "phosphor-svelte";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import LnQrModal from "$modals/LnQrModal.svelte";

    export let article: NDKArticle;
    export let supported: boolean;


    const speak = async () => {
        await TextToSpeech.speak({
            text: 'This is a sample text.',
            lang: 'en-US',
            rate: 1.0,
            pitch: 1.0,
            volume: 1.0,
            category: 'ambient',
        });
    };

    const stop = async () => {
        await TextToSpeech.stop();
    };

    const getSupportedLanguages = async () => {
        const languages = await TextToSpeech.getSupportedLanguages();
    };

    const getSupportedVoices = async () => {
        const voices = await TextToSpeech.getSupportedVoices();
    };

    const isLanguageSupported = async (lang: string) => {
        const isSupported = await TextToSpeech.isLanguageSupported({ lang });
    };

    let voices: SpeechSynthesisVoice[] = [];

    // const dvms = $ndk.storeSubscribe({ kinds: [NDKKind.AppHandler], "#k": ["5250"]});
    // const dvmProfiles = derived(dvms, ($dvms) => {
    //     console.log($dvms)
    //     return $dvms
    //         .map(dvm => {
    //             try {
    //                 const content = JSON.parse(dvm.content) as NDKUserProfile;
    //                 if (content.name && content.display_name)
    //                     return content;
    //             } catch (e) {
    //                 console.error(e, dvm.content);
    //             }
    //         })
    //         .filter(p => !!p);
    // });

    onMount(async () => {
        const res = await TextToSpeech.getSupportedVoices();
        voices = res.voices;
    });

    let showChooseVoice = false;
    let voice: SpeechSynthesisVoice | undefined;
    
    function chooseVoice() {
        showChooseVoice = !showChooseVoice;
    }

    async function replaceNpubWithName(npub: string) {
        const user = $ndk.getUser({npub})
        const profile = await user.fetchProfile();

        return profile?.display_name || npub.slice(6);
    }

    let playing = false;

    async function playWithVoice(v: SpeechSynthesisVoice) {
        // showChooseVoice = false;
        voice = v;
        play();
    }

    async function play() {
        if (!voice) return;
        playing = true;
        
        let content = article.content;

        // remove anything that looks like a link
        content = content.replace(/https?:\/\/\S+/g, '');

        // go through anything that looks like a nostr:npub and get the text, strip the nostr: prefix and replace with the name from the function above
        const npubRegex = /nostr:npub1[a-zA-Z0-9]+/g;
        const npubs = content.match(npubRegex);

        if (npubs) {
            for (let npub of npubs) {
                // remove the nostr: prefix
                npub = npub.slice(6);
                const name = await replaceNpubWithName(npub);
                content = content.replace(npub, name);
            }
        }

        
        await TextToSpeech.speak({
            text: article.content,
            lang: voice.lang,
            name: voice.name,
            rate: 1.0,
            pitch: 1.0,
            volume: 1.0,
            category: 'ambient',
        });

        playing = false;
    }

    let dvmSub: NDKSubscription | undefined;

    async function togglePlay() {
        const relay = $ndk.pool.getRelay("wss://relay.damus.io")
        const relaySet = new NDKRelaySet(new Set([relay]), $ndk);
        const e = new NDKEvent($ndk, {
            kind: 5250,
        } as NostrEvent)
        e.tags.push(["p", "7c3be2769c76eecd6c6e27276722dfae0d8ad201825253452153b90093c41654"]);
        e.tags.push(["i", "ff305d4a9f3b77188802f92af2148849a49349405007a56aa3c4fa7e08d6ac34", "event"]);
        e.tags.push(["param", "language", "en"]);
        e.tags.push(["relays", "wss://relay.primal.net", "wss://relay.f7z.io", "wss://nos.lol"])
        await e.sign();

        dvmSub = $ndk.subscribe(e.filter(), {}, relaySet);

        dvmSub.on("event", (e) => {
            console.log(e);

            if (e.kind === 7000) {
                toast.success(e.content);
            }

            const amount = e.getMatchingTags("amount")[0];
            console.log(amount);
            openModal(LnQrModal, { title: "Pay DVM", satAmount: parseInt(amount[1])/1000, pr: amount[2] })
        });
        
        await e.publish();
        
        // if (playing) {
        //     stop();
        // } else if (voice) {
        //     play();
        // } else {
        //     chooseVoice();
        // }
        // playing = !playing;
    }
</script>

<Button variant="secondary" on:click={togglePlay}>
    {#if playing}
        <Stop />
    {:else}
        <Play />
    {/if}
</Button>

{#if $appMobileView}
    <Actions
        opened={showChooseVoice}
        onBackdropClick={() => {(showChooseVoice = false)}}
    >
        <ActionsGroup class="max-h-[50vh] overflow-y-auto scrollbar-hide">
            <!-- {#each $dvmProfiles as dvm}
                <ActionsButton onClick={() => {}}>
                    {#if dvm.image}<Avatar src={dvm.image} />{/if}
                    {dvm.displayName??dvm.name}
                </ActionsButton>
            {/each} -->
            {#each voices as voice}
                <ActionsButton onClick={() => playWithVoice(voice)}>
                    {voice.name}
                </ActionsButton>
            {/each}
            <ActionsButton onClick={() => {(showChooseVoice = false)}}>
                Cancel
            </ActionsButton>
        </ActionsGroup>
    </Actions>
{:else}
{/if}