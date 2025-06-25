import Hero from '@/components/Hero'
import Navbar from '@/components/Navbar'
import Features from '@/components/Features'
import ProductDemo from '@/components/ProductDemo'
import Stats from '@/components/Stats'
import Testimonials from '@/components/Testimonials'
import Pricing from '@/components/Pricing'
import FAQ from '@/components/FAQ'
import CTA from '@/components/CTA'
import Footer from '@/components/Footer'

export default function Home() {
  return (
    <main className="min-h-screen bg-black text-white overflow-x-hidden">
      <Navbar />
      <Hero />
      <Features />
      <ProductDemo />
      <Stats />
      <Testimonials />
      <Pricing />
      <FAQ />
      <CTA />
      <Footer />
    </main>
  )
}