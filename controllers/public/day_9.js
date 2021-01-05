var SpeechRecognition = SpeechRecognition || webkitSpeechRecognition
let data = {
    synth: null,
    voice: null,
    recognition: new SpeechRecognition(),
    step: 0,
}
const GO = document.getElementById("go")
const TWISTER = document.getElementById("twister")
const WORDS = document.getElementById("words")
data.synth = window.speechSynthesis;
// our gal victoria
data.voice = data.synth.getVoices()[41]
twisters = [
    "11 benevolent elephants",
    "Peter Piper picked a peck of pickled peppers",
    "How can a clam cram in a clean cream can",
    "Betty Botter bought some butter but said she the butter is bitter",
    "Imagine an imaginary menagerie manager managing an imaginary menagerie",
 ]

const buildUtterance = (text) => {
    let utterance = new SpeechSynthesisUtterance(text)
    utterance.voice = data.voice
    utterance.pitch = 1
    utterance.rate = 1
    return utterance
}
const speak = async (text) => {
    data.synth.speak(buildUtterance(text))
    while (data.synth.speaking) {
        await new Promise(resolve => setTimeout(resolve, 500))
    }
}

const run = async () => {
    GO.hidden = true
    let response = await fetch('/name', {  credentials: "same-origin" })
    let body = await response.json()
    let name = "you anonymous person"
    if (body.name && body.name.length > 0) {
        name = body.name
    }

    response = await fetch('/day_9_twister', {  credentials: "same-origin" })
    body = await response.json()
    let i = body.twister
    if (i == 4) {
        TWISTER.textContent = "-...  ...  --."
        return
    } else if (i == 0) {
        await speak('Hello ' + name + ", todays puzzle will get your tongue all in a twist. I'll give you a tongue twister to say and judge how well you say it. Harshly. Lets get started.")
    } else {
        await speak("Oh you're back. Well. I guess we should carry on then, shall we?")
    }

    for (i; i < twisters.length; i++) {
        TWISTER.textContent = twisters[i]
        await speak("Go ahead, I'm listening")
        let result = await twistTongue(twisters[i])

        while (result !== "GREAT") {
            WORDS.style.color = "red"
            await speak("Nope. No, That's wrong. Start again.")
            WORDS.style.color = "grey"
            WORDS.textContent = ""
            result = await twistTongue(twisters[i])
        }
        WORDS.style.color = "lightgreen"
        fetch('/day_9', {method: "PUT", credentials: "same-origin"})
        await speak("Yay. Woohoo. Nice work. Good talking.")
        WORDS.style.color = "grey"
        WORDS.textContent = ""
        TWISTER.textContent = ""
        if (i < twisters.length - 1) {
            await speak("Alright, next up.")
        }
    }
    await speak("Finally. Jeez. Way to go. Just take up all my time why don't you. Anyway, here's your clue")
    TWISTER.textContent = "-...  ...  --."
}

const twistTongue = async (tongueTwister) => {
    tongueTwister = tongueTwister.toLowerCase()
    return new Promise((resolve, reject) => {

        data.recognition.continuous = false;
        data.recognition.lang = 'en-AU';
        data.recognition.interimResults = true;
        data.recognition.maxAlternatives = 1;

        resolver = (event) => {
            var result = event.results[0][0]
            WORDS.textContent = result.transcript

            // We may want to tweak the confidence number here if we get held up here in testing
            if (result.confidence > 0.8 && !tongueTwister.startsWith(result.transcript.toLowerCase())) {
                console.log(result.confidence)
                console.log(result.transcript)
                console.log(tongueTwister.startsWith(result.transcript.toLowerCase()))
                console.log(tongueTwister)
                WORDS.textContent = result.transcript
                data.recognition.stop()
                return resolve('WRONG WORDS')
            } else if (result.transcript.toLowerCase() == tongueTwister) {
                WORDS.textContent = result.transcript
                data.recognition.stop()
                return resolve('GREAT')
            } else if (result[0].isFinal) {
                WORDS.textContent = result.transcript
                return resolve('STOPPED EARLY')
            }
        }
        data.recognition.onresult = resolver

        data.recognition.start()
        setTimeout(() => resolve("SOMETHING WENT WRONG"), 7000)
    })
}

GO.addEventListener("mousedown", () => run())
