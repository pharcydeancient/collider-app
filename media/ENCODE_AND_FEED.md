# Collider media ingest
Buckets: media-public (posters + free 720), media-premium (private paid streams).
Paths: live/<category>/<slug>/{poster.webp,720.mp4,1080.mp4}, still/<category>/<slug>/poster.webp, audio/<category>/<slug>.m4a
Run 001_media_assets.sql. Locked premium is dim/mist/smoke, never blur. Poster paints first.
