#!/usr/bin/env bash
# Encodes inbox/ and uploads out/ to media-public. No paste.
set -euo pipefail
cd "$(dirname "$0")"
: "${SUPABASE_URL:?set SUPABASE_URL}"
: "${SUPABASE_SERVICE_KEY:?set SUPABASE_SERVICE_KEY}"
./batch.sh
python3 - << 'PY'
import os, pathlib, urllib.request
root = pathlib.Path('out')
base = os.environ['SUPABASE_URL'].rstrip('/') + '/storage/v1/object/media-public/'
key = os.environ['SUPABASE_SERVICE_KEY']
for p in root.rglob('*'):
    if not p.is_file() or p.name == 'paste.csv':
        continue
    rel = str(p.relative_to(root)).replace('\\', '/')
    data = p.read_bytes()
    req = urllib.request.Request(base + rel, data=data, method='POST')
    req.add_header('Authorization', 'Bearer ' + key)
    req.add_header('apikey', key)
    req.add_header('x-upsert', 'true')
    req.add_header('Content-Type', 'application/octet-stream')
    try:
        urllib.request.urlopen(req)
        print('up', rel)
    except Exception as e:
        print('fail', rel, e)
PY
echo 'App lists media-public. Nothing to paste.'
