'use client'
import { signInWithPopup } from 'firebase/auth'
import { useState } from 'react'
import { auth, googleProvider } from '@/lib/firebase/client'

export default function Login(){
  const [loading,setLoading]=useState(false)
  const [error,setError]=useState('')
  async function google(){
    setLoading(true); setError('')
    try {
      await signInWithPopup(auth, googleProvider)
      window.location.href = '/'
    } catch (e) {
      setError(e instanceof Error ? e.message : 'No se pudo iniciar sesión.')
      setLoading(false)
    }
  }
  return <main className="grid min-h-screen place-items-center p-5">
    <section className="w-full max-w-md rounded-3xl border border-white/10 bg-white/[.04] p-8">
      <div className="mb-8 text-center"><div className="text-3xl font-black">VANTYRA</div><p className="mt-2 text-slate-400">Inicia sesión para comprar y gestionar tus pedidos.</p></div>
      <button onClick={google} disabled={loading} className="w-full rounded-xl bg-white px-5 py-3 font-bold text-black disabled:opacity-50">{loading?'Conectando…':'Continuar con Google'}</button>
      {error&&<p className="mt-4 break-words text-sm text-red-400">{error}</p>}
    </section>
  </main>
}