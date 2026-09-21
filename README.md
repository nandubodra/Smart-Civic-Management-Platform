# SafaiSetu

The resolution evidence workflow is now included:

- Workers can upload an after photo from `/worker`.
- Uploading evidence records `resolved_at`, optional resolution notes, and moves the complaint to `resolved`.
- Citizens see a Before → After comparison and resolution timestamp in `/account`.
- Original evidence remains linked through `photo_url`.

Apply the updated `supabase/schema.sql` and make sure the `complaint-photos` Storage bucket exists. The current UI uses public URLs for evidence previews; for a private bucket, replace `getPublicUrl` with signed URLs and tighten Storage RLS policies before production deployment.
