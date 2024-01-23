export function isImage(url: string) {
	return url.match(/\.(jpeg|jpg|gif|png|webp|tiff|psd|raw|bmp|heif)$/i);
}

export function isVideo(url: string) {
	return url.match(/\.(mp4|webm|ogg|mov|avi|wmv|flv|mkv)$/i);
}

export function isYoutube(url: string) {
	return url.match(/^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+/i);
}

export function youtubeIdFromUrl(url: string) {
	const match = url.match(/^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+/i);
	if (!match) return null;

	const id = match[0].split('/').pop();
	if (!id) return null;

	return id;
}
