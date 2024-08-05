
self.addEventListener('install', (event) => {
	console.log('Service Worker installed');
});

self.addEventListener('activate', (event) => {
	console.log('Service Worker activated');
});

self.addEventListener('fetch', (event) => {
	// Do nothing, let the browser handle the request normally
});

self.addEventListener('notificationclick', (event) => {
	
});

self.addEventListener('push', (event) => {
	if (!event.data) {
		console.warning("Received a push event which has no data!");
		return;
	}

	const promiseChain = self.registration.showNotification(
		"🔔 Ping", {
			body: event.data.text(),
			silent: true,
			icon: '/images/notification-icon.png',
			badge: '/images/notification-badge.png',
			actions: [
				/* {action: 'reply', title: "Reply", icon: undefined}, */
				/* {action: 'mark-spam', title: "Mark spam", icon: undefined}, */
			],
		}
	);

	event.waitUntil(promiseChain);
});

