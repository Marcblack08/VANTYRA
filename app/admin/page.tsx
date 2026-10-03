import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
export default async function Admin(){
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 if(!user) redirect('/login')
 const {data:profile}=await supabase.from('profiles').select('role').eq('id',user.id).single()
 if(profile?.role!=='admin') redirect('/')
 return <main className="min-h-screen p-8"><div className="mx-auto max-w-7xl"><p className="text-sm uppercase tracking-[.2em] text-cyan-400">Vantyra</p><h1 className="mt-2 text-4xl font-black">Panel de administración</h1><p className="mt-2 text-slate-400">Gestión central de catálogo, inventario y pedidos.</p><div className="mt-10 grid gap-5 md:grid-cols-3"><a href="/admin/products" className="rounded-2xl border border-white/10 bg-white/[.03] p-6 transition hover:border-cyan-400/50"><h2 className="text-xl font-bold">Productos</h2><p className="mt-2 text-sm text-slate-400">Crear y administrar el catálogo.</p></a><div className="rounded-2xl border border-white/10 bg-white/[.03] p-6"><h2 className="text-xl font-bold">Inventario</h2><p className="mt-2 text-sm text-slate-400">Stock y disponibilidad.</p></div><div className="rounded-2xl border border-white/10 bg-white/[.03] p-6"><h2 className="text-xl font-bold">Pedidos</h2><p className="mt-2 text-sm text-slate-400">Gestión global de pedidos.</p></div></div></div></main>