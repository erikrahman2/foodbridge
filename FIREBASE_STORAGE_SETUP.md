# Setup Firebase Storage CORS untuk Web

## Error yang Muncul:

```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...'
from origin 'http://localhost:56222' has been blocked by CORS policy
```

## Solusi:

### 1. Install Google Cloud SDK

Download dan install dari: https://cloud.google.com/sdk/docs/install

### 2. Login ke Google Cloud

```bash
gcloud auth login
```

### 3. Set Project ID

Ganti `YOUR_PROJECT_ID` dengan Firebase Project ID Anda:

```bash
gcloud config set project YOUR_PROJECT_ID
```

### 4. Apply CORS Configuration

Jalankan command ini di folder project:

```bash
gsutil cors set cors.json gs://YOUR_PROJECT_ID.appspot.com
```

### 5. Verify CORS Settings

```bash
gsutil cors get gs://YOUR_PROJECT_ID.appspot.com
```

## Alternatif Tanpa CORS Setup (Testing):

Untuk testing sementara, gunakan Firebase Storage Rules yang permissive:

1. Buka Firebase Console > Storage > Rules
2. Gunakan rules ini:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **WARNING**: Rules di atas hanya untuk testing! Jangan gunakan di production.

## Production Rules (Recommended):

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /food_images/{imageId} {
      // Allow read for all
      allow read: if true;

      // Allow write only for authenticated sellers
      allow write: if request.auth != null;
    }
  }
}
```

## Cara Cek Project ID Firebase:

1. Buka Firebase Console: https://console.firebase.google.com
2. Pilih project Anda
3. Settings > General
4. Lihat di "Project ID"
