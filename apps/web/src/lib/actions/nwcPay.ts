export async function nwcPay(invoice: string) {
	const res = await fetch('/api/user/pay', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify({ invoice })
	});

	const status = res.status;
	const json = await res.json();

	if (status !== 200) throw new Error(json.error);

	return json.preimage;
}
