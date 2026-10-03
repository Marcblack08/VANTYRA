# VANTYRA

Marketplace moderno construido con Next.js, Supabase y Tailwind CSS.

## Stack
- Next.js App Router
- TypeScript
- Tailwind CSS
- Lucide React
- Supabase Auth / PostgreSQL / Storage

## Inicio
1. Copia .env.example a .env.local.
2. Configura NEXT_PUBLIC_SUPABASE_URL y NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY.
3. Ejecuta supabase/schema.sql en el SQL Editor de Supabase.
4. Activa Google OAuth en Supabase.
5. npm install
6. npm run dev

## Seguridad
La autorización administrativa se aplica mediante RLS. Nunca expongas SUPABASE_SERVICE_ROLE_KEY al navegador.
