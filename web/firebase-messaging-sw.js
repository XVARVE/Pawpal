/* web/firebase-messaging-sw.js */
/* eslint-disable no-undef */

// Use the *compat* SDKs in a classic service worker:
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// ⬇️ Paste your *Web* app config from Firebase console (Project settings → Your apps → Web app)
firebase.initializeApp({
  apiKey: "AIzaSyAN0zHSqyutY1LjtgO4igZlezw8p8I_stA",
  authDomain: "pawpal-128f4.firebaseapp.com",
  databaseURL: "https://pawpal-128f4-default-rtdb.firebaseio.com",
  projectId: "pawpal-128f4",
  storageBucket: "pawpal-128f4.firebasestorage.app",
  messagingSenderId: "380239055049",
  chappId: "1:380239055049:web:f6dc2371b3ab56ba79e518"
  // databaseURL optional for FCM
});

// Initialize messaging
const messaging = firebase.messaging();

// Optional: show a notification when a push arrives in the background
messaging.onBackgroundMessage((payload) => {
  const title = payload?.notification?.title || 'PawPal';
  const options = {
    body: payload?.notification?.body || '',
    icon: '/icons/Icon-192.png', // ensure this exists under /web/icons
    data: payload?.data || {},
  };
  self.registration.showNotification(title, options);
});

// Optional: handle notification clicks (keeps SPA focus)
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = self.location.origin + '/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((wins) => {
      for (const w of wins) {
        if (w.url.startsWith(self.location.origin)) {
          w.focus();
          return;
        }
      }
      return clients.openWindow(targetUrl);
    })
  );
});
