'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "90747fccea17bce9044ae7be4b477a17",
"assets/AssetManifest.bin.json": "088fddbc1702af9fd6f9ad452af8b999",
"assets/AssetManifest.json": "e4e02dd3de5dbc371294dd30f4ef6cb6",
"assets/assets/fonts/Poppins-Bold.ttf": "08c20a487911694291bd8c5de41315ad",
"assets/assets/fonts/Poppins-Light.ttf": "fcc40ae9a542d001971e53eaed948410",
"assets/assets/fonts/Poppins-Medium.ttf": "bf59c687bc6d3a70204d3944082c5cc0",
"assets/assets/fonts/Poppins-Regular.ttf": "093ee89be9ede30383f39a899c485a82",
"assets/assets/fonts/Poppins-SemiBold.ttf": "6f1520d107205975713ba09df778f93f",
"assets/assets/icons/bread.png": "911b7aa95afd1b9b553119a54c4ca4e5",
"assets/assets/icons/burger.png": "387dd73b1b30c6f8b440d31422a7d972",
"assets/assets/icons/burgercat.png": "dd5328bfd9726a1d20eae7ab5160aa1a",
"assets/assets/icons/donuts.png": "60c5528fd133dda5454a8bf3e9b7d439",
"assets/assets/icons/friedcat.png": "fb6e3a3e68881a96bc878e7b2cb5e5ad",
"assets/assets/icons/gorengan.png": "87ad8af34dd9a7024aa902f9f28255ff",
"assets/assets/icons/iccat.png": "d9327725e82a7c3b0f2ef666fe2fc9a6",
"assets/assets/icons/icecream.png": "1478cf166051f06b93ffe0f59a3617f2",
"assets/assets/icons/iscat.png": "ba7ac3eb253e2d2d9bbfece9851ca842",
"assets/assets/icons/jus.png": "f545f55f88e67387006213012dc317ca",
"assets/assets/icons/juscat.png": "b05340ebe9497cce6d63a59a162c1d43",
"assets/assets/icons/mie.png": "784acd3048b02fd5501ea0b76417e610",
"assets/assets/icons/more.png": "fa22df5b7df27b97e930b90604234e9a",
"assets/assets/icons/nasgorcat.png": "e3334f39f2a777142bf09fb322305851",
"assets/assets/icons/nasigoreng.png": "00957f2d5d5736c8fe1afcd2c742c756",
"assets/assets/icons/nasningcat.png": "baf6aa3ea5fffa3e8c1f4fc7837e5218",
"assets/assets/icons/roticat.png": "73f3b2be43dcccb81f5623b6bbbc2a1f",
"assets/assets/icons/salad.png": "d1678bcc876fc1441c2a37a9dc496525",
"assets/assets/icons/sotocat.png": "b2b18d31f3e2d9a0ae9ae744c3fae5f6",
"assets/assets/images/aicream.png": "5b9c9e138b0d5a46d45e92ceda3a16f4",
"assets/assets/images/amperaf.jpg": "1db8ad7eecc2e20065e8c7a23ef00956",
"assets/assets/images/amperaf_2.jpg": "2c3907a3ee96e13ab4f8cdcb8fbe02d9",
"assets/assets/images/amperaf_3.jpg": "71968aea014fcc75da7f51cb931ef726",
"assets/assets/images/amperaf_4.jpg": "0e71a6b8a19bec5eb9d707f55a8a328a",
"assets/assets/images/anekajus.jpg": "173f69654188f5038d98a10574fd744d",
"assets/assets/images/baso.jpg": "21e8fb2fb4a3fc53761ed97b511006e8",
"assets/assets/images/bigspa.jpg": "97ee68bb6bfb88576e0c7f857bb8aaef",
"assets/assets/images/bluenoodles.jpg": "11dd5493b6e34f83f74249f1617b6555",
"assets/assets/images/bobabread.jpg": "ae39a4b01efa8d81e67cd7ef295a592d",
"assets/assets/images/burger2.jpg": "894de9f0777fc3df59dccc9eaf4bd662",
"assets/assets/images/cocodonut.jpg": "2081962415ea76e75930c044a7f654c6",
"assets/assets/images/croisco.jpg": "624e25fb3e36c9e077a8394c6d798796",
"assets/assets/images/Default_Create_an_image_of_a_small_3D_style_rocket_Has_white_b_2%25201.png": "14d40b588b8cb0ff64e3947554e55a99",
"assets/assets/images/dragonjus.jpg": "cca09ae78f68bf9f5d118e799f3ce292",
"assets/assets/images/eskelapa.jpg": "ac0fe0920c47aaae8805c0ff35a2280e",
"assets/assets/images/eskrim.jpg": "887806d469d1cddd1ccb64a16b9efadb",
"assets/assets/images/eskrim2.jpg": "85d5ac769526ebde4dc28fb15c1786b6",
"assets/assets/images/friedrice.jpg": "678bf7ac051d8a721594277fe510dbaf",
"assets/assets/images/friedrice_2.jpg": "2f5c3432d86430aabca2b73d61cc6c8d",
"assets/assets/images/gorengan.jpg": "3c30d59a9b51f1bfff32be71fbb32e03",
"assets/assets/images/gorengan2.jpg": "d52251ae891e3feb78870050a5b63e8c",
"assets/assets/images/Image%2520(2).png": "d56c34b386ffaa1e37752a8ef04dda5f",
"assets/assets/images/Image%2520(3).png": "8b01a0748c50300ac46cadf54d0aa70b",
"assets/assets/images/Image%2520(4).png": "ece25a80a6da98bc1bcd9c5fb3aa984b",
"assets/assets/images/jusbuah.jpg": "4bfd8559a8e858e7efefc5aa11516f2e",
"assets/assets/images/jussehat.jpg": "62d13d333e7b3b6c08e4889e0d27f3ed",
"assets/assets/images/katsu1.jpg": "88839c5fd9de62b83ac4279f3da3c821",
"assets/assets/images/kitdonut.jpg": "4cfba951103f8e0f6373de6da1471635",
"assets/assets/images/kopi.jpg": "2c32a91e7295c0a8a8000e8b14436c59",
"assets/assets/images/LogoOnboarding.png": "7fdcd52561edc074434beb4943d22e34",
"assets/assets/images/mathcajus.jpg": "3a6bc8b304c54fee8d3b1406b4e9faf1",
"assets/assets/images/mie2.jpg": "4ee0a9547eca3760286a5b3a3e852332",
"assets/assets/images/mieayam.jpg": "3338cc1665052c730068f68bbefb17ae",
"assets/assets/images/nasigoreng.jpg": "620c873a689e6b0ce44ea93c6c585a70",
"assets/assets/images/nasigoreng2.jpg": "694b6ae607528e3ebb1347d7ed2140ad",
"assets/assets/images/nasikuning.jpg": "032f1a7838b9ffa69dabb5845fa06196",
"assets/assets/images/nasikuning2.jpg": "0491d2abf91b674d6a4d32f26dbcc6e9",
"assets/assets/images/nasiuduk.jpg": "2c3907a3ee96e13ab4f8cdcb8fbe02d9",
"assets/assets/images/nasiuduk2.jpg": "1db8ad7eecc2e20065e8c7a23ef00956",
"assets/assets/images/pecellele.jpg": "cd919bd78e541dd776b1502cdb4545ab",
"assets/assets/images/ph1.jpg": "0cc84fbea37a8cc53e37b1395c1a1f57",
"assets/assets/images/ramena.jpg": "01bb7d6df5456fb95a1bd1098af3acb7",
"assets/assets/images/ramentpg.jpg": "f990076163802e8d54f968b58f39e5e0",
"assets/assets/images/rawdonut.jpg": "533d56e771c63dcc2ad63b8f7bd652aa",
"assets/assets/images/rnbwdonut.jpg": "be4404e13765e299fcaedcb6d18cda13",
"assets/assets/images/roti'i.jpg": "d533871ad85dfefcbc97036e4a94afb7",
"assets/assets/images/roti2.jpg": "f8a4ff5bd8a5c12277b38b88ee2aaafa",
"assets/assets/images/salad.jpg": "7b8fefe349c55f9224cd31238680e15d",
"assets/assets/images/saladb.png": "8e6d3440a22e630eb7b5fbeeac3b38f1",
"assets/assets/images/satepadang.jpg": "0de9406966ee883633707a165f1d62dd",
"assets/assets/images/soto.jpg": "b20ed2638c80edcccfd946fd732da964",
"assets/assets/images/soto2.jpg": "9616288b52e025362fc3f1a46c1eb162",
"assets/assets/images/strosmo.jpg": "9f1cd54793c1944ad5eb1410e5918839",
"assets/assets/images/sugarbread.jpg": "eb3a9513685319beddfc3b45957f53e0",
"assets/assets/images/sugarbread_2.jpg": "0d528502400948a8ce614ecab311f3ad",
"assets/assets/images/sugardonat.jpg": "fcd08560ef312ff71753c930a282c1b5",
"assets/assets/images/sushi21.jpg": "3b2d425c6a6bc5e7cf2d5a09b2322a04",
"assets/assets/images/sushi22.jpg": "d65492c6255e049d481ee409f791a7f0",
"assets/assets/images/yellowrice2.jpg": "032f1a7838b9ffa69dabb5845fa06196",
"assets/FontManifest.json": "23c089f16f0275e999f87deeeab6d169",
"assets/fonts/MaterialIcons-Regular.otf": "c493a9aac71ac6b3001fdd68f67607d8",
"assets/NOTICES": "f8fd0b7ffb0c2f3dd15cb76bb9a74dba",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "e9637967dd8d05eff15b0c23a45f3f2d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "24832db74816cb3340b52ab429a51f1e",
"/": "24832db74816cb3340b52ab429a51f1e",
"main.dart.js": "78ac1acb8b6a8a060064e05a0bcc2b22",
"manifest.json": "d17a2bc63fdd42024214a632c65fa0e9",
"version.json": "bd6d3b8b85f8344dca659ce5f0329cdb"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
