# SafaiSetu — private evidence

Complaint evidence uses a private Supabase Storage bucket and short-lived signed URLs.

- Database stores `photo_path` and `resolution_photo_path`, never public URLs.
- Files are namespaced under `complaints/<complaint-id>/...`.
- `/api/evidence` checks the authenticated Supabase session and complaint RLS before generating 10-minute signed URLs.
- Citizens can access their own evidence; assigned workers and admins can access relevant evidence; anonymous visitors cannot.
- Storage RLS correctly reads the complaint UUID from path segment 2.

## Apply the database migration

Run `supabase/schema.sql` in the Supabase SQL editor. It is safe for existing databases: it adds missing evidence columns, forces the `complaint-photos` bucket to private, replaces the evidence policies, and adds useful complaint indexes.

Do not expose the service-role key in the browser. The signed URL route uses the authenticated Supabase session and database/storage RLS.
