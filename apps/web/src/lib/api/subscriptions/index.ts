export async function getAllActibeSubscriptions() {
	const res = await fetch('/api/subscriptions');
	return res.json();
}
