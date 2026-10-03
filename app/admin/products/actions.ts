'use server'
import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
export async function createProduct(formData:FormData){
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 if(!user) throw new Error('No autenticado')
 const {data:profile}=await supabase.from('profiles').select('role').eq('id',user.id).single()
 if(profile?.role!=='admin') throw new Error('No autorizado')
 const name=String(formData.get('name')||'').trim()
 const description=String(formData.get('description')||'').trim()
 const price=Number(formData.get('price'))
 const sale=String(formData.get('sale_price')||'').trim()
 const stock=Number(formData.get('stock'))
 if(!name||!Number.isFinite(price)||price<0||!Number.isInteger(stock)||stock<0) throw new Error('Datos de producto inválidos')
 const slug=name.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')+'-'+crypto.randomUUID().slice(0,8)
 const {error}=await supabase.from('products').insert({name,slug,description,price,sale_price:sale?Number(sale):null,stock,created_by:user.id})
 if(error) throw new Error(error.message)
 revalidatePath('/')
 revalidatePath('/admin/products')
}
