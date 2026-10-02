# Drop files. The app reads the bucket.

No SQL paste. No CSV.

1. Create bucket `media-public` once, public.
2. Drag `live/<name>/poster.webp` and `live/<name>/720.mp4` into that bucket. Same for `still/` and `audio/`.
3. The client lists the bucket and builds the catalog.

Optional one command if the service key is in the environment:

```
export SUPABASE_URL=...
export SUPABASE_SERVICE_KEY=...
./upload.sh
```

`upload.sh` encodes `inbox/` and uploads `out/` to `media-public`. The app still does not need a pasted insert.
