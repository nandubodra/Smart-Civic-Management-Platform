'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { LayoutDashboard, MapPinned, ShieldCheck, Menu, X, LogIn } from 'lucide-react'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

export function Shell({ children }: { children: React.ReactNode }) {
  const path = usePathname()
  const [open, setOpen] = useState(false)
  const [signedIn, setSignedIn] = useState(false)
  const links = [['/dashboard', 'Live Map', MapPinned], ['/report', 'Report Waste', ShieldCheck], ['/admin', 'Authority', LayoutDashboard]] as const

  useEffect(() => {
    if (!supabase) return
    supabase.auth.getSession().then(({ data }) => setSignedIn(Boolean(data.session)))
    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => setSignedIn(Boolean(session)))
    return () => listener.subscription.unsubscribe()
  }, [])

  return <>
    <header className="fixed top-0 z-50 w-full border-b border-gold/20 bg-ivory/85 backdrop-blur-xl">
      <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 lg:px-10">
        <Link href="/" className="flex items-center gap-3" onClick={() => setOpen(false)}><span className="grid h-10 w-10 place-items-center rounded-full bg-navy text-lg text-gold">✦</span><span className="serif text-xl font-semibold tracking-wide">Safai<span className="text-gold">Setu</span></span></Link>
        <nav className={`${open ? 'flex' : 'hidden'} absolute left-0 top-20 w-full flex-col gap-5 border-b border-gold/20 bg-ivory p-6 md:static md:flex md:w-auto md:flex-row md:border-0 md:bg-transparent md:p-0`}>
          {links.map(([href, label, Icon]) => <Link key={href} href={href} onClick={() => setOpen(false)} className={`flex items-center gap-2 text-sm ${path === href ? 'font-semibold text-gold' : 'text-navy/65 hover:text-navy'}`}><Icon size={16} />{label}</Link>)}
          <Link href="/report" className="rounded-full bg-navy px-5 py-3 text-center text-xs font-semibold uppercase tracking-[.16em] text-ivory shadow-luxury">Report an issue</Link>
          <Link href={signedIn ? '/account' : '/login'} onClick={() => setOpen(false)} className="flex items-center justify-center gap-2 rounded-full border border-gold/40 px-5 py-3 text-center text-xs font-semibold uppercase tracking-[.16em] text-navy"><LogIn size={15} />{signedIn ? 'Account' : 'Citizen login'}</Link>
        </nav>
        <button className="md:hidden" onClick={() => setOpen(!open)}>{open ? <X /> : <Menu />}</button>
      </div>
    </header>
    <main className="min-h-screen pt-20">{children}</main>
    <footer className="border-t border-gold/20 py-10"><div className="mx-auto flex max-w-7xl flex-col justify-between gap-4 px-6 text-xs text-navy/50 md:flex-row md:px-10"><span>© 2026 SafaiSetu Civic Network</span><span>Built for cleaner, stronger villages.</span></div></footer>
  </>
}
