import { createServerClient } from '@supabase/ssr'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const response = NextResponse.next()
  const supabase = createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll: (cookies) => cookies.forEach(({ name, value, options }) => response.cookies.set(name, value, options)),
    },
  })

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return NextResponse.json({ error: 'Authentication required.' }, { status: 401 })
  }

  const complaintId = request.nextUrl.searchParams.get('complaintId')
  if (!complaintId) {
    return NextResponse.json({ error: 'Complaint ID is required.' }, { status: 400 })
  }

  const { data: complaint, error: complaintError } = await supabase
    .from('complaints')
    .select('id,user_id')
    .eq('id', complaintId)
    .maybeSingle()

  if (complaintError || !complaint) {
    return NextResponse.json({ error: 'Complaint not found.' }, { status: 404 })
  }

  const canAccess = complaint.user_id === user.id || user.role === 'admin'
  if (!canAccess) {
    return NextResponse.json({ error: 'Forbidden.' }, { status: 403 })
  }

  const { data: fileData, error: fileError } = await supabase
    .from('complaints')
    .select('photo_path,resolution_photo_path')
    .eq('id', complaintId)
    .maybeSingle()

  if (fileError || !fileData) {
    return NextResponse.json({ error: 'Evidence unavailable.' }, { status: 404 })
  }

  const urls: Record<string, string> = {}
  const paths = [fileData.photo_path, fileData.resolution_photo_path].filter(Boolean) as string[]

  for (const path of paths) {
    const { data, error } = await supabase.storage.from('complaint-photos').createSignedUrl(path, 600)
    if (!error && data?.signedUrl) {
      urls[path] = data.signedUrl
    }
  }

  return NextResponse.json({ urls })
}
