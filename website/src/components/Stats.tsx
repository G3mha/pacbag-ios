'use client'

import React, { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import type { Stat } from '@/types'

const stats: Stat[] = [
  { number: '100', label: 'Happy Travelers', suffix: 'K+' },
  { number: '2.5', label: 'Items Packed', suffix: 'M+' },
  { number: '150', label: 'Countries Visited', suffix: '+' },
  { number: '4.9', label: 'App Store Rating', suffix: '/5' }
]

const AnimatedCounter: React.FC<{ value: string; suffix?: string; inView: boolean }> = ({ 
  value, 
  suffix = '', 
  inView 
}) => {
  const [count, setCount] = useState(0)
  const numericValue = parseFloat(value)

  useEffect(() => {
    if (!inView) return

    const duration = 2000
    const steps = 50
    const increment = numericValue / steps
    let current = 0

    const timer = setInterval(() => {
      current += increment
      if (current >= numericValue) {
        setCount(numericValue)
        clearInterval(timer)
      } else {
        setCount(current)
      }
    }, duration / steps)

    return () => clearInterval(timer)
  }, [inView, numericValue])

  const displayValue = numericValue % 1 === 0 ? Math.floor(count) : count.toFixed(1)

  return (
    <span className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
      {displayValue}{suffix}
    </span>
  )
}

const Stats: React.FC = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.3,
  })

  return (
    <section className="py-32 bg-gradient-to-r from-purple-900/10 via-black to-pink-900/10">
      <div className="container mx-auto px-6">
        <motion.div
          ref={ref}
          className="text-center mb-20"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7 }}
        >
          <motion.div
            className="inline-flex items-center space-x-2 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-full px-4 py-2 mb-6"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <span className="text-sm text-purple-300">Trusted Worldwide</span>
          </motion.div>

          <h2 className="text-5xl md:text-6xl font-bold mb-6 text-white">
            Numbers that speak
            <br />
            <span className="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              for themselves
            </span>
          </h2>
          
          <p className="text-xl text-gray-400 max-w-3xl mx-auto">
            Join thousands of travelers who have transformed their packing experience with PacBag.
          </p>
        </motion.div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              className="text-center group"
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: index * 0.1 }}
            >
              <motion.div
                className="relative mb-4"
                whileHover={{ scale: 1.05 }}
                transition={{ type: "spring", stiffness: 300, damping: 20 }}
              >
                {/* Glow Effect */}
                <div className="absolute inset-0 bg-gradient-to-r from-purple-500/20 to-pink-500/20 rounded-2xl blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                
                <div className="relative bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 group-hover:border-purple-400/30 transition-all duration-300">
                  <AnimatedCounter 
                    value={stat.number} 
                    suffix={stat.suffix} 
                    inView={inView} 
                  />
                  
                  <div className="mt-4">
                    <h3 className="text-lg font-semibold text-gray-300 group-hover:text-white transition-colors duration-300">
                      {stat.label}
                    </h3>
                  </div>

                  {/* Decorative Elements */}
                  <motion.div
                    className="absolute top-4 right-4 w-2 h-2 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full opacity-0 group-hover:opacity-100"
                    animate={{ 
                      scale: [1, 1.2, 1],
                      opacity: inView ? [0, 1, 0.7] : 0
                    }}
                    transition={{ 
                      repeat: Infinity, 
                      duration: 2,
                      delay: index * 0.2
                    }}
                  />
                </div>
              </motion.div>
            </motion.div>
          ))}
        </div>

        {/* Trust Indicators */}
        <motion.div
          className="mt-20 text-center"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.5 }}
        >
          <p className="text-gray-400 mb-8">
            Featured and trusted by leading travel communities
          </p>
          
          <div className="flex flex-wrap justify-center items-center gap-8 opacity-50">
            {/* Placeholder for partner logos */}
            {['TechCrunch', 'App Store', 'Product Hunt', 'Nomad List'].map((partner, index) => (
              <motion.div
                key={index}
                className="px-6 py-3 bg-white/5 rounded-lg border border-white/10"
                whileHover={{ scale: 1.05, opacity: 0.8 }}
                transition={{ duration: 0.2 }}
              >
                <span className="text-gray-500 font-medium">{partner}</span>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* Call to Action */}
        <motion.div
          className="text-center mt-16"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.7 }}
        >
          <motion.button
            className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-8 py-4 rounded-2xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all duration-300 shadow-2xl shadow-purple-500/25"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Join the Community
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
}

export default Stats