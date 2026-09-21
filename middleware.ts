import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })
  const supabase = createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, {
    cookies: { getAll: () => request.cookies.getAll(), setAll: (cookies) => cookies.forEach(({ name, value, options }) => response.cookies.set(name, value, options)) },
  })
  const { data: { user } } = await supabase.auth.getUser()
  const protectedPath = ['/report', '/account', '/admin', '/worker'].some((path) => request.nextUrl.pathname.startsWith(path))
  if (protectedPath && !user) return NextResponse.redirect(new URL(`/login?next=${encodeURIComponent(request.nextUrl.pathname)}`, request.url))
  if (user && (request.nextUrl.pathname.startsWith('/admin') || request.nextUrl.pathname.startsWith('/worker'))) {
    const { data: profile } = await supabase.from('users').select('role').eq('id', user.id).maybeSingle()
    const allowed = request.nextUrl.pathname.startsWith('/admin') ? profile?.role === 'admin' : profile?.role === 'worker' || profile?.role === 'admin'
    if (!allowed) return NextResponse.redirect(new URL('/forbidden', request.url))
  }
  return response
}

export const config = { matcher: ['/report/:path*', '/account/:path*', '/admin/:path*', '/worker/:path*'] }
