export function randomImage(seed: string, width: number, height: number): string {
    seed = encodeURIComponent(seed);
    return `https://picsum.photos/seed/${seed}/${width}/${height}`;
}