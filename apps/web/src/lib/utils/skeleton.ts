export function randomVideoThumbnail() {
	const opts = [
		'https://cdn.satellite.earth/01a8a5f5162a90fd7e6d3af6bc86d975e08a98f1852864c8ae7d8ba547bad669.png'
	];

	return opts[Math.floor(Math.random() * opts.length)];
}
