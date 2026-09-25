# Ivoanjimi Web (React + Vite + TypeScript)

Guest-facing web app for the Ivoanjimi short-term rental platform (Nigeria).
Wired to the real NestJS backend in `../backend`.

## Screens

- **Login** — demo credentials prefilled (`customer@example.com` / `Customer123!`)
- **Home** — fresh stays + city shortcuts
- **Explore** — search with filters (city, price, bedrooms, guests, dates, sort)
- **Property details** — gallery, amenities, host card, reviews, booking widget
  with price breakdown + mock-payment reserve flow, save-to-favorites,
  message-host
- **Trips** — upcoming / completed / cancelled bookings
- **Booking details** — full details, two-step cancellation (pending bookings),
  message host, leave-a-review for completed stays
- **Messages** — conversation list + thread with composer and mark-as-read
- **Favorites** — saved stays (optimistic heart toggles everywhere)
- **Profile** — account details, settings links, become-a-host, logout

## Run it

```bash
# 1. Backend (from ../backend)
#    needs PostgreSQL + DATABASE_URL in .env, then:
npx prisma migrate deploy
npx tsx prisma/seed-demo.ts   # believable demo data (8 Lagos/Abuja/PH/Ibadan listings)
npm run start:dev              # API on http://localhost:3000

# 2. Web (from this folder)
npm install
npm run dev                    # app on http://localhost:5173
```

Set `VITE_API_URL` in a `.env` file to point at a non-local backend.

## Reliability behavior

- Expired/invalid token → automatic logout + redirect to login.
- Offline → banner; failed requests surface a retryable error notice.
- Empty search results → friendly empty state.
- Booking form validates dates client-side (checkout after check-in, no past
  check-in); server re-validates.
- Cancel requires a two-step confirm and only works on pending bookings.
- Reviews only for completed stays, one per booking (server enforced).
- Favorite hearts are optimistic and degrade gracefully if the API is behind.
