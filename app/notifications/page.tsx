'use client'
import { useEffect, useState } from 'react'
import { CheckCircle2, MapPin, Bell, Sparkles, Loader2 } from 'lucide-react'
import { supabase } from '@/lib/supabase'

type Notification = {
  id: string
  title: string
  message: string
  created_at: string
  read: boolean
}

export default function NotificationCenter() {
  const [items, setItems] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const load = async () => {
      if (!supabase) {
        setLoading(false)
        return
      }

      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (!error) setItems(data || [])
      setLoading(false)
    }

    load()
  }, [])

  const markRead = async (id: string) => {
    const next = items.map((item) => item.id === id ? { ...item, read: true } : item)
    setItems(next)
    await supabase?.from('notifications').update({ read: true }).eq('id', id)
  }

  return (
    <div className="mx-auto max-w-4xl px-6 py-14 lg:px-10">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[.25em] text-gold">Alerts</p>
          <h1 className="mt-3 text-5xl">Notifications</h1>
        </div>
        <div className="rounded-full border border-gold/20 bg-ivory px-4 py-2 text-xs uppercase tracking-[.2em] text-navy/60">
          {items.filter((x) => !x.read).length} new
        </div>
      </div>

      <div className="mt-8 space-y-4">
        {loading ? (
          <div className="grid gap-3">
            {[1, 2, 3].map((x) => (
              <div key={x} className="h-24 animate-pulse rounded-2xl bg-navy/5" />
            ))}
          </div>
        ) : items.length === 0 ? (
          <div className="glass rounded-2xl p-10 text-center shadow-luxury">
            <Bell size={32} className="mx-auto text-gold" />
            <p className="serif mt-4 text-3xl">No alerts yet.</p>
            <p className="mt-2 text-sm text-navy/55">Your issue updates will appear here.</p>
          </div>
        ) : (
          items.map((item) => (
            <div key={item.id} className={`glass rounded-2xl p-5 shadow-luxury ${item.read ? 'opacity-75' : ''}`}>
              <div className="flex items-start justify-between gap-4">
                <div className="flex gap-4">
                  <div className="grid h-12 w-12 place-items-center rounded-2xl bg-gold/10 text-gold">
                    {item.read ? <CheckCircle2 size={20} /> : <Sparkles size={20} />}
                  </div>
                  <div>
                    <p className="text-lg font-semibold">{item.title}</p>
                    <p className="mt-1 text-sm text-navy/55">{item.message}</p>
                    <p className="mt-3 text-[11px] uppercase tracking-[.2em] text-navy/40">{new Date(item.created_at).toLocaleString()}</p>
                  </div>
                </div>

                {!item.read && (
                  <button
                    type="button"
                    onClick={() => markRead(item.id)}
                    className="rounded-full border border-gold/30 bg-ivory px-4 py-2 text-[10px] font-semibold uppercase tracking-[.2em] text-navy"
                  >
                    Mark read
                  </button>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
