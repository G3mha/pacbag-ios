'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import { Play, Pause, ChevronLeft, ChevronRight } from 'lucide-react'
import type { Demo } from '@/types'

const demos: Demo[] = [
  {
    id: 1,
    title: 'Create Your Trip',
    description: 'Start by adding your destination, dates, and trip type. PacBag automatically suggests relevant categories.',
    image: '/demo-1.jpg'
  },
  {
    id: 2,
    title: 'Smart Suggestions',
    description: 'Our AI analyzes weather, activities, and your preferences to suggest personalized packing items.',
    image: '/demo-2.jpg'
  },
  {
    id: 3,
    title: 'Organize & Check',
    description: 'Organize items by category, add custom items, and check off packed items with satisfying animations.',
    image: '/demo-3.jpg'
  },
  {
    id: 4,
    title: 'Share & Sync',
    description: 'Share lists with travel companions and sync across all your devices seamlessly.',
    image: '/demo-4.jpg'
  }
]

const ProductDemo: React.FC = () => {
  const [currentDemo, setCurrentDemo] = useState(0)
  const [isPlaying, setIsPlaying] = useState(true)
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.3,
  })

  useEffect(() => {
    if (!isPlaying || !inView) return

    const interval = setInterval(() => {
      setCurrentDemo((prev) => (prev + 1) % demos.length)
    }, 4000)

    return () => clearInterval(interval)
  }, [isPlaying, inView])

  const nextDemo = () => {
    setCurrentDemo((prev) => (prev + 1) % demos.length)
  }

  const prevDemo = () => {
    setCurrentDemo((prev) => (prev - 1 + demos.length) % demos.length)
  }

  return (
    <section id="demo" className="py-32 bg-gradient-to-b from-black to-purple-900/10">
      <div className="container mx-auto px-6">
        <motion.div
          ref={ref}
          className="text-center mb-20"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7 }}
        >
          <motion.div
            className="inline-flex items-center space-x-2 bg-pink-500/10 border border-pink-500/20 rounded-full px-4 py-2 mb-6"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Play className="w-4 h-4 text-pink-400" />
            <span className="text-sm text-pink-300">Interactive Demo</span>
          </motion.div>

          <h2 className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent">
            See PacBag
            <br />
            <span className="bg-gradient-to-r from-pink-400 to-purple-400 bg-clip-text text-transparent">
              in action
            </span>
          </h2>
          
          <p className="text-xl text-gray-400 max-w-3xl mx-auto">
            Experience the intuitive workflow that makes packing effortless, from trip planning to final checklist.
          </p>
        </motion.div>

        <div className="max-w-6xl mx-auto">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Phone Mockup */}
            <motion.div
              className="relative max-w-sm mx-auto"
              initial={{ opacity: 0, x: -50 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.3 }}
            >
              <div className="relative">
                {/* Phone Frame */}
                <div className="bg-gradient-to-b from-gray-800 to-gray-900 rounded-[3rem] p-3 shadow-2xl">
                  <div className="bg-black rounded-[2.5rem] overflow-hidden">
                    {/* Screen Content */}
                    <div className="aspect-[9/19.5] bg-gradient-to-b from-purple-900/30 to-black relative">
                      <AnimatePresence mode="wait">
                        <motion.div
                          key={currentDemo}
                          className="absolute inset-0 p-6"
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, y: -20 }}
                          transition={{ duration: 0.5 }}
                        >
                          {/* Status Bar */}
                          <div className="flex justify-between items-center text-white text-sm mb-8">
                            <span>9:41</span>
                            <div className="flex space-x-1">
                              <div className="w-4 h-2 bg-white rounded-sm"></div>
                              <div className="w-4 h-2 bg-white rounded-sm"></div>
                              <div className="w-4 h-2 bg-white/50 rounded-sm"></div>
                            </div>
                          </div>

                          {/* Demo Content */}
                          <div className="text-white h-full flex flex-col">
                            {currentDemo === 0 && (
                              <div className="space-y-6">
                                <h3 className="text-2xl font-bold">New Trip</h3>
                                <div className="space-y-4">
                                  <div className="bg-white/10 rounded-xl p-4">
                                    <label className="text-sm text-gray-300">Destination</label>
                                    <div className="text-lg font-medium">Tokyo, Japan</div>
                                  </div>
                                  <div className="bg-white/10 rounded-xl p-4">
                                    <label className="text-sm text-gray-300">Duration</label>
                                    <div className="text-lg font-medium">5 days</div>
                                  </div>
                                  <div className="bg-white/10 rounded-xl p-4">
                                    <label className="text-sm text-gray-300">Trip Type</label>
                                    <div className="text-lg font-medium">Business</div>
                                  </div>
                                </div>
                              </div>
                            )}

                            {currentDemo === 1 && (
                              <div className="space-y-6">
                                <h3 className="text-xl font-bold">AI Suggestions</h3>
                                <div className="space-y-3">
                                  {['🌡️ Weather: 15-22°C', '☔ Rain expected', '👔 Business attire', '🔌 Universal adapter'].map((item, i) => (
                                    <motion.div
                                      key={i}
                                      className="bg-gradient-to-r from-purple-500/20 to-pink-500/20 rounded-lg p-3 border border-purple-400/30"
                                      initial={{ opacity: 0, x: -20 }}
                                      animate={{ opacity: 1, x: 0 }}
                                      transition={{ delay: i * 0.1 }}
                                    >
                                      <span className="text-sm">{item}</span>
                                    </motion.div>
                                  ))}
                                </div>
                              </div>
                            )}

                            {currentDemo === 2 && (
                              <div className="space-y-6">
                                <h3 className="text-xl font-bold">Packing List</h3>
                                <div className="space-y-3">
                                  {['👔 Business suits (3)', '👞 Dress shoes', '☂️ Umbrella', '💻 Laptop'].map((item, i) => (
                                    <motion.div
                                      key={i}
                                      className="flex items-center space-x-3 bg-white/10 rounded-lg p-3"
                                      initial={{ opacity: 0, scale: 0.8 }}
                                      animate={{ opacity: 1, scale: 1 }}
                                      transition={{ delay: i * 0.1 }}
                                    >
                                      <motion.div
                                        className="w-6 h-6 border-2 border-green-400 rounded bg-green-400/20"
                                        whileHover={{ scale: 1.1 }}
                                        whileTap={{ scale: 0.9 }}
                                      >
                                        <motion.div
                                          className="w-full h-full flex items-center justify-center text-green-400 text-xs"
                                          initial={{ opacity: 0 }}
                                          animate={{ opacity: 1 }}
                                          transition={{ delay: 0.5 + i * 0.1 }}
                                        >
                                          ✓
                                        </motion.div>
                                      </motion.div>
                                      <span className="text-sm">{item}</span>
                                    </motion.div>
                                  ))}
                                </div>
                              </div>
                            )}

                            {currentDemo === 3 && (
                              <div className="space-y-6">
                                <h3 className="text-xl font-bold">Share & Sync</h3>
                                <div className="bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-xl p-4 border border-blue-400/30">
                                  <div className="flex items-center space-x-3 mb-3">
                                    <div className="w-8 h-8 bg-blue-500 rounded-full"></div>
                                    <span className="text-sm">Shared with team</span>
                                  </div>
                                  <div className="text-xs text-gray-300">
                                    All devices synced ✓
                                  </div>
                                </div>
                                <div className="flex space-x-2">
                                  <div className="w-12 h-12 bg-gradient-to-r from-gray-700 to-gray-600 rounded-xl flex items-center justify-center">
                                    📱
                                  </div>
                                  <div className="w-12 h-12 bg-gradient-to-r from-gray-700 to-gray-600 rounded-xl flex items-center justify-center">
                                    💻
                                  </div>
                                  <div className="w-12 h-12 bg-gradient-to-r from-gray-700 to-gray-600 rounded-xl flex items-center justify-center">
                                    ⌚
                                  </div>
                                </div>
                              </div>
                            )}
                          </div>
                        </motion.div>
                      </AnimatePresence>
                    </div>
                  </div>
                </div>

                {/* Floating Animation */}
                <motion.div
                  className="absolute -top-4 -right-4 w-8 h-8 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center shadow-lg"
                  animate={{ 
                    y: [-5, 5, -5],
                    rotate: [0, 180, 360]
                  }}
                  transition={{ 
                    repeat: Infinity, 
                    duration: 3,
                    ease: "easeInOut"
                  }}
                >
                  ✨
                </motion.div>
              </div>
            </motion.div>

            {/* Demo Controls */}
            <motion.div
              className="space-y-8"
              initial={{ opacity: 0, x: 50 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.5 }}
            >
              <div className="flex items-center justify-between mb-8">
                <h3 className="text-2xl font-bold text-white">
                  Step {currentDemo + 1} of {demos.length}
                </h3>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={prevDemo}
                    className="p-2 bg-white/10 rounded-lg hover:bg-white/20 transition-colors"
                  >
                    <ChevronLeft className="w-5 h-5 text-white" />
                  </button>
                  <button
                    onClick={() => setIsPlaying(!isPlaying)}
                    className="p-2 bg-white/10 rounded-lg hover:bg-white/20 transition-colors"
                  >
                    {isPlaying ? 
                      <Pause className="w-5 h-5 text-white" /> : 
                      <Play className="w-5 h-5 text-white" />
                    }
                  </button>
                  <button
                    onClick={nextDemo}
                    className="p-2 bg-white/10 rounded-lg hover:bg-white/20 transition-colors"
                  >
                    <ChevronRight className="w-5 h-5 text-white" />
                  </button>
                </div>
              </div>

              <AnimatePresence mode="wait">
                <motion.div
                  key={currentDemo}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.5 }}
                >
                  <h4 className="text-3xl font-bold text-white mb-4">
                    {demos[currentDemo].title}
                  </h4>
                  <p className="text-lg text-gray-300 leading-relaxed mb-6">
                    {demos[currentDemo].description}
                  </p>
                </motion.div>
              </AnimatePresence>

              {/* Progress Dots */}
              <div className="flex space-x-3">
                {demos.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setCurrentDemo(index)}
                    className={`w-3 h-3 rounded-full transition-all duration-300 ${
                      index === currentDemo
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 w-8'
                        : 'bg-white/30 hover:bg-white/50'
                    }`}
                  />
                ))}
              </div>

              <motion.button
                className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-8 py-4 rounded-2xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all duration-300 shadow-2xl shadow-purple-500/25"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                Try It Yourself
              </motion.button>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default ProductDemo