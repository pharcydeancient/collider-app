# Drag, drop, paste

1. Put clips, photos, and tracks in inbox/.
2. Run ./batch.sh.
3. Drag out/live, out/still, out/audio into Supabase bucket media-public. Keep folder names.
4. Copy the INSERT the script prints. Paste it in the SQL editor. Run it.

One time: create public bucket media-public, paste 001_media_assets.sql once.
Paid tracks are premium=true. Put those files in media-premium, not the public bucket.
