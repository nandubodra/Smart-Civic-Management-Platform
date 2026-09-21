import type { Metadata } from 'next'
import { Playfair_Display, Inter } from 'next/font/google'
import './globals.css'
import { Shell } from '@/components/Shell'
const playfair = Playfair_Display({ subsets:['latin'], variable:'--font-playfair' })
const inter = Inter({ subsets:['latin'], variable:'--font-inter' })
export const metadata: Metadata = { title:'SafaiSetu — From Waste to Worth', description:'Smart village waste management, made transparent.' }
export default function RootLayout({ children }:{children:React.ReactNode}) { return <html lang="en"><body className={`${playfair.variable} ${inter.variable}`}><Shell>{children}</Shell></body></html> }
