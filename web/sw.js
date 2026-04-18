// Service Worker for E-commerce PWA Experiment

self.addEventListener('install', (event) => {
  console.log('Service Worker: Installed Successfully.');
  // Force the waiting service worker to become the active service worker.
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activated Successfully.');
  // Tell the active service worker to take control of the page immediately.
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Pass-through default fetch handler
});
