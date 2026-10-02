import { createClient } from '@supabase/supabase-js'

export type Plate = {
  id: string
  kind: 'live' | 'still' | 'audio'
  title: string
  posterUrl: string | null
  streamUrl: string
}

/** Catalog is the bucket. No media_assets table. */
export async function listMedia(url: string, anonKey: string, bucket = 'media-public'): Promise<Plate[]> {
  const supabase = createClient(url, anonKey)
  const { data: roots, error } = await supabase.storage.from(bucket).list('', { limit: 100 })
  if (error) throw error
  const plates: Plate[] = []
  for (const kind of ['live', 'still', 'audio'] as const) {
    if (!roots?.some((r) => r.name === kind)) continue
    const { data: items } = await supabase.storage.from(bucket).list(kind, { limit: 200 })
    for (const item of items ?? []) {
      if (!item.name || item.name.startsWith('.')) continue
      if (kind === 'audio') {
        plates.push({
          id: `${kind}/${item.name}`,
          kind,
          title: item.name.replace(/\.[^.]+$/, ''),
          posterUrl: null,
          streamUrl: supabase.storage.from(bucket).getPublicUrl(`${kind}/${item.name}`).data.publicUrl,
        })
        continue
      }
      const base = `${kind}/${item.name}`
      const poster = supabase.storage.from(bucket).getPublicUrl(`${base}/poster.webp`).data.publicUrl
      const stream = kind === 'live'
        ? supabase.storage.from(bucket).getPublicUrl(`${base}/720.mp4`).data.publicUrl
        : poster
      plates.push({ id: base, kind, title: item.name, posterUrl: poster, streamUrl: stream })
    }
  }
  return plates
}
