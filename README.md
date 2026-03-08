# Skincare App

A cross-platform skincare product discovery app with a REST API backend.

## Structure

```
skincare-app/
├── app/        # Flutter mobile app (iOS & Android)
└── backend/    # Node.js + Express + TypeScript REST API
```

## App (`app/`)

Flutter app supporting HK, SG, MY, TW, JP markets.

**Features:**
- Browse & search skincare products by country
- Filter by product type or functionality (Hydrating, Brightening, Anti-aging, etc.)
- Product detail with ingredients & store availability
- Favorites / wishlist
- Local store & online store listings per country

**Run:**
```bash
cd app
flutter pub get
flutter run
```

## Backend (`backend/`)

Node.js + Express + TypeScript REST API backed by PostgreSQL.

**Endpoints:**
- `POST /api/auth/register` & `/api/auth/login` — JWT auth
- `GET  /api/products` — filter by country, category, functionality, brand, price, search
- `GET  /api/countries/:code/stores` — stores per country
- `GET|POST|DELETE /api/favorites` — wishlist (authenticated)
- `GET|POST /api/products/:id/reviews` — reviews & ratings

**Run:**
```bash
cd backend
cp .env.example .env   # fill in DATABASE_URL and JWT_SECRET
npm install
npm run db:schema      # create tables
npm run db:seed        # seed countries, stores & products
npm run dev            # start dev server on :3000
```

## Deploy (Railway)

1. Connect this repo on [Railway](https://railway.app)
2. Set **Root Directory** → `backend`
3. Add a PostgreSQL plugin
4. Set environment variables from `.env.example`
5. Railway auto-detects Node and runs `npm start`
