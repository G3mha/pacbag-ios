'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { ArrowRight, Download, Star, Users } from 'lucide-react'

const Hero: React.FC = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-black via-purple-900/20 to-black">
      {/* Background Effects */}
      <div className="absolute inset-0">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }} />
      </div>

      <div className="container mx-auto px-6 py-32 relative z-10">
        <div className="text-center max-w-4xl mx-auto">
          {/* Badge */}
          <motion.div
            className="inline-flex items-center space-x-2 bg-white/5 backdrop-blur-sm border border-white/10 rounded-full px-4 py-2 mb-8"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <Star className="w-4 h-4 text-yellow-400" fill="currentColor" />
            <span className="text-sm text-gray-300">Featured App of the Week</span>
          </motion.div>

          {/* Headline */}
          <motion.h1
            className="text-6xl md:text-7xl lg:text-8xl font-bold mb-6 bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent leading-tight"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.2 }}
          >
            Pack Smart,
            <br />
            Travel Better
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            className="text-xl md:text-2xl text-gray-300 mb-12 max-w-3xl mx-auto leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.4 }}
          >
            The intelligent packing companion that learns from your travel habits and suggests personalized packing lists for every journey.
          </motion.p>

          {/* CTA Buttons */}
          <motion.div
            className="flex flex-col sm:flex-row items-center justify-center space-y-4 sm:space-y-0 sm:space-x-6 mb-16"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.6 }}
          >
            <motion.button
              className="group bg-gradient-to-r from-purple-600 to-pink-600 text-white px-8 py-4 rounded-2xl font-semibold text-lg hover:from-purple-700 hover:to-pink-700 transition-all duration-300 flex items-center space-x-2 shadow-2xl shadow-purple-500/25"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Download className="w-5 h-5" />
              <span>Download Free</span>
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </motion.button>
            
            <motion.button
              className="group border border-white/20 text-white px-8 py-4 rounded-2xl font-semibold text-lg hover:bg-white/5 transition-all duration-300 flex items-center space-x-2"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <span>Watch Demo</span>
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </motion.button>
          </motion.div>

          {/* Social Proof */}
          <motion.div
            className="flex flex-col sm:flex-row items-center justify-center space-y-6 sm:space-y-0 sm:space-x-12 text-gray-400"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.8 }}
          >
            <div className="flex items-center space-x-2">
              <Users className="w-5 h-5" />
              <span>100K+ travelers trust us</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="flex space-x-1">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-4 h-4 text-yellow-400" fill="currentColor" />
                ))}
              </div>
              <span>4.9/5 App Store rating</span>
            </div>
          </motion.div>
        </div>

        {/* Phone Mockup */}
        <motion.div
          className="relative max-w-sm mx-auto mt-20"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1 }}
        >
          <div className="relative">
            {/* Phone Frame */}
            <div className="bg-gradient-to-b from-gray-800 to-gray-900 rounded-[3rem] p-3 shadow-2xl">
              <div className="bg-black rounded-[2.5rem] overflow-hidden">
                {/* Screen Content */}
                <div className="aspect-[9/19.5] bg-gradient-to-b from-purple-900/50 to-black p-6 relative">
                  {/* Status Bar */}
                  <div className="flex justify-between items-center text-white text-sm mb-8">
                    <span>9:41</span>
                    <div className="flex space-x-1">
                      <div className="w-4 h-2 bg-white rounded-sm"></div>
                      <div className="w-4 h-2 bg-white rounded-sm"></div>
                      <div className="w-4 h-2 bg-white/50 rounded-sm"></div>
                    </div>
                  </div>

                  {/* App Content */}
                  <div className="text-white">
                    <h3 className="text-xl font-bold mb-4">Weekend Trip</h3>
                    <div className="space-y-3">
                      {['👕 Casual shirts (3)', '👖 Jeans (2)', '🧥 Light jacket', '👟 Sneakers'].map((item, i) => (
                        <motion.div
                          key={i}
                          className="flex items-center space-x-3 bg-white/10 rounded-lg p-3"
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.5 + i * 0.1 }}
                        >
                          <div className="w-6 h-6 border border-white/30 rounded"></div>
                          <span className="text-sm">{item}</span>
                        </motion.div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Floating Elements */}
            <motion.div
              className="absolute -top-4 -right-4 bg-green-500 text-white p-2 rounded-full shadow-lg"
              animate={{ y: [-5, 5, -5] }}
              transition={{ repeat: Infinity, duration: 2 }}
            >
              ✓
            </motion.div>
            <motion.div
              className="absolute -bottom-4 -left-4 bg-purple-500 text-white p-3 rounded-full shadow-lg"
              animate={{ y: [5, -5, 5] }}
              transition={{ repeat: Infinity, duration: 2, delay: 0.5 }}
            >
              🎒
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

export default Hero