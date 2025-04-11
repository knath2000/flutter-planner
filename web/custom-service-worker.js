// Custom Service Worker for Planner App

const CACHE_NAME = 'planner-app-cache-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter_service_worker.js',
  '/favicon.png',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('Service Worker: Installing...');
  
  // Skip waiting to ensure the new service worker activates immediately
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activating...');
  
  // Claim clients to ensure the service worker takes control immediately
  event.waitUntil(self.clients.claim());
  
  // Clean up old caches
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Clearing old cache', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Don't cache Firebase API calls
  if (url.hostname.includes('firestore.googleapis.com') || 
      url.hostname.includes('www.googleapis.com') ||
      url.pathname.includes('/api/')) {
    // Network-first strategy for API calls
    event.respondWith(networkFirstStrategy(event.request));
    return;
  }
  
  // Cache-first for static assets
  if (
    event.request.destination === 'style' ||
    event.request.destination === 'script' ||
    event.request.destination === 'font' ||
    event.request.destination === 'image' ||
    url.pathname.endsWith('.js') ||
    url.pathname.endsWith('.css') ||
    url.pathname.endsWith('.png') ||
    url.pathname.endsWith('.jpg') ||
    url.pathname.endsWith('.svg') ||
    url.pathname.endsWith('.json')
  ) {
    event.respondWith(cacheFirstStrategy(event.request));
    return;
  }
  
  // Stale-while-revalidate for HTML navigation
  if (
    event.request.mode === 'navigate' ||
    event.request.destination === 'document'
  ) {
    event.respondWith(staleWhileRevalidateStrategy(event.request));
    return;
  }
  
  // Default: network with cache fallback
  event.respondWith(
    fetch(event.request)
      .catch(() => caches.match(event.request))
  );
});

// Cache-first strategy implementation
function cacheFirstStrategy(request) {
  return caches.match(request)
    .then((cacheResponse) => {
      if (cacheResponse) {
        // Return cached response and update cache in background
        fetch(request)
          .then((networkResponse) => {
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(request, networkResponse);
              });
          })
          .catch(() => {
            // Ignore network errors when updating cache
          });
          
        return cacheResponse;
      }
      
      // If not in cache, fetch from network and cache
      return fetch(request)
        .then((networkResponse) => {
          // Clone the response as it can only be consumed once
          const responseToCache = networkResponse.clone();
          
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(request, responseToCache);
            });
            
          return networkResponse;
        });
    });
}

// Network-first strategy implementation
function networkFirstStrategy(request) {
  return fetch(request)
    .then((networkResponse) => {
      // Clone the response
      const responseToCache = networkResponse.clone();
      
      caches.open(CACHE_NAME)
        .then((cache) => {
          cache.put(request, responseToCache);
        });
        
      return networkResponse;
    })
    .catch(() => {
      // If network fails, try to serve from cache
      return caches.match(request);
    });
}

// Stale-while-revalidate strategy implementation
function staleWhileRevalidateStrategy(request) {
  return caches.open(CACHE_NAME)
    .then((cache) => {
      return cache.match(request)
        .then((cachedResponse) => {
          // Create a promise for the network request
          const fetchPromise = fetch(request)
            .then((networkResponse) => {
              // Update the cache with the new response
              cache.put(request, networkResponse.clone());
              return networkResponse;
            })
            .catch((error) => {
              console.error('Fetch failed:', error);
              // If offline page exists, return it for navigation requests
              if (request.mode === 'navigate') {
                return caches.match('/offline.html');
              }
              throw error;
            });
          
          // Return the cached response immediately, or wait for network response if not in cache
          return cachedResponse || fetchPromise;
        });
    });
}

// Redundant fetch listener removed (Offline fallback handled in staleWhileRevalidateStrategy)

// Background sync for offline actions
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-data') {
    event.waitUntil(syncData());
  }
});

// Function to sync data when back online
async function syncData() {
  // This would be implemented to process queued actions from IndexedDB
  console.log('Background sync triggered');
  
  // Example implementation would:
  // 1. Open IndexedDB
  // 2. Get all queued actions
  // 3. Process each action by sending to server
  // 4. Remove successful actions from queue
  
  return Promise.resolve(); // Placeholder for actual implementation
}