importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBdRVZ0_Yx3ItWpiToFXgM2UeshQbqwvII",
  authDomain: "course-explorer-guntur.firebaseapp.com",
  projectId: "course-explorer-guntur",
  storageBucket: "course-explorer-guntur.firebasestorage.app",
  messagingSenderId: "772182352528",
  appId: "1:772182352528:web:477d3169004a0d5b9d6e15"
});

const messaging = firebase.messaging();