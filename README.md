# SafaiSetu

Premium civic issue reporting for villages, built with Next.js 14, Tailwind, Framer Motion, Leaflet and Supabase.

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` to enable persistence and phone OTP authentication. In Supabase, enable **Phone** under Authentication → Providers and configure an SMS provider. Apply `supabase/schema.sql`, create a public Storage bucket named `complaint-photos`, and apply Storage policies before using photo uploads.

Protected application routes:

- `/report` — authenticated citizens only
- `/account` — authenticated citizens only, with personal report history
- `/admin` — users with `admin` role only
- `/worker` — users with `worker` or `admin` role only

The middleware refreshes Supabase sessions and enforces role-based access. Without Supabase credentials the public landing and demo map remain available, while protected routes redirect to login.
