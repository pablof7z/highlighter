export function niceDuration(durationInSeconds: number) {
    const hours = Math.floor(durationInSeconds / 3600);
    const minutes = Math.floor((durationInSeconds - hours * 3600) / 60);
    const seconds = Math.floor(durationInSeconds - hours * 3600 - minutes * 60);

    return `${hours ? hours + ":" : ""}${minutes}:${seconds < 10 ? "0" : ""}${seconds}`;
}