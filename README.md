# VANTYRA

Marketplace built with Next.js and Firebase.

## Stack
- Next.js App Router
- Firebase Authentication (Google)
- Cloud Firestore
- Firebase Storage
- Firebase Admin SDK
- Tailwind CSS

## Environment
Copy `.env.example` to `.env.local`.

Public Firebase configuration may be present in the browser. Never expose `FIREBASE_PRIVATE_KEY`, service-account JSON, or other Admin credentials to client code.

## Development
```bash
npm install
npm run dev
```

## Firebase collections planned
- users
- categories
- products
- carts
- favorites
- orders
- orderItems

The next implementation stage enables Firestore catalog management and Firebase Storage uploads.