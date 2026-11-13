// Firebase App ve Messaging SDK'larını içe aktar
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

// Firebase Web Yapılandırması
firebase.initializeApp({
  apiKey: "AIzaSyB-dclC6QJz2O5W6HN7HLtNF8mrMXK5-oE",
  authDomain: "basibozuklar26.firebaseapp.com",
  projectId: "basibozuklar26",
  storageBucket: "basibozuklar26.appspot.com",
  messagingSenderId: "488840175464",
  appId: "1:488840175464:web:d981057fbe2836896a80dd"
});

const messaging = firebase.messaging();

// Arka planda (uygulama kapalıyken) gelen bildirimleri yakala ve göster
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Arka plan mesajı alındı: ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Uygulama ikonun
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});