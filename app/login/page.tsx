'use client'
import { FormEvent, useState } from 'react'
import Link from 'next/link'
import { ArrowLeft, CheckCircle2, Loader2, Smartphone } from 'lucide-react'
import { supabase } from '@/lib/supabase'

export default function LoginPage() {
  const [phone, setPhone] = useState('')
  const [otp, setOtp] = useState('')
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  const sendOtp = async (event: FormEvent) => {
    event.preventDefault(); setLoading(true); setError(''); setMessage('')
    if (!supabase) { setError('Add Supabase credentials to enable phone login.'); setLoading(false); return }
    const { error: requestError } = await supabase.auth.signInWithOtp({ phone })
    if (requestError) setError(requestError.message)
    else { setSent(true); setMessage('A verification code has been sent to your phone.') }
    setLoading(false)
  }

  const verifyOtp = async (event: FormEvent) => {
    event.preventDefault(); setLoading(true); setError('')
    if (!supabase) return
    const { error: verifyError } = await supabase.auth.verifyOtp({ phone, token: otp, type: 'sms' })
    if (verifyError) setError(verifyError.message)
    else window.location.href = '/report'
    setLoading(false)
  }

  return <div className="mx-auto grid min-h-[calc(100vh-180px)] max-w-6xl items-center gap-14 px-6 py-16 lg:grid-cols-2 lg:px-10"><div><Link href="/" className="flex items-center gap-2 text-xs uppercase tracking-[.2em] text-navy/50"><ArrowLeft size={14} /> Back home</Link><p className="mt-16 text-xs font-semibold uppercase tracking-[.25em] text-gold">Citizen access</p><h1 className="mt-4 text-6xl leading-none">Your village,<br /><i className="font-normal text-gold">your voice.</i></h1><p className="mt-6 max-w-md leading-7 text-navy/55">Sign in with your phone to track reports, receive updates, and help verify progress in your community.</p></div><div className="glass rounded-3xl p-7 shadow-luxury md:p-10"><div className="mb-8 flex h-12 w-12 items-center justify-center rounded-full bg-navy text-gold"><Smartphone size={21} /></div><h2 className="text-3xl">{sent ? 'Enter your code' : 'Sign in securely'}</h2><p className="mt-2 text-sm leading-6 text-navy/55">{sent ? `We sent a six-digit code to ${phone}.` : 'No passwords. We will send a one-time verification code.'}</p>{!sent ? <form onSubmit={sendOtp} className="mt-8"><label className="text-sm font-semibold">Mobile number<input required type="tel" value={phone} onChange={e => setPhone(e.target.value)} placeholder="+91 98765 43210" className="mt-3 w-full rounded-xl border border-gold/30 bg-ivory p-4 outline-none focus:border-gold" /></label><button disabled={loading} className="mt-6 flex w-full items-center justify-center gap-2 rounded-xl bg-navy py-4 text-sm font-semibold uppercase tracking-[.15em] text-ivory disabled:opacity-60">{loading && <Loader2 size={16} className="animate-spin" />}Send verification code</button></form> : <form onSubmit={verifyOtp} className="mt-8"><label className="text-sm font-semibold">Verification code<input required inputMode="numeric" maxLength={6} value={otp} onChange={e => setOtp(e.target.value.replace(/\D/g, ''))} placeholder="000000" className="mt-3 w-full rounded-xl border border-gold/30 bg-ivory p-4 text-center text-xl tracking-[.5em] outline-none focus:border-gold" /></label><button disabled={loading} className="mt-6 flex w-full items-center justify-center gap-2 rounded-xl bg-navy py-4 text-sm font-semibold uppercase tracking-[.15em] text-ivory disabled:opacity-60">{loading && <Loader2 size={16} className="animate-spin" />}Verify and continue</button><button type="button" onClick={() => setSent(false)} className="mt-4 w-full text-xs text-navy/50 underline">Use a different number</button></form>}{message && <p className="mt-5 flex items-center gap-2 text-sm text-green-700"><CheckCircle2 size={16} />{message}</p>}{error && <p className="mt-5 text-sm text-red-700">{error}</p>}<p className="mt-8 text-xs leading-5 text-navy/45">By continuing, you agree to use SafaiSetu responsibly and help keep community reports accurate.</p></div></div>
}
