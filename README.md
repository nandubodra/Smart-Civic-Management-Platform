# SafaiSetu — private evidence

Complaint evidence now uses a private Supabase Storage bucket and short-lived signed URLs.

- Database stores `photo_path` and `resolution_photo_path`, never public URLs.
- Files are namespaced under `complaints/<complaint-id>/...`.
- `/api/evidence` checks the authenticated Supabase session and complaint RLS before generating 10-minute signed URLs.
- Citizens can access their own evidence; assigned workers and admins can access relevant evidence; anonymous visitors cannot.
- Original and resolution uploads use Storage RLS policies tied to the complaint ID.

Create a **private** Storage bucket named `complaint-photos`, apply `supabase/schema.sql`, and configure the environment variables before testing. Existing rows that contain old `photo_url` values will need a one-time migration to private paths or will no longer render in the new UI.
