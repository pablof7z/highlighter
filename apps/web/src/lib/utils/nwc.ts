export function isNwcAvailable() {
	const jwt = localStorage.getItem('jwt');
	if (!jwt) return false;

	try {
		const jwtPayload = JSON.parse(Buffer.from(jwt.split('.')[1], 'base64').toString('utf-8'));
		
		return !!jwtPayload?.nwcAvailable;
	} catch {
		return false;
	}
}
