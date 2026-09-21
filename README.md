# SafaiSetu

> **From Waste to Worth — Empowering Villages**

SafaiSetu is a premium civic issue reporting and village waste-management platform. It connects citizens, field workers, and authorities through one transparent workflow:

```text
Citizen Report → AI Assistance → Location → Authority Review → Worker Assignment
→ Resolution Evidence → Community Verification → Analytics
```

The platform is designed around a simple goal: make civic problems easy to report, visible to the right people, accountable through evidence, and measurable over time.

---

## Table of Contents

- [What SafaiSetu Does](#what-safaisetu-does)
- [Core Features](#core-features)
- [User Roles](#user-roles)
- [Application Routes](#application-routes)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Supabase Setup](#supabase-setup)
- [Private Evidence Security](#private-evidence-security)
- [Authentication and Access Control](#authentication-and-access-control)
- [Database Model](#database-model)
- [End-to-End Workflows](#end-to-end-workflows)
- [AI Categorization](#ai-categorization)
- [Notifications](#notifications)
- [Testing Checklist](#testing-checklist)
- [Production Checklist](#production-checklist)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## What SafaiSetu Does

SafaiSetu helps communities report and resolve civic issues such as:

- Garbage accumulation
- Overflowing drains
- Water leakage
- Potholes
- Broken street lights
- Damaged public property

Citizens can submit a photo, location, category, and description. Authorities can review reports, assign field workers, and update progress. Workers can upload private resolution evidence. Citizens can then compare before and after proof and vote on whether the issue was genuinely resolved.

---

## Core Features

### 1. Premium citizen experience

- Minimal navy, ivory, and gold design system
- Playfair Display headings with Inter body text
- Responsive layouts for mobile, tablet, and desktop
- Glassmorphism cards, soft shadows, spacious composition
- Clear empty states, loading states, and error feedback

### 2. Phone OTP authentication

- Passwordless Supabase Phone OTP login
- Session-aware navigation
- Protected application routes
- Role-based access for citizens, workers, and admins

### 3. Civic issue reporting

- Photo evidence upload
- GPS location detection through the browser Geolocation API
- Manual coordinate entry
- Waste/civic issue category selection
- Optional description
- Unique complaint ID
- Supabase-backed complaint persistence

### 4. AI-assisted categorization

- Optional image classification through a server-side API route
- Suggested category, description, confidence, and reasoning
- Citizen reviews the AI suggestion before submission
- Safe local keyword fallback when an AI key is not configured
- AI never silently submits a category on behalf of the citizen

### 5. Live civic map

- Leaflet-based issue map
- Status filters for pending, in progress, and resolved issues
- Status-colored markers
- Issue register with location and status details

### 6. Authority operations

- Complaint register
- Status management
- Worker assignment
- Pending and resolution metrics
- Community verification summary

### 7. Worker workspace

- Assigned work queue
- Status updates
- Location and report date
- Private after-photo upload
- Resolution notes
- Automatic resolution timestamp

### 8. Before/after resolution evidence

- Original report photo is retained
- Worker uploads an after photo
- Resolution timestamp and notes are stored
- Citizens see a Before → After comparison
- Evidence is served through temporary signed URLs

### 9. Community verification

- Citizens can vote `resolved` or `unresolved`
- One vote per user per complaint
- Existing votes can be changed
- Admin view shows verification counts
- Conflicting community feedback is visible for manual review

### 10. Notifications

- Dedicated notification center
- Unread count
- Mark-as-read interaction
- Supabase-backed notification records

---

## User Roles

| Role | Capabilities |
|---|---|
| **Citizen** | Sign in with OTP, report issues, view own reports, view own evidence, vote on resolved complaints |
| **Worker** | View assigned complaints, update progress, upload resolution evidence |
| **Admin** | Review complaints, assign workers, update statuses, view verification summaries |
| **Anonymous visitor** | View public landing page and demo/public map data; cannot access private evidence or protected dashboards |

Role values are stored in `users.role`:

```text
citizen | worker | admin
```

---

## Application Routes

| Route | Access | Purpose |
|---|---|---|
| `/` | Public | Premium SafaiSetu landing page |
| `/login` | Public | Phone OTP authentication |
| `/report` | Authenticated citizen | Create a civic complaint |
| `/dashboard` | Public/authenticated | Live civic issue map |
| `/account` | Authenticated citizen | Personal complaint history and verification |
| `/worker` | Worker or admin | Field work queue and resolution evidence |
| `/admin` | Admin only | Authority operations and assignments |
| `/notifications` | Authenticated user | Personal notification center |
| `/forbidden` | Protected fallback | Unauthorized access message |

API routes include:

| API route | Purpose |
|---|---|
| `POST /api/classify` | AI-assisted image/category suggestion |
| `GET /api/evidence?complaintId=...` | Generate authorized temporary evidence URLs |
| `GET /api/verify?complaintId=...` | Read community vote summary |
| `POST /api/verify` | Create or update a verification vote |

---

## Technology Stack

### Frontend

- Next.js 14
- React 18
- TypeScript
- App Router
- Tailwind CSS
- Framer Motion
- Lucide React
- Leaflet

### Backend and data

- Supabase Auth
- Supabase PostgreSQL
- Supabase Storage
- PostgreSQL Row Level Security
- Next.js Route Handlers

### Optional AI

- OpenAI-compatible vision API through a server-only API key

---

## Project Structure

```text
.
├── app/
│   ├── account/              # Citizen account and report history
│   ├── admin/                # Admin authority dashboard
│   ├── api/
│   │   ├── classify/         # AI categorization endpoint
│   │   ├── evidence/         # Signed private evidence URLs
│   │   └── verify/           # Community verification API
│   ├── dashboard/            # Leaflet civic map
│   ├── forbidden/            # Access denied page
│   ├── login/                # Phone OTP login
│   ├── notifications/        # Notification center
│   ├── report/               # Citizen reporting flow
│   ├── worker/               # Worker operations workspace
│   ├── globals.css           # Global design tokens and styles
│   ├── layout.tsx            # Root layout and metadata
│   └── page.tsx              # Landing page
├── components/
│   ├── MapView.tsx           # Client-side Leaflet map
│   └── Shell.tsx             # Navigation and application shell
├── lib/
│   └── supabase.ts           # Browser Supabase client
├── supabase/
│   └── schema.sql            # Database, RLS, Storage policies, indexes
├── middleware.ts             # Session refresh and route protection
├── .env.example              # Environment variable template
├── next.config.js
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

---

## Getting Started

### Prerequisites

Install the following first:

- Node.js 18.17+ or Node.js 20+
- npm, pnpm, or yarn
- A Supabase project
- Optional: an OpenAI-compatible API key for AI image classification

### Install dependencies

```bash
npm install
```

### Create local environment file

```bash
cp .env.example .env.local
```

### Start the development server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Production build

```bash
npm run build
npm start
```

### Lint

```bash
npm run lint
```

---

## Environment Variables

Use `.env.local` for local development. Never commit real secrets.

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key

# Optional server-only AI configuration
OPENAI_API_KEY=your-server-only-api-key
OPENAI_VISION_MODEL=gpt-4o-mini
```

### Security rules for environment variables

- `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are browser-safe Supabase values.
- Never expose `OPENAI_API_KEY` with a `NEXT_PUBLIC_` prefix.
- Never put a Supabase service-role key in client components, browser code, or public environment variables.
- Use platform secret storage in production.

---

## Supabase Setup

### 1. Create a Supabase project

Create a project at [supabase.com](https://supabase.com), then copy the project URL and anon key into `.env.local`.

### 2. Enable Phone Authentication

In Supabase:

1. Open **Authentication → Providers**.
2. Enable **Phone**.
3. Configure an SMS provider supported by your Supabase plan.
4. Add the correct redirect/site URLs under **Authentication → URL Configuration**.

### 3. Apply the database schema

Open **SQL Editor** in Supabase and run:

```text
supabase/schema.sql
```

The schema creates or configures:

- `users`
- `workers`
- `complaints`
- complaint evidence columns
- Row Level Security policies
- private Storage bucket configuration
- evidence access policies
- complaint indexes

### 4. Create user profiles

After a user authenticates, create a matching row in `public.users` using the same UUID as `auth.users.id`.

Example admin profile:

```sql
insert into public.users (id, name, phone, role, village_name)
values ('AUTH_USER_UUID', 'Village Administrator', '+91XXXXXXXXXX', 'admin', 'Demo Village');
```

Example worker profile and worker record:

```sql
insert into public.users (id, name, phone, role, village_name)
values ('WORKER_AUTH_UUID', 'Field Worker', '+91XXXXXXXXXX', 'worker', 'Demo Village');

insert into public.workers (user_id, name, assigned_area)
values ('WORKER_AUTH_UUID', 'Field Worker', 'Ward 4');
```

Replace placeholder UUIDs with real Auth user IDs.

### 5. Configure private Storage

The application expects a private bucket named:

```text
complaint-photos
```

The schema configures the bucket as private and applies policies for:

- Citizen original evidence uploads
- Assigned worker resolution uploads
- Authorized evidence reads

Storage paths use this format:

```text
complaints/<complaint-uuid>/original-<timestamp>-<filename>
complaints/<complaint-uuid>/resolution-<timestamp>-<filename>
```

---

## Private Evidence Security

Evidence is intentionally not exposed through public URLs.

```text
User uploads image
       ↓
Private Storage bucket
       ↓
Database stores only the file path
       ↓
Authenticated user requests evidence
       ↓
Complaint RLS checks access
       ↓
Temporary signed URL is generated
       ↓
Image is displayed for a limited time
```

Access policy:

| User | Evidence access |
|---|---|
| Citizen | Their own complaints |
| Worker | Complaints assigned to them |
| Admin | Authority-visible complaints |
| Anonymous visitor | No private evidence access |

Signed URLs currently expire after 10 minutes. Do not convert the bucket to public in production.

---

## Authentication and Access Control

`middleware.ts` refreshes the Supabase session and protects application routes.

- Unauthenticated visitors are redirected to `/login`.
- Admin routes require `users.role = 'admin'`.
- Worker routes require `users.role = 'worker'` or `admin`.
- Citizen data access is additionally enforced by PostgreSQL RLS.
- Storage evidence access is enforced by Storage RLS and the signed URL API.

UI checks are not a security boundary. Keep the database and Storage policies enabled in every environment.

---

## Database Model

### `users`

Stores the application profile linked to `auth.users`.

Important fields:

- `id`
- `name`
- `phone`
- `role`
- `village_name`

### `workers`

Stores field-worker details.

Important fields:

- `id`
- `user_id`
- `name`
- `assigned_area`
- `total_tasks_completed`

### `complaints`

Stores civic reports and workflow state.

Important fields:

- `id`
- `user_id`
- `assigned_worker_id`
- `waste_type`
- `description`
- `ai_confidence`
- `location_lat`
- `location_lng`
- `photo_path`
- `resolution_photo_path`
- `resolution_notes`
- `status`
- `resolved_at`
- `created_at`

### Additional tables used by the UI

The application also expects these tables for their respective features:

- `complaint_votes` — community verification votes
- `notifications` — citizen notification records

If these tables are not present, the related screens will return database errors until their SQL migrations are applied.

---

## End-to-End Workflows

### Citizen report

1. Citizen signs in with phone OTP.
2. Citizen opens `/report`.
3. Citizen uploads an issue photo.
4. Browser captures GPS coordinates or citizen enters them manually.
5. AI optionally suggests a category and description.
6. Citizen reviews the suggestion.
7. Complaint is created in Supabase.
8. Original photo is uploaded to private Storage.
9. Database stores the private file path.

### Authority and worker workflow

1. Admin opens `/admin`.
2. Admin reviews pending reports.
3. Admin assigns a worker.
4. Complaint moves to `in_progress`.
5. Worker opens `/worker`.
6. Worker updates progress.
7. Worker uploads an after photo and adds optional notes.
8. Complaint is marked `resolved` with a timestamp.

### Community verification

1. Citizen sees a resolved complaint and evidence.
2. Citizen selects `Resolved` or `Still not resolved`.
3. Vote is inserted or updated for that user and complaint.
4. Admin sees the community totals.
5. A strong unresolved signal can be reviewed manually by the authority team.

### Notification workflow

Application events can create records in `notifications`, such as:

- Report submitted
- Complaint assigned
- Work started
- Complaint resolved
- Resolution evidence uploaded
- Verification requested

---

## AI Categorization

AI categorization is optional and must remain assistive—not authoritative.

The `/api/classify` route:

- Accepts an image and optional citizen hint.
- Uses a server-side vision model when `OPENAI_API_KEY` is configured.
- Returns category, description, confidence, and reason.
- Falls back to keyword classification when no AI key exists.
- Does not identify people or infer sensitive personal information.
- Requires the citizen to review the suggestion before submission.

For privacy and cost control, add file-size/type validation, request limits, and image retention rules before production deployment.

---

## Testing Checklist

### Authentication

- [ ] Phone OTP sends successfully.
- [ ] Invalid OTP is rejected.
- [ ] Unauthenticated users cannot open `/report` or `/account`.
- [ ] Citizens cannot open `/admin` or `/worker`.
- [ ] Workers cannot open `/admin`.
- [ ] Admins can open authority routes.

### Reporting

- [ ] Citizen can submit a valid photo and location.
- [ ] Invalid or missing input shows an error.
- [ ] Complaint ID is generated.
- [ ] Original file path is stored, not a public URL.
- [ ] Complaint appears in the citizen account.

### Evidence

- [ ] Storage bucket is private.
- [ ] Citizen can view their own signed evidence URLs.
- [ ] Assigned worker can upload resolution evidence.
- [ ] Unassigned workers cannot read another worker’s evidence.
- [ ] Anonymous users cannot read evidence.
- [ ] Signed URLs expire.

### Verification

- [ ] Only authenticated users can vote.
- [ ] A user has one vote per complaint.
- [ ] A user can change their vote.
- [ ] Admin sees vote counts.

### Notifications

- [ ] User sees only their own notifications.
- [ ] Unread count is accurate.
- [ ] Mark-as-read persists after reload.

### Production build

- [ ] `npm run lint` passes.
- [ ] `npm run build` passes.
- [ ] Environment variables exist in the deployment platform.
- [ ] Supabase RLS is enabled and tested with non-admin accounts.

---

## Production Checklist

Before deploying to real users:

- [ ] Apply and verify all Supabase migrations.
- [ ] Keep `complaint-photos` private.
- [ ] Add strict Storage file-type and file-size limits.
- [ ] Validate latitude/longitude ranges.
- [ ] Sanitize file names and reject executable uploads.
- [ ] Add rate limiting to OTP, AI, upload, and vote endpoints.
- [ ] Add CAPTCHA or abuse controls for public-facing flows.
- [ ] Add server-side validation for every API route.
- [ ] Add audit logs for status, assignment, and evidence changes.
- [ ] Add notification creation triggers or a trusted server workflow.
- [ ] Configure backups and database monitoring.
- [ ] Configure error tracking and structured logs.
- [ ] Review privacy, retention, and deletion policies.
- [ ] Avoid exposing exact reporter identity or sensitive coordinates publicly.
- [ ] Test with citizen, worker, admin, and anonymous sessions.
- [ ] Run a complete production build and smoke test.

---

## Known Limitations

This repository provides the SafaiSetu MVP foundation. The following items require final deployment-specific work:

- Supabase Phone OTP and SMS provider configuration
- Applying the SQL schema and related table migrations
- Creating and seeding user profiles and workers
- Creating `complaint_votes` and `notifications` tables
- Automated notification generation for every workflow event
- Nearby-citizen validation for voting
- Duplicate complaint detection
- Heatmaps and advanced analytics
- Server-side image moderation and upload limits
- Full automated test coverage
- Deployment-specific build and runtime validation

---

## Contributing

1. Fork the repository.
2. Create a feature branch:

```bash
git checkout -b feat/your-feature
```

3. Install dependencies and run the app locally.
4. Keep secrets out of Git.
5. Apply database changes through reviewed SQL migrations.
6. Run lint and production build before opening a pull request.
7. Describe security and RLS changes clearly in the pull request.

---

## License

No license has been specified yet. Add a license file before distributing or accepting external contributions.

---

## Project Vision

SafaiSetu is more than a complaint form. It is a transparent civic operating system for villages—where every report has a location, every assignment has an owner, every resolution has evidence, and every citizen can participate in building a cleaner community.
