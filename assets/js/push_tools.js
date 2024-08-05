
function urlBase64ToUint8Array(base64String) {
	const padding = '='.repeat((4 - base64String.length % 4) % 4);
	const base64 = (base64String + padding)
		.replace(/-/g, '+')
		.replace(/_/g, '/');

	const rawData = window.atob(base64);
	const outputArray = new Uint8Array(rawData.length);

	for (let i = 0; i < rawData.length; ++i) {
		outputArray[i] = rawData.charCodeAt(i);
	}
	return outputArray;
}

function getSubscription() {
	return new Promise((resolve, reject) => {
		if ('serviceWorker' in navigator && 'PushManager' in window) {
			navigator.serviceWorker.ready
				.then((registration) => {
					return registration.pushManager.getSubscription();
				})
				.then((subscription) => {
					resolve(subscription);
				})
				.catch(reject);
		} else {
			reject(null);
		}
	});
}

function subscribe(options) {
	if (options.serverKey == null
		|| options.csrfToken == null
	) {
		return new Promise((_, reject) => { reject(null); })
	}

	return new Promise(async (resolve, reject) => {
		const permission = await Notification.requestPermission();

		if (permission === 'granted') {
			const registration = await navigator.serviceWorker.ready;
			const subscribeOptions = {
				userVisibleOnly: true,
				applicationServerKey: urlBase64ToUint8Array(options.serverKey),
			};

			const subscription = await registration.pushManager.subscribe(subscribeOptions);

			const response = await fetch("/api/subscribe", {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'x-csrf-token': options.csrfToken,
				},
				body: JSON.stringify({
					subscription: JSON.stringify(subscription),
				}),
			});

			const response_json = await response.json();

			resolve({ response: response_json });
		} else {
			reject({ permission });
		}
	});
}

export default {
	getSubscription,
	subscribe,
};

