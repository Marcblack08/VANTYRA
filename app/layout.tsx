import './globals.css'
import type { Metadata } from 'next'
export const metadata:Metadata={title:'Vantyra | Marketplace',description:'Marketplace de nueva generación.'}
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="es"><body>{children}</body></html>}
