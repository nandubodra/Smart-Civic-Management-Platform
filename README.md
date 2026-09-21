# SafaiSetu

Premium civic issue reporting for villages, built with Next.js 14, Tailwind, Framer Motion, Leaflet and Supabase.

## Workflow

- `/report` — authenticated citizens create reports with photo evidence, GPS, description, and optional AI category suggestion
- `/account` — citizens see their personal report history
- `/admin` — admins review, assign workers, and update statuses
- `/worker` — workers see assigned jobs and update progress

## AI categorization

The report form includes an AI-assisted suggestion step. Citizens always review the suggested category before submission. If `OPENAI_API_KEY` is configured on the server, `/api/classify` uses a vision model; without it, a safe local keyword fallback keeps the demo usable.

```env
OPENAI_API_KEY=your_server_only_key
OPENAI_VISION_MODEL=gpt-4o-mini
```

Never prefix the OpenAI key with `NEXT_PUBLIC_`.

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Enable Phone authentication in Supabase, apply `supabase/schema.sql`, create the `complaint-photos` Storage bucket, and configure its authenticated upload policies.
