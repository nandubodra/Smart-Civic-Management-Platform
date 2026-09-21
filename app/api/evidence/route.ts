import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const response = NextResponse.next()
  const supabase = createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, {
    cookies: { getAll: () => request.cookies.getAll(), setAll: (cookies) => cookies.forEach(({ name, value, options }) => response.cookies.set(name, value, options)) },
  })
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Authentication required.' }, { status: 401 })
  const complaintId = request.nextUrl.searchParams.get('complaintId')
  if (!complaintId) return NextResponse.json({ error: 'Complaint ID is required.' }, { status: 400 })
  const { data: complaint, error } = await supabase.from('complaints').select('id,photo_path,resolution_photo_path').eq('id', complaintId).maybeSingle()
  if (error || !complaint) return NextResponse.json({ error: 'Evidence not found or access denied.' }, { status: 404 })
  const paths = [complaint.photo_path, complaint.resolution_photo_path].filter(Boolean) as string[]
  const signed: Record<string, string> = {}
  if (paths.length) {
    const { data, error: signError } = await supabase.storage.from('complaint-photos').createSignedUrls(paths, 600)
    if (signError) return NextResponse.json({ error: 'Could not authorize evidence.' }, { status: 500 })
    data?.forEach((item) => { if (item.path && item.signedUrl) signed[item.path] = item.signedUrl })
  }
  return NextResponse.json({ urls: signed, expiresIn: 600 }, { headers: { 'Cache-Control': 'private, max-age=540' } })
}
