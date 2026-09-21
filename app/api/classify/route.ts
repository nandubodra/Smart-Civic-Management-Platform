import { NextResponse } from 'next/server'

const categories = ['Garbage', 'Overflowing drain', 'Water leakage', 'Pothole', 'Broken street light', 'Damaged public property']

export async function POST(request: Request) {
  const form = await request.formData()
  const file = form.get('image')
  const hint = String(form.get('hint') || '')
  if (!(file instanceof File)) return NextResponse.json({ error: 'An image is required.' }, { status: 400 })

  const apiKey = process.env.OPENAI_API_KEY
  if (apiKey) {
    const bytes = Buffer.from(await file.arrayBuffer()).toString('base64')
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: process.env.OPENAI_VISION_MODEL || 'gpt-4o-mini',
        temperature: 0.1,
        response_format: { type: 'json_object' },
        messages: [{ role: 'system', content: `You classify civic issues. Return JSON only with category, description, confidence (0 to 1), and reason. category must be exactly one of: ${categories.join(', ')}. Do not identify people or infer sensitive personal information.` }, { role: 'user', content: [{ type: 'text', text: `Classify this civic issue. Citizen hint: ${hint || 'none'}` }, { type: 'image_url', image_url: { url: `data:${file.type};base64,${bytes}`, detail: 'low' } }] }],
      }),
    })
    if (response.ok) {
      const data = await response.json()
      try { return NextResponse.json(JSON.parse(data.choices?.[0]?.message?.content || '{}')) } catch { /* use safe fallback */ }
    }
  }

  const text = `${file.name} ${hint}`.toLowerCase()
  const rules: [string, string][] = [['pothole', 'Pothole'], ['leak', 'Water leakage'], ['water', 'Water leakage'], ['drain', 'Overflowing drain'], ['light', 'Broken street light'], ['property', 'Damaged public property'], ['garbage', 'Garbage'], ['waste', 'Garbage']]
  const match = rules.find(([word]) => text.includes(word))
  return NextResponse.json({ category: match?.[1] || 'Garbage', description: hint || 'Civic issue detected from the uploaded evidence.', confidence: match ? 0.78 : 0.35, reason: match ? 'Matched the citizen hint to a supported civic issue.' : 'Please review this suggestion before submitting.' })
}
