# Setup CORS untuk Firebase Storage

## Masalah

Upload gambar ke Firebase Storage gagal karena CORS policy di web platform.

## Solusi: Setup CORS via Google Cloud SDK

### Langkah 1: Install Google Cloud SDK

1. Download dari: https://cloud.google.com/sdk/docs/install
2. Install dan restart terminal

### Langkah 2: Login ke Google Cloud

```bash
gcloud auth login
```

### Langkah 3: Set Project

```bash
# Ganti YOUR_PROJECT_ID dengan Firebase Project ID kamu
gcloud config set project YOUR_PROJECT_ID
```

### Langkah 4: Apply CORS Configuration

```bash
gsutil cors set cors.json gs://YOUR_BUCKET_NAME
```

Bucket name biasanya: `YOUR_PROJECT_ID.appspot.com`

### Langkah 5: Verify CORS

```bash
gsutil cors get gs://YOUR_BUCKET_NAME
```

## Alternatif Tanpa Setup CORS

Jika tidak bisa setup CORS, gunakan URL direct input sebagai method utama.
