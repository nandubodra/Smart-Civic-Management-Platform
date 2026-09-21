import type { Config } from 'tailwindcss'
const config: Config = { content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'], theme: { extend: { colors: { navy:'#0A1931', ivory:'#FFFFF0', gold:'#C5A880', mist:'#F4F3EE' }, fontFamily: { display:['var(--font-playfair)'], sans:['var(--font-inter)'] }, boxShadow: { luxury:'0 18px 55px rgba(10,25,49,.10)' } } }, plugins: [] }
export default config
