# SafaiSetu

Premium civic issue reporting for villages, built with Next.js 14, Tailwind, Framer Motion, Leaflet and Supabase.

Protected workflow:

- `/report` — authenticated citizens create reports
- `/account` — citizens see their personal report history
- `/admin` — admins review, assign workers, and update statuses
- `/worker` — workers see assigned jobs and update progress

For worker assignment, create a `workers` row with `user_id` equal to the worker's Supabase Auth user ID and set that user's `users.role` to `worker`. Admins can then assign complaints from the Authority panel.

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Enable Phone authentication in Supabase, apply `supabase/schema.sql`, create the `complaint-photos` Storage bucket, and configure its authenticated upload policies.
