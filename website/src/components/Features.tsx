'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import { 
  Brain, 
  Cloud, 
  Smartphone, 
  Users, 
  MapPin, 
  Clock, 
  Shield, 
  Zap, 
  Heart 
} from 'lucide-react'
import type { Feature } from '@/types'

const features: Feature[] = [
  {
    icon: Brain,
    title: 'AI-Powered Suggestions',
    description: 'Smart recommendations based on your destination, weather, and travel history.',
    highlight: true
  },
  {
    icon: Cloud,
    title: 'Cloud Sync',
    description: 'Access your packing lists across all devices with seamless synchronization.',
  },
  {
    icon: Smartphone,
    title: 'Native iOS Experience',
    description: 'Built specifically for iOS with intuitive gestures and smooth animations.',
  },
  {
    icon: Users,
    title: 'Family Sharing',
    description: 'Share packing lists with family members and collaborate on group trips.',
  },
  {
    icon: MapPin,
    title: 'Location-Based Lists',
    description: 'Get location-specific suggestions for activities and weather conditions.',
  },
  {
    icon: Clock,
    title: 'Smart Reminders',
    description: 'Never forget important items with intelligent packing reminders.',
  },
  {
    icon: Shield,
    title: 'Privacy First',
    description: 'Your data stays private with end-to-end encryption and local storage.',
  },
  {
    icon: Zap,
    title: 'Lightning Fast',
    description: 'Optimized performance ensures smooth experience even with large lists.',
  },
  {
    icon: Heart,
    title: 'Apple Ecosystem',
    description: 'Deep integration with iOS, Shortcuts, and Apple Watch support.',
    highlight: true
  }
]

const Features: React.FC = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  })

  return (
    <section id="features" className="py-32 bg-black relative">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 2px 2px, white 1px, transparent 0)`,
          backgroundSize: '40px 40px'
        }} />
      </div>

      <div className="container mx-auto px-6 relative">
        <motion.div
          ref={ref}
          className="text-center mb-20"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7 }}
        >
          <motion.div
            className="inline-flex items-center space-x-2 bg-purple-500/10 border border-purple-500/20 rounded-full px-4 py-2 mb-6"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Zap className="w-4 h-4 text-purple-400" />
            <span className="text-sm text-purple-300">Powerful Features</span>
          </motion.div>

          <h2 className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent">
            Everything you need
            <br />
            <span className="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              in one app
            </span>
          </h2>
          
          <p className="text-xl text-gray-400 max-w-3xl mx-auto">
            PacBag combines intelligent automation with intuitive design to make packing effortless and stress-free.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              className={`group relative p-8 rounded-2xl border transition-all duration-300 hover:scale-105 ${
                feature.highlight
                  ? 'bg-gradient-to-br from-purple-900/20 to-pink-900/20 border-purple-500/30 hover:border-purple-400/50'
                  : 'bg-white/5 border-white/10 hover:border-white/20 hover:bg-white/10'
              }`}
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: index * 0.1 }}
            >
              {/* Highlight Glow */}
              {feature.highlight && (
                <div className="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-pink-500/10 rounded-2xl blur-xl group-hover:blur-2xl transition-all duration-300" />
              )}

              <div className="relative">
                <div className={`inline-flex items-center justify-center w-12 h-12 rounded-xl mb-6 ${
                  feature.highlight
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500'
                    : 'bg-white/10'
                }`}>
                  <feature.icon className="w-6 h-6 text-white" />
                </div>

                <h3 className="text-xl font-semibold text-white mb-3">
                  {feature.title}
                </h3>
                
                <p className="text-gray-400 leading-relaxed">
                  {feature.description}
                </p>

                {/* Hover Arrow */}
                <motion.div
                  className="absolute top-8 right-8 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  initial={{ x: -10 }}
                  whileHover={{ x: 0 }}
                >
                  <div className="w-8 h-8 bg-white/10 rounded-full flex items-center justify-center">
                    <motion.div
                      animate={{ x: [0, 4, 0] }}
                      transition={{ repeat: Infinity, duration: 1.5 }}
                    >
                      →
                    </motion.div>
                  </div>
                </motion.div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Bottom CTA */}
        <motion.div
          className="text-center mt-20"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.5 }}
        >
          <p className="text-gray-400 mb-6">
            Ready to revolutionize your packing experience?
          </p>
          <motion.button
            className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-8 py-4 rounded-2xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all duration-300 shadow-2xl shadow-purple-500/25"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Get Started Free
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
}

export default Features