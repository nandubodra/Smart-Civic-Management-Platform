import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

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

  const { data: votes, error } = await supabase
    .from('complaint_votes')
    .select('vote_type, user_id')
    .eq('complaint_id', complaintId)

  if (error) {
    return NextResponse.json({ error: 'Unable to read verification votes.' }, { status: 500 })
  }

  const resolved = votes?.filter((vote) => vote.vote_type === 'resolved').length ?? 0
  const unresolved = votes?.filter((vote) => vote.vote_type === 'unresolved').length ?? 0
  const myVote = votes?.find((vote) => vote.user_id === user.id)?.vote_type ?? null

  return NextResponse.json({
    counts: {
      resolved,
      unresolved,
      total: votes?.length ?? 0,
      myVote,
    },
  })
}

export async function POST(request: NextRequest) {
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

  const body = await request.json()
  const complaintId = body.complaintId
  const voteType = body.voteType

  if (!complaintId || !['resolved', 'unresolved'].includes(voteType)) {
    return NextResponse.json({ error: 'Valid complaint ID and vote type are required.' }, { status: 400 })
  }

  const { data: complaint, error: complaintError } = await supabase
    .from('complaints')
    .select('id')
    .eq('id', complaintId)
    .maybeSingle()

  if (complaintError || !complaint) {
    return NextResponse.json({ error: 'Complaint not found.' }, { status: 404 })
  }

  const { data: existingVote, error: lookupError } = await supabase
    .from('complaint_votes')
    .select('id, vote_type')
    .eq('complaint_id', complaintId)
    .eq('user_id', user.id)
    .maybeSingle()

  if (lookupError) {
    return NextResponse.json({ error: 'Unable to verify your previous vote.' }, { status: 500 })
  }

  if (existingVote) {
    const { error: updateError } = await supabase
      .from('complaint_votes')
      .update({ vote_type: voteType, created_at: new Date().toISOString() })
      .eq('id', existingVote.id)

    if (updateError) {
      return NextResponse.json({ error: 'Unable to update your vote.' }, { status: 500 })
    }
  } else {
    const { error: insertError } = await supabase.from('complaint_votes').insert({
      complaint_id: complaintId,
      user_id: user.id,
      vote_type: voteType,
    })

    if (insertError) {
      return NextResponse.json({ error: 'Unable to save your vote.' }, { status: 500 })
    }
  }

  const { data: votes, error: fetchError } = await supabase
    .from('complaint_votes')
    .select('vote_type')
    .eq('complaint_id', complaintId)

  if (fetchError) {
    return NextResponse.json({ error: 'Unable to refresh the voting summary.' }, { status: 500 })
  }

  const resolved = votes?.filter((vote) => vote.vote_type === 'resolved').length ?? 0
  const unresolved = votes?.filter((vote) => vote.vote_type === 'unresolved').length ?? 0

  return NextResponse.json({
    counts: {
      resolved,
      unresolved,
      total: votes?.length ?? 0,
      myVote: voteType,
    },
  })
}
