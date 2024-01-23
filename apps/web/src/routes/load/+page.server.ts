// import Parser from "rss-parser";

export async function load({ fetch, url }) {
	const loadUrl = url.searchParams.get('url');
	const rss = url.searchParams.get('rss');
	const itemUrl = url.searchParams.get('itemUrl');

	if (rss && itemUrl) {
		// return await loadRss(rss, itemUrl);
	} else if (loadUrl) {
		return await fetchUrl(loadUrl, fetch);
	}
}

async function fetchUrl(url: string, _fetch: typeof fetch) {
	const response = await _fetch(url);
	let contentType = response.headers.get('content-type').split(';')[0];
	const text = await response.text();

	if (url.startsWith('https://overcast.fm/+')) {
		contentType = 'embed/overcast';
	} else if (url.startsWith('https://youtube.com/watch')) {
		contentType = 'embed/youtube';
	}

	return {
		text,
		contentType
	};
}

async function loadRss(url: string, itemUrl: string) {
	// const parser = new Parser();
	// const feed = await parser.parseURL(url);
	// const item = feed.items.find(item => item.link === itemUrl);
	// console.log(item);
	// return {
	//     title: item!.title,
	//     text: item!.content,
	//     contentType: 'text/rss',
	//     articleUrl: item!.link,
	// };
}
