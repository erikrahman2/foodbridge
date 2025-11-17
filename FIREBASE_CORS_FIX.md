# Fix CORS Firebase Storage - Metode Firebase Console

## ❌ Masalah

```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...'
from origin 'http://localhost:57545' has been blocked by CORS policy
```

## ✅ Solusi 1: Firebase Console (TERMUDAH)

### Langkah 1: Buka Firebase Console

1. Buka: https://console.firebase.google.com/
2. Pilih project: **FoodBridge**
3. Klik **Storage** di menu kiri

### Langkah 2: Atur CORS Rules

1. Klik tab **Rules**
2. Ganti rules dengan:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;  // Semua orang bisa baca
      allow write: if request.auth != null;  // Hanya user login bisa upload
    }
  }
}
```

3. Klik **Publish**

### Langkah 3: Enable Cross-Origin Access

**PENTING:** Firebase Storage secara default sudah support CORS untuk domain yang valid.

Masalahnya adalah `localhost` dengan port random. Solusinya:

## ✅ Solusi 2: Deploy ke Hosting (RECOMMENDED)

Upload ke Firebase Hosting sehingga domain sama:

```bash
firebase deploy --only hosting
```

Aplikasi akan jalan di: `https://YOUR-PROJECT.web.app`

## ✅ Solusi 3: Gunakan Signed URL (Workaround)

Ubah flow menjadi:

1. Upload gambar ke temporary storage
2. Generate signed URL dengan expiry
3. Save URL ke Firestore

## ✅ Solusi 4: Cloud Functions untuk Upload

Buat Cloud Function sebagai proxy upload:

```javascript
exports.uploadImage = functions.https.onCall(async (data, context) => {
  const bucket = admin.storage().bucket();
  const file = bucket.file(`food_images/${Date.now()}.jpg`);

  await file.save(Buffer.from(data.image, "base64"), {
    metadata: { contentType: "image/jpeg" },
  });

  const [url] = await file.getSignedUrl({
    action: "read",
    expires: "03-01-2500",
  });

  return { url };
});
```

## 🎯 Solusi Sementara: URL Input

Untuk development saat ini, gunakan URL dari:

- **Imgur**: https://imgur.com/upload
- **Pexels**: https://www.pexels.com/
- **Unsplash**: https://unsplash.com/

Upload gambar → Copy URL → Paste di form

---

## 📝 Catatan

CORS error muncul karena:

1. Firebase Storage punya CORS policy ketat
2. `localhost` dengan port random dianggap origin berbeda
3. Web browser block cross-origin requests

**Solusi terbaik**: Deploy ke Firebase Hosting untuk production use.
