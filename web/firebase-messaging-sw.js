importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyB1VHXoiOan6z3XFfOLzRLfTC1PPVm8_Ro",
  authDomain: "currencyconverter-2d61d.firebaseapp.com",
  projectId: "currencyconverter-2d61d",
  storageBucket: "currencyconverter-2d61d.firebasestorage.app",
  messagingSenderId: "71306683320",
  appId: "1:71306683320:web:5a4ca4bc5c38642e38a54d"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  const notificationTitle = payload.notification?.title || 'Background Message';
  const notificationOptions = {
    body: payload.notification?.body || 'No body provided',
    icon: '/firebase-logo.png' // Ensure this exists in web/
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Log service worker activation
self.addEventListener('install', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker installed');
});

self.addEventListener('activate', (event) => {
  console.log('[firebase-messaging-sw.js] Service Worker activated');
});