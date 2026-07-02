# CLAUDE.md — Brandero project

> Template origin: `alindashboard/site-template`. If the **Project Specifics** section
> at the bottom is empty, this repo has NOT been initialized — run the
> "Project initialization" steps below before doing anything else.

## Critical: this is NOT the Next.js you know

Next.js 16 has breaking changes — APIs, conventions, and file structure may differ
from your training data. Read the relevant guide in `node_modules/next/dist/docs/`
before writing any code. Heed deprecation notices. Notably: `proxy.ts`, **not**
`middleware.ts`.

## Stack (fixed — do not deviate, do not add dependencies without approval)

- Next.js 16 App Router · React 19 · TypeScript
- Tailwind **v4** — design tokens live in `globals.css` under `@theme inline`.
  There is no `tailwind.config.js` in the v3 sense. Never write v3-style config.
- shadcn/ui `base-nova` · lucide-react icons
- Supabase (auth, DB, storage) — some projects remove it entirely; check Project Specifics
- Resend for all transactional email
- Vercel: hosting, push-to-deploy on `main`, DNS via ns1/ns2.vercel-dns.com

## Working rules

1. **Investigate before assuming.** Read the actual files, DB schema, and config
   before editing. Never trust that this repo matches the template exactly.
2. **Stop and report discrepancies.** If reality doesn't match the task description,
   stop and report — do not proceed on assumptions.
3. **`npm run build` must pass locally before any push/deploy.** No exceptions.
4. Code comments in **English**. UI text in **Romanian** unless Project Specifics
   says otherwise (e.g., IT/EN projects).
5. Unconfirmed business data (addresses, prices, hours, phone numbers) → use
   `TODO_CONFIRM` placeholders and list them in your final report. Never invent.
6. Canonical URLs and sitemap always use the custom domain — never `*.vercel.app`.
7. Every page is self-canonical with complete metadata; never rely on inherited
   defaults for canonical/OG. No redirect chains.
8. Never add `aggregateRating` JSON-LD without verified review data (manual action risk).
9. Never ship the default template color palette — see Design section.

## Known gotchas (learned the hard way)

- Vercel handles www→non-www at the edge **before** `proxy.ts` runs; redirect code
  in proxy is a non-executing safety net.
- `NEXT_PUBLIC_SITE_URL` must be set in Vercel env vars — missing it silently breaks
  OG URLs (they fall back to Supabase URLs).
- Slugs: keep digits (model years, etc.) — they improve uniqueness and SEO. When
  migrating URLs, use 308 permanent redirects from old paths.
- Admin, cart, and checkout routes must be `noindex`.
- GSC Domain property covers all subdomains; no separate www property needed.

## Design

Design tokens (colors, radii, fonts) are defined in `globals.css` `@theme inline`.
The template ships with a neutral default palette that must be **replaced at
initialization** according to the project's design brief / Brandero design language.
Two Brandero sites must never look like reskins of each other.

## Project initialization (MANDATORY on every new clone)

1. Fill in **Project Specifics** below; delete template sections that don't apply.
2. **Rewrite `README.md` for this project** — client name, domain, what the site
   does, project-specific setup. The template README must not survive initialization.
3. Configure `lib/config.ts` with real client data (or TODO_CONFIRM placeholders).
4. Replace design tokens per the design brief.
5. Remove unused features/modules for this project type.
6. Report back: preview URL, admin URL, list of TODO_CONFIRM items.

## Maintenance rule for this file

When a task teaches something durable (a gotcha, a convention, a client constraint),
add it here in the same commit — one or two lines, no essays. This file is the
project's memory.

---

## Project Specifics

<!-- FILL ON INITIALIZATION — if this is empty, the repo is uninitialized.

- **Client:**
- **Domain:**
- **Project type:** magazin | prezentare | rezervări
- **Languages:** (e.g., RO only / IT default + EN)
- **Supabase:** yes / removed
- **Features enabled/disabled:**
- **Divergences from template:**
- **External services & env vars specific to this project:**
- **Things the client must confirm:**
-->
