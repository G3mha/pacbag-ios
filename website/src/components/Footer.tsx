'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import Image from 'next/image'
import { useTilt } from '@/hooks/useTilt'
import { 
  Mail, 
  Twitter, 
  Instagram, 
  Github, 
  MapPin, 
  Send,
  ArrowRight,
  Heart
} from 'lucide-react'

const Footer: React.FC = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  })

  const footerAppStoreTiltRef = useTilt({
    max: 15,
    perspective: 800,
    scale: 1.05,
    speed: 300,
    glare: true,
    'max-glare': 0.2,
  })

  const footerLinks = {
    product: [
      { name: 'Features', href: '#features' },
      { name: 'Pricing', href: '#pricing' },
      { name: 'Download', href: '#download' },
      { name: 'Roadmap', href: '#roadmap' }
    ],
    support: [
      { name: 'Help Center', href: '#help' },
      { name: 'Contact Us', href: '#contact' },
      { name: 'Bug Reports', href: '#bugs' },
      { name: 'Feature Requests', href: '#features-request' }
    ],
    company: [
      { name: 'About Us', href: '#about' },
      { name: 'Blog', href: '#blog' },
      { name: 'Careers', href: '#careers' },
      { name: 'Press Kit', href: '#press' }
    ],
    legal: [
      { name: 'Privacy Policy', href: '/privacy-policy.html' },
      { name: 'Terms of Service', href: '#terms' },
      { name: 'Cookie Policy', href: '#cookies' },
      { name: 'GDPR', href: '#gdpr' }
    ]
  }

  return (
    <footer className="bg-black border-t border-white/10 relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 2px 2px, white 1px, transparent 0)`,
          backgroundSize: '50px 50px'
        }} />
      </div>

      <div className="container mx-auto px-6 py-20 relative">
        <motion.div
          ref={ref}
          className="grid grid-cols-1 lg:grid-cols-12 gap-12"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
        >
          {/* Company Info */}
          <div className="lg:col-span-4">
            <motion.div
              className="mb-8"
              initial={{ opacity: 0, x: -20 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <div className="flex items-center space-x-3 mb-6">
                <Image
                  src="/icon-raw.png"
                  alt="PacBag"
                  width={40}
                  height={40}
                  className="rounded-xl"
                />
                <span className="text-2xl font-bold text-white">PacBag</span>
              </div>
              <p className="text-gray-400 leading-relaxed mb-6">
                The digital twin of your travel luggage. Track every item in your bag and never leave anything behind.
              </p>
              <div className="flex items-center space-x-2 text-gray-400">
                <MapPin className="w-4 h-4" />
                <span>Sao Paulo, Brazil</span>
              </div>
            </motion.div>

            {/* Newsletter */}
            <motion.div
              className="mb-8"
              initial={{ opacity: 0, x: -20 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.6, delay: 0.4 }}
            >
              <h4 className="text-white font-semibold mb-4">Stay Updated</h4>
              <p className="text-gray-400 text-sm mb-4">
                Get travel tips and PacBag updates delivered to your inbox.
              </p>
              <div className="flex space-x-2">
                <div className="flex-1 relative">
                  <input
                    type="email"
                    placeholder="Enter your email"
                    className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:border-purple-500 transition-colors"
                  />
                  <Mail className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
                </div>
                <motion.button
                  className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg hover:from-purple-700 hover:to-pink-700 transition-all duration-300 flex items-center space-x-2"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Send className="w-4 h-4" />
                </motion.button>
              </div>
            </motion.div>

            {/* Social Links */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.6, delay: 0.6 }}
            >
              <h4 className="text-white font-semibold mb-4">Follow Us</h4>
              <div className="flex space-x-4">
                {[
                  { icon: Twitter, href: '#', label: 'Twitter' },
                  { icon: Instagram, href: '#', label: 'Instagram' },
                  { icon: Github, href: '#', label: 'GitHub' },
                ].map((social, index) => (
                  <motion.a
                    key={index}
                    href={social.href}
                    className="w-10 h-10 bg-white/5 border border-white/10 rounded-lg flex items-center justify-center text-gray-400 hover:text-white hover:border-purple-500 hover:bg-purple-500/10 transition-all duration-300"
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.9 }}
                    aria-label={social.label}
                  >
                    <social.icon className="w-4 h-4" />
                  </motion.a>
                ))}
              </div>
            </motion.div>
          </div>

          {/* Links Grid */}
          <div className="lg:col-span-8 grid grid-cols-2 lg:grid-cols-4 gap-8">
            {Object.entries(footerLinks).map(([category, links], categoryIndex) => (
              <motion.div
                key={category}
                initial={{ opacity: 0, y: 20 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.6, delay: 0.3 + categoryIndex * 0.1 }}
              >
                <h4 className="text-white font-semibold mb-6 capitalize">
                  {category}
                </h4>
                <ul className="space-y-3">
                  {links.map((link, linkIndex) => (
                    <motion.li
                      key={linkIndex}
                      initial={{ opacity: 0, x: -10 }}
                      animate={inView ? { opacity: 1, x: 0 } : {}}
                      transition={{ 
                        duration: 0.4, 
                        delay: 0.4 + categoryIndex * 0.1 + linkIndex * 0.05 
                      }}
                    >
                      <a
                        href={link.href}
                        className="text-gray-400 hover:text-white transition-colors duration-200 flex items-center group"
                      >
                        <span>{link.name}</span>
                        <ArrowRight className="w-3 h-3 ml-1 opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all duration-200" />
                      </a>
                    </motion.li>
                  ))}
                </ul>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* App Store Badge */}
        <motion.div
          className="mt-16 pt-8 border-t border-white/10"
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
        >
          <div className="flex flex-col lg:flex-row items-center justify-between space-y-6 lg:space-y-0">
            <div className="flex items-center space-x-4">
              <motion.div
                className="cursor-pointer"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                ref={footerAppStoreTiltRef}
              >
                <Image
                  src="/appstore.png"
                  alt="Download on the App Store"
                  width={150}
                  height={45}
                  className="rounded-lg"
                />
              </motion.div>
              <div className="text-gray-400 text-sm">
                <div className="flex items-center space-x-1">
                  <span>4.9</span>
                  <div className="flex space-x-1">
                    {[...Array(5)].map((_, i) => (
                      <div key={i} className="w-3 h-3 bg-yellow-400 rounded-full" />
                    ))}
                  </div>
                  <span>(2.5K reviews)</span>
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-6 text-gray-400 text-sm">
              <span>iOS 17.0+</span>
              <span>•</span>
              <span>iPhone & iPad</span>
            </div>
          </div>
        </motion.div>

        {/* Bottom Bar */}
        <motion.div
          className="mt-12 pt-8 border-t border-white/10 flex flex-col lg:flex-row items-center justify-between space-y-4 lg:space-y-0"
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 1 }}
        >
          <div className="text-gray-400 text-sm">
            © 2025 Enricco Gemha. All rights reserved.
          </div>
          
          <div className="flex items-center space-x-4 text-gray-400 text-sm">
            <span>Made with</span>
            <motion.div
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ repeat: Infinity, duration: 1.5 }}
            >
              <Heart className="w-4 h-4 text-red-400" fill="currentColor" />
            </motion.div>
            <span>by Enricco Gemha in Sao Paulo</span>
          </div>
        </motion.div>
      </div>

      {/* Decorative Elements */}
      <motion.div
        className="absolute bottom-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-purple-500 to-transparent opacity-50"
        initial={{ scaleX: 0 }}
        animate={inView ? { scaleX: 1 } : {}}
        transition={{ duration: 1.5, delay: 1.2 }}
      />
    </footer>
  )
}

export default Footer