
self.addEventListener('install', (event) => {
	//console.log('Service Worker installed');
});

self.addEventListener('activate', (event) => {
	//console.log('Service Worker activated');
});

self.addEventListener('fetch', (event) => {
	// Do nothing, let the browser handle the request normally
});

self.addEventListener('notificationclick', (event) => {
	event.notification.close();
	
	const promiseChain = fetch(
		'/api/notification_action',
		{
			method: 'POST',
			body: JSON.stringify(event),
			headers: {
				'Content-Type': 'application/json',
			},
		}
	);
	event.waitUntil(promiseChain);
});

self.addEventListener('push', (event) => {
	const eventData = event.data?.json();

	if (!eventData) {
		console.warning("Received a push event which has no data!");
		return;
	}

	const promiseChain = self.registration.showNotification(
		eventData.title ?? "🔔 Ping",
		{
			body: eventData.message ?? undefined,
			silent: eventData.silent ?? true,
			icon: '/images/notification-icon.png',
			badge: '/images/notification-badge.png',
			actions: eventData.actions,
			/*actions: [
				/* {action: 'reply', title: "Reply", icon: undefined}, */
				/* {action: 'mark-spam', title: "Mark spam", icon: undefined}, */
			//],
		}
	);

	event.waitUntil(promiseChain);
});

