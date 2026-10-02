#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p inbox out/live out/still out/audio
CSV=out/paste.csv
echo "kind,category,title,poster_path,stream_path,hi_path,duration_ms,motion,premium,locked_treatment,sort" > "$CSV"
n=10
slug() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g;s/--*/-/g;s/^-//;s/-$//'; }
shopt -s nullglob
for f in inbox/*; do
  base=$(basename "$f")
  name="${base%.*}"
  s=$(slug "$name")
  [ -z "$s" ] && continue
  ext=$(echo "${base##*.}" | tr '[:upper:]' '[:lower:]')
  case "$ext" in
    mp4|mov|mkv|webm)
      d="out/live/$s"; mkdir -p "$d"
      ffmpeg -y -i "$f" -an -pix_fmt yuv420p -r 24 -movflags +faststart -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" -c:v libx264 -preset fast -crf 23 "$d/1080.mp4"
      ffmpeg -y -i "$d/1080.mp4" -an -movflags +faststart -vf "scale=720:1280" -c:v libx264 -preset fast -crf 24 "$d/720.mp4"
      ffmpeg -y -ss 3 -i "$d/1080.mp4" -frames:v 1 "$d/poster.jpg"
      ffmpeg -y -i "$d/poster.jpg" -c:v libwebp -quality 78 "$d/poster.webp"
      ms=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$d/720.mp4" | awk '{printf "%d", $1*1000}')
      echo "live,uncategorized,$name,live/$s/poster.webp,live/$s/720.mp4,live/$s/1080.mp4,$ms,weather,false,none,$n" >> "$CSV" ;;
    jpg|jpeg|png|webp)
      d="out/still/$s"; mkdir -p "$d"
      ffmpeg -y -i "$f" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920" -c:v libwebp -quality 80 "$d/poster.webp"
      echo "still,uncategorized,$name,still/$s/poster.webp,still/$s/poster.webp,,0,none,false,none,$n" >> "$CSV" ;;
    wav|mp3|m4a|aac|flac)
      mkdir -p out/audio
      ffmpeg -y -i "$f" -c:a aac -b:a 256k "out/audio/$s.m4a"
      ms=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "out/audio/$s.m4a" | awk '{printf "%d", $1*1000}')
      echo "audio,lofi,$name,,audio/$s.m4a,,$ms,none,true,dim,$n" >> "$CSV" ;;
    *) echo "skip $base" ;;
  esac
  n=$((n+10)); echo "done $base"
done
echo "Upload out/ folders to Supabase. Paste rows from out/paste.csv."
