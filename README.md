# SafaiSetu

Premium civic issue reporting for villages, built with Next.js 14, Tailwind, Framer Motion, Leaflet and Supabase.

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` to enable persistence and phone OTP authentication. In Supabase, enable **Phone** under Authentication → Providers and configure an SMS provider. Apply `supabase/schema.sql` and create a public Storage bucket named `complaint-photos`.

The interface includes a premium landing experience, phone OTP citizen login, geolocated report flow with photo upload, live Leaflet dashboard, and operational authority panel. Without Supabase credentials it runs with polished demo data for preview.
