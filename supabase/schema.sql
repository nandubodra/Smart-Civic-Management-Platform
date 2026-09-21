'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { ArrowUpRight, Clock3, LogOut, MapPin, Image as ImageIcon, Loader2 } from 'lucide-react'
import { supabase } from '@/lib/supabase'

type Complaint = {
  id: string
  waste_type: string
  status: string
  created_at: string
  location_lat: number | null
  location_lng: number | null
  photo_path: string | null
  resolution_photo_path: string | null
  resolved_at: string | null
  resolution_notes: string | null
}

type VerificationSummary = {
  resolved: number
  unresolved: number
  total: number
  myVote: 'resolved' | 'unresolved' | null
}

export default function AccountPage() {
  const [rows, setRows] = useState<Complaint[]>([])
  const [urls, setUrls] = useState<Record<string, { before?: string; after?: string }>>({})
  const [verification, setVerification] = useState<Record<string, VerificationSummary>>({})
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    let active = true

    const load = async () => {
      if (!supabase) {
        setLoading(false)
        return
      }

      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        setLoading(false)
        return
      }

      const { data, error: loadError } = await supabase
        .from('complaints')
        .select('id,waste_type,status,created_at,location_lat,location_lng,photo_path,resolution_photo_path,resolved_at,resolution_notes')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

      if (loadError) {
        if (active) {
          setError(loadError.message)
          setLoading(false)
        }
        return
      }

      const items = (data || []) as Complaint[]
      if (active) {
        setRows(items)
      }

      const results = await Promise.all(
        items.map(async (row) => {
          const response = await fetch(`/api/evidence?complaintId=${row.id}`)
          if (!response.ok) return null
          const result = await response.json()
          return { row, urls: result.urls as Record<string, string> }
        })
      )

      if (active) {
        const map: Record<string, { before?: string; after?: string }> = {}
        results.forEach((item) => {
          if (!item) return
          const row = item.row
          map[row.id] = {
            before: row.photo_path ? item.urls[row.photo_path] : undefined,
            after: row.resolution_photo_path ? item.urls[row.resolution_photo_path] : undefined,
          }
        })
        setUrls(map)
      }

      const summaryResults = await Promise.all(
        items.map(async (row) => {
          const response = await fetch(`/api/verify?complaintId=${row.id}`)
          if (!response.ok) return null
          const result = await response.json()
          return { complaintId: row.id, summary: result.counts as VerificationSummary }
        })
      )

      if (active) {
        const nextSummary: Record<string, VerificationSummary> = {}
        summaryResults.forEach((item) => {
          if (!item) return
          nextSummary[item.complaintId] = item.summary
        })
        setVerification(nextSummary)
        setLoading(false)
      }
    }

    load()
    return () => {
      active = false
    }
  }, [])

  const vote = async (complaintId: string, voteType: 'resolved' | 'unresolved') => {
    try {
      const response = await fetch('/api/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ complaintId, voteType }),
      })
      const body = await response.json()
      if (!response.ok) throw new Error(body.error || 'Unable to cast vote.')

      setVerification((current) => ({
        ...current,
        [complaintId]: body.counts,
      }))
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unable to save verification vote.')
    }
  }

  const signOut = async () => {
    await supabase?.auth.signOut()
    window.location.href = '/'
  }

  return (
    <div className="mx-auto max-w-5xl px-6 py-14 lg:px-10">
      <div className="flex flex-col justify-between gap-6 md:flex-row md:items-end">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[.25em] text-gold">Citizen account</p>
          <h1 className="mt-4 text-5xl md:text-6xl">Your civic journey.</h1>
          <p className="mt-4 text-navy/55">Track every report and see how the community validates each resolution.</p>
        </div>
        <button
          onClick={signOut}
          className="flex items-center gap-2 self-start rounded-full border border-gold/40 px-5 py-3 text-xs font-semibold uppercase tracking-widest"
        >
          <LogOut size={15} />
          Sign out
        </button>
      </div>

      <div className="mt-12 flex items-center justify-between">
        <h2 className="text-3xl">Your reports</h2>
        <Link href="/report" className="flex items-center gap-2 text-sm font-semibold text-gold">
          New report <ArrowUpRight size={16} />
        </Link>
      </div>

      {error && <p className="mt-5 rounded-xl bg-red-50 p-4 text-sm text-red-700">{error}</p>}

      {loading ? (
        <div className="mt-6 grid gap-3">
          {[1, 2, 3].map((x) => (
            <div key={x} className="h-24 animate-pulse rounded-2xl bg-navy/5" />
          ))}
        </div>
      ) : rows.length === 0 ? (
        <div className="glass mt-6 rounded-2xl p-10 text-center shadow-luxury">
          <p className="serif text-3xl">No reports yet.</p>
          <p className="mt-3 text-sm text-navy/55">Your first report can help make a visible difference.</p>
          <Link href="/report" className="mt-6 inline-block rounded-full bg-navy px-6 py-3 text-sm text-ivory">
            Report waste
          </Link>
        </div>
      ) : (
        <div className="mt-6 space-y-5">
          {rows.map((row) => {
            const summary = verification[row.id]
            const statusLabel = row.status.replace('_', ' ')

            return (
              <div key={row.id} className="glass rounded-2xl p-5 shadow-luxury">
                <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
                  <div>
                    <p className="text-sm font-semibold">{row.waste_type}</p>
                    <p className="mt-2 flex items-center gap-2 text-xs text-navy/50">
                      <Clock3 size={13} />
                      {new Date(row.created_at).toLocaleDateString()}
                      {row.location_lat && (
                        <>
                          <MapPin size={13} />
                          {Number(row.location_lat).toFixed(3)}, {Number(row.location_lng).toFixed(3)}
                        </>
                      )}
                    </p>
                  </div>

                  <div className="flex items-center gap-4">
                    <span className="rounded-full bg-mist px-3 py-1 text-xs capitalize">{statusLabel}</span>
                    <span className="font-mono text-xs text-gold">#{row.id.slice(0, 8)}</span>
                  </div>
                </div>

                {row.resolution_photo_path && (
                  <div className="mt-5 border-t border-gold/15 pt-5">
                    <div className="mb-3 flex items-center gap-2 text-xs font-semibold uppercase tracking-widest text-green-700">
                      <ImageIcon size={15} />
                      Before & after proof · {row.resolved_at && new Date(row.resolved_at).toLocaleString()}
                    </div>

                    <div className="grid gap-3 sm:grid-cols-2">
                      <div>
                        <p className="mb-2 text-xs text-navy/50">Before</p>
                        {urls[row.id]?.before ? (
                          <img src={urls[row.id].before} alt="Original issue evidence" className="h-48 w-full rounded-xl object-cover" />
                        ) : (
                          <div className="grid h-48 place-items-center rounded-xl bg-navy/5 text-xs text-navy/40">Evidence link expired</div>
                        )}
                      </div>
                      <div>
                        <p className="mb-2 text-xs text-navy/50">After</p>
                        {urls[row.id]?.after ? (
                          <img src={urls[row.id].after} alt="Resolution evidence" className="h-48 w-full rounded-xl object-cover" />
                        ) : (
                          <div className="grid h-48 place-items-center rounded-xl bg-navy/5 text-xs text-navy/40">Evidence link expired</div>
                        )}
                      </div>
                    </div>

                    {row.resolution_notes && <p className="mt-3 text-sm text-navy/55">{row.resolution_notes}</p>}
                  </div>
                )}

                {row.status === 'resolved' && (
                  <div className="mt-5 border-t border-gold/15 pt-5">
                    <div className="flex items-center justify-between gap-4">
                      <p className="text-xs font-semibold uppercase tracking-widest text-navy/55">Community verification</p>
                      <span className="text-xs text-navy/50">{summary?.total ?? 0} verified votes</span>
                    </div>

                    <div className="mt-3 flex flex-wrap gap-3">
                      <button
                        type="button"
                        onClick={() => vote(row.id, 'resolved')}
                        className={`rounded-full border px-4 py-2 text-xs font-semibold ${
                          summary?.myVote === 'resolved' ? 'border-green-500 bg-green-50 text-green-700' : 'border-gold/40 bg-ivory text-navy'
                        }`}
                      >
                        ✅ Resolved ({summary?.resolved ?? 0})
                      </button>

                      <button
                        type="button"
                        onClick={() => vote(row.id, 'unresolved')}
                        className={`rounded-full border px-4 py-2 text-xs font-semibold ${
                          summary?.myVote === 'unresolved' ? 'border-red-500 bg-red-50 text-red-700' : 'border-gold/40 bg-ivory text-navy'
                        }`}
                      >
                        ❌ Still not resolved ({summary?.unresolved ?? 0})
                      </button>
                    </div>

                    {summary && summary.total > 0 && (
                      <p className="mt-3 text-xs text-navy/55">
                        {summary.resolved >= summary.unresolved
                          ? 'The community is leaning toward a resolved outcome.'
                          : 'Several citizens still report this issue as unresolved.'}
                      </p>
                    )}
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}





























































































































































































































































































































"use client"
import { useEffect, useState } from 'react'
import { Check, Clock3, Users, ArrowUpRight, UserRound } from 'lucide-react'
import { supabase } from '@/lib/supabase'

const demo = [{ id:'SF-24810', type:'Garbage', area:'Central market', status:'pending', assigned_worker_id:'' }, { id:'SF-24811', type:'Water leakage', area:'Ward 4', status:'in_progress', assigned_worker_id:'' }, { id:'SF-24812', type:'Pothole', area:'Main road', status:'resolved', assigned_worker_id:'' }]

type Worker = { id:string; name:string; assigned_area:string | null }
type Complaint = { id:string; waste_type:string; status:string; location_lat:number | null; location_lng:number | null; assigned_worker_id:string | null; created_at?:string }
type VerificationSummary = { resolved: number; unresolved: number; total: number; myVote: 'resolved' | 'unresolved' | null }

export default function Admin() {
  const [rows, setRows] = useState<Complaint[]>(demo as Complaint[])
  const [workers, setWorkers] = useState<Worker[]>([])
  const [verification, setVerification] = useState<Record<string, VerificationSummary>>({})
  const [message, setMessage] = useState('')

  useEffect(() => {
    const load = async () => {
      if (!supabase) return

      const [{ data: complaints }, { data: team }] = await Promise.all([
        supabase.from('complaints').select('*').order('created_at', { ascending: false }),
        supabase.from('workers').select('id,name,assigned_area').order('name'),
      ])

      if (complaints?.length) setRows(complaints)
      if (team) setWorkers(team)
    }

    load()
  }, [])

  useEffect(() => {
    const loadSummaries = async () => {
      const summaries = await Promise.all(
        rows.map(async (row) => {
          const response = await fetch(`/api/verify?complaintId=${row.id}`)
          if (!response.ok) return null
          const result = await response.json()
          return { complaintId: row.id, summary: result.counts as VerificationSummary }
        })
      )

      const next: Record<string, VerificationSummary> = {}
      summaries.forEach((item) => {
        if (!item) return
        next[item.complaintId] = item.summary
      })

      setVerification(next)
    }

    if (rows.length) loadSummaries()
  }, [rows])

  const updateStatus = async (id: string, status: string) => {
    setRows((r) => r.map((x) => (x.id === id ? { ...x, status } : x)))
    const result = await supabase?.from('complaints').update({ status }).eq('id', id)
    if (result?.error) setMessage(result.error.message)
  }

  const assign = async (id: string, workerId: string) => {
    setRows((r) => r.map((x) => (x.id === id ? { ...x, assigned_worker_id: workerId || null } : x)))
    const result = await supabase?.from('complaints').update({ assigned_worker_id: workerId || null, status: workerId ? 'in_progress' : 'pending' }).eq('id', id)
    if (result?.error) setMessage(result.error.message)
    else setMessage(workerId ? 'Complaint assigned and moved to In Progress.' : 'Worker assignment removed.')
  }

  return (
    <div className="mx-auto max-w-7xl px-6 py-12 lg:px-10">
      <div className="flex items-end justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[.25em] text-gold">Operations desk</p>
          <h1 className="mt-3 text-5xl">Authority panel</h1>
        </div>
        <span className="hidden items-center gap-2 text-xs text-navy/50 md:flex">
          <span className="h-2 w-2 rounded-full bg-green-700" />
          System operational
        </span>
      </div>

      <div className="mt-10 grid gap-4 md:grid-cols-3">
        <Metric icon={Clock3} n={String(rows.filter((r) => r.status === 'pending').length)} l="Pending reports" />
        <Metric icon={Users} n={String(workers.length || 14)} l="Active workers" />
        <Metric icon={Check} n={`${rows.length ? Math.round((rows.filter((r) => r.status === 'resolved').length / rows.length) * 100) : 0}%`} l="Resolution rate" />
      </div>

      {message && <p className="mt-5 rounded-xl bg-gold/10 p-4 text-sm text-navy">{message}</p>}

      <div className="mt-10 overflow-hidden rounded-2xl border border-gold/20 bg-white/50 shadow-luxury">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[1000px] text-left text-sm">
            <thead className="border-b border-gold/20 bg-navy text-xs uppercase tracking-widest text-ivory/70">
              <tr>
                <th className="p-5">Reference</th>
                <th>Issue</th>
                <th>Location</th>
                <th>Status</th>
                <th>Community verification</th>
                <th>Assign worker</th>
                <th className="p-5">Update</th>
              </tr>
            </thead>

            <tbody>
              {rows.map((r) => {
                const summary = verification[r.id]
                return (
                  <tr key={r.id} className="border-b border-gold/10 last:border-0">
                    <td className="p-5 font-mono text-xs text-gold">#{String(r.id).slice(0, 10)}</td>
                    <td className="font-semibold">{r.waste_type}</td>
                    <td className="text-navy/55">
                      {r.location_lat ? `${Number(r.location_lat).toFixed(3)}, ${Number(r.location_lng).toFixed(3)}` : 'Reported location'}
                    </td>
                    <td>
                      <span className="rounded-full bg-mist px-3 py-1 text-xs capitalize">{r.status.replace('_', ' ')}</span>
                    </td>
                    <td>
                      {summary ? (
                        <div className="space-y-1 text-xs text-navy/60">
                          <div>✅ {summary.resolved} resolved</div>
                          <div>❌ {summary.unresolved} still not resolved</div>
                        </div>
                      ) : (
                        <span className="text-xs text-navy/40">Waiting for votes…</span>
                      )}
                    </td>
                    <td>
                      <div className="flex items-center gap-2">
                        <UserRound size={15} className="text-gold" />
                        <select
                          value={r.assigned_worker_id || ''}
                          onChange={(e) => assign(r.id, e.target.value)}
                          className="rounded-lg border border-gold/30 bg-ivory px-3 py-2 text-xs"
                        >
                          <option value="">Unassigned</option>
                          {workers.map((w) => (
                            <option key={w.id} value={w.id}>
                              {w.name}
                              {w.assigned_area ? ` · ${w.assigned_area}` : ''}
                            </option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-5">
                      <select
                        value={r.status}
                        onChange={(e) => updateStatus(r.id, e.target.value)}
                        className="rounded-lg border border-gold/30 bg-ivory px-3 py-2 text-xs"
                      >
                        <option value="pending">Pending</option>
                        <option value="in_progress">In progress</option>
                        <option value="resolved">Resolved</option>
                      </select>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      <p className="mt-5 flex items-center gap-2 text-xs text-navy/45">
        <ArrowUpRight size={14} />
        Community verification is included in every resolved complaint workflow.
      </p>
    </div>
  )
}

function Metric({ icon: Icon, n, l }: { icon: any; n: string; l: string }) {
  return (
    <div className="glass rounded-2xl p-6 shadow-luxury">
      <Icon size={19} className="text-gold" />
      <p className="serif mt-5 text-4xl">{n}</p>
      <p className="mt-1 text-xs uppercase tracking-widest text-navy/50">{l}</p>
    </div>
  )
}






























































































































































































































































































































































































































































































































































































































































































n
