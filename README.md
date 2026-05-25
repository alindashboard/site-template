# Site Template — Next.js 16 + Supabase + Resend

Template generic pentru site-uri cu sistem de rezervări, galerie de produse/servicii și panou de administrare.

**Stack:** Next.js 16 (App Router) · React 19 · Tailwind CSS 4 · shadcn/ui · Supabase · Resend · Vercel

---

## Pornire rapidă

### Setup automat (recomandat)

Un singur script face tot: creează proiectul Supabase, aplică schema, preia cheile API, configurează `.env.local` și face deploy pe Vercel.

**Prima dată (o singură dată pe mașină):**
```bash
npm install -g supabase vercel
supabase login   # deschide browserul pentru autentificare
vercel login
```

**Pentru fiecare proiect nou:**
```bash
git clone https://github.com/alindashboard/site-template.git nume-proiect
cd nume-proiect
npm install
vercel link      # leagă directorul de proiectul Vercel
./scripts/setup.sh nume-proiect
```

> **Windows:** rulează în **Git Bash**, nu în PowerShell.

Scriptul afișează la final parola DB — salveaz-o în 1Password.

---

### Setup manual (alternativă)

<details>
<summary>Extinde dacă preferi pași manuali</summary>

#### 1. Clonează și instalează

```bash
git clone https://github.com/alindashboard/site-template.git my-project
cd my-project
npm install
```

#### 2. Creează proiect Supabase

1. [supabase.com](https://supabase.com) → **New project**
2. **SQL Editor** → copiază și rulează `supabase/schema.sql`
3. **Storage** → **New bucket** → `items` (Public)
4. **Authentication** → **Users** → **Add user** (adminul tău)

#### 3. Configurează variabilele de mediu

```bash
cp .env.local.example .env.local
# Completează cu valorile din Supabase → Settings → API
```

#### 4. Setează env vars în Vercel

```bash
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add SUPABASE_SERVICE_ROLE_KEY production
vercel --prod
```

</details>

---

### Personalizează site-ul

Editează `lib/config.ts` cu datele clientului:

```ts
export const SITE_CONFIG = {
  url: 'https://domeniultau.ro',
  business: {
    name: 'Numele Afacerii',
    phone: '+40700000000',
    // ...
  },
  itemLabel: {
    singular: 'cameră',   // sau 'mașină', 'apartament', 'birou'
    plural: 'camere',
    priceUnit: 'noapte',  // sau 'zi', 'ora'
  },
  // ...
}
```

### Dev local

```bash
npm run dev
```

Deschide [http://localhost:3000](http://localhost:3000).

---

## Structura principală

```
app/
  page.tsx                  # Landing page (hero, listing, contact)
  items/[id]/               # Pagina detaliu item + formular rezervare
  rezervare-confirmata/     # Pagina de confirmare după rezervare
  admin/
    dashboard/              # Tabel rezervări (approve/reject/cancel)
    items/                  # CRUD items cu upload imagini
    contact/                # Formulare contact primite

components/
  Navbar.tsx                # Header sticky cu logo și telefon
  ItemCard.tsx              # Card pentru un item în listing
  ItemGrid.tsx              # Grid cu filtre
  ItemImageGallery.tsx      # Galerie imagini cu thumbnails
  BookingForm.tsx           # Formular rezervare cu calendar
  ContactForm.tsx           # Formular contact

lib/
  config.ts                 # ← EDITEAZĂ ASTA PRIMUL
  email.ts                  # Template-uri email (Resend)
  supabase.ts               # Clienți Supabase (browser + admin)
  supabase-server.ts        # Client server (SSR)

supabase/
  schema.sql                # Schema completă + RLS policies
```

---

## Cum adaugi un item nou

1. Accesează `/admin/items` (după autentificare)
2. Click **Adaugă** → completează formularul
3. Adaugă fotografii (principal + suplimentare)
4. Item-ul apare imediat pe pagina principală

---

## Cum gestionezi rezervările

- `/admin/dashboard` — toate rezervările, filtrate pe status
- **Pending** → poți aproba sau respinge
- **Approved** → poți respinge sau anula
- Clienții primesc email automat la rezervare (necesită domeniu verificat în Resend)

---

## Deploy pe Vercel

```bash
npm install -g vercel
vercel
```

Adaugă variabilele din `.env.local` în **Vercel → Settings → Environment Variables**.

---

## Personalizare avansată

### Schimbă culorile

În `lib/config.ts`:
```ts
branding: {
  primaryColor: '#2563eb',  // albastru implicit
  accentColor: '#16a34a',
}
```

### Dezactivează funcționalități

```ts
features: {
  reservations: true,   // pune false dacă nu vrei sistem de rezervări
  contactForm: true,
  gallery: true,
  whatsapp: false,      // ascunde butonul WhatsApp
}
```

### SEO local business

Editează `app/page.tsx` — blocul `localBusinessJsonLd` — cu coordonatele și tipul afacerii tale.
