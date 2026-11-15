importScripts("https://www.gstatic.com/firebasejs/11.0.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/11.0.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBdRVZ0_Yx3ItWpiToFXgM2UeshQbqwvII",
  authDomain: "course-explorer-guntur.firebaseapp.com",
  projectId: "course-explorer-guntur",
  storageBucket: "course-explorer-guntur.firebasestorage.app",
  messagingSenderId: "772182352528",
  appId: "1:772182352528:web:477d3169004a0d5b9d6e15"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[BACKGROUND SW] Received background message ', payload);
  const title = payload.notification?.title || payload.data?.title || 'KosFinder';
  const options = {
    body: payload.notification?.body || payload.data?.body || 'Kos baru tersedia di sekitar kampus.',
    icon: '/icons/Icon-192.png',
    requireInteraction: true
  };
  return self.registration.showNotification(title, options);
});