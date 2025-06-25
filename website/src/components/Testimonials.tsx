'use client'

import React, { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import { ChevronLeft, ChevronRight, Star, Quote } from 'lucide-react'
import type { Testimonial } from '@/types'

const testimonials: Testimonial[] = [
  {
    id: 1,
    name: 'Sarah Chen',
    role: 'Digital Nomad',
    company: 'Remote Tech',
    content: 'PacBag has completely transformed how I prepare for my travels. The AI suggestions are incredibly accurate, and I never forget important items anymore. It\'s like having a personal packing assistant.',
    rating: 5,
    avatar: '👩‍💻'
  },
  {
    id: 2,
    name: 'Marcus Rodriguez',
    role: 'Travel Blogger',
    company: 'Wanderlust Weekly',
    content: 'As someone who travels 200+ days a year, I need efficiency. PacBag\'s smart categorization and sync across devices saves me hours of preparation time. Absolutely essential for frequent travelers.',
    rating: 5,
    avatar: '🧑‍✈️'
  },
  {
    id: 3,
    name: 'Emma Thompson',
    role: 'Family Travel Coordinator',
    company: 'The Thompson Family',
    content: 'Managing packing for a family of five was a nightmare until we found PacBag. The family sharing feature and custom lists for each family member is a game-changer. Highly recommend!',
    rating: 5,
    avatar: '👩‍👧‍👦'
  },
  {
    id: 4,
    name: 'James Kim',
    role: 'Business Executive',
    company: 'Global Enterprises',
    content: 'The business trip templates are spot-on. PacBag understands the difference between a 2-day conference and a week-long client visit. It\'s professional, intuitive, and incredibly reliable.',
    rating: 5,
    avatar: '👨‍💼'
  },
  {
    id: 5,
    name: 'Priya Patel',
    role: 'Adventure Photographer',
    company: 'Wild Lens Studio',
    content: 'From camera gear to hiking equipment, PacBag\'s specialized categories cover everything. The weather integration is perfect for planning shoots in remote locations. Love this app!',
    rating: 5,
    avatar: '📸'
  }
]

const Testimonials: React.FC = () => {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isAutoPlaying, setIsAutoPlaying] = useState(true)
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.2,
  })

  useEffect(() => {
    if (!isAutoPlaying || !inView) return

    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % testimonials.length)
    }, 5000)

    return () => clearInterval(interval)
  }, [isAutoPlaying, inView])

  const nextTestimonial = () => {
    setCurrentIndex((prev) => (prev + 1) % testimonials.length)
    setIsAutoPlaying(false)
  }

  const prevTestimonial = () => {
    setCurrentIndex((prev) => (prev - 1 + testimonials.length) % testimonials.length)
    setIsAutoPlaying(false)
  }

  const goToTestimonial = (index: number) => {
    setCurrentIndex(index)
    setIsAutoPlaying(false)
  }

  return (
    <section className="py-32 bg-black relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 1px 1px, white 1px, transparent 0)`,
          backgroundSize: '50px 50px'
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
            className="inline-flex items-center space-x-2 bg-yellow-500/10 border border-yellow-500/20 rounded-full px-4 py-2 mb-6"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Star className="w-4 h-4 text-yellow-400" fill="currentColor" />
            <span className="text-sm text-yellow-300">5-Star Reviews</span>
          </motion.div>

          <h2 className="text-5xl md:text-6xl font-bold mb-6 text-white">
            Loved by travelers
            <br />
            <span className="bg-gradient-to-r from-yellow-400 to-orange-400 bg-clip-text text-transparent">
              worldwide
            </span>
          </h2>
          
          <p className="text-xl text-gray-400 max-w-3xl mx-auto">
            Don't just take our word for it. Here's what our community of travelers has to say about PacBag.
          </p>
        </motion.div>

        <div className="max-w-4xl mx-auto">
          {/* Main Testimonial Card */}
          <motion.div
            className="relative"
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.3 }}
          >
            <div className="bg-gradient-to-br from-white/10 to-white/5 backdrop-blur-sm border border-white/20 rounded-3xl p-8 md:p-12 relative overflow-hidden">
              {/* Background Quote */}
              <Quote className="absolute top-8 right-8 w-16 h-16 text-white/5" />
              
              <AnimatePresence mode="wait">
                <motion.div
                  key={currentIndex}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.5 }}
                  className="relative z-10"
                >
                  {/* Stars */}
                  <div className="flex justify-center mb-6">
                    <div className="flex space-x-1">
                      {[...Array(testimonials[currentIndex].rating)].map((_, i) => (
                        <Star 
                          key={i} 
                          className="w-6 h-6 text-yellow-400" 
                          fill="currentColor" 
                        />
                      ))}
                    </div>
                  </div>

                  {/* Testimonial Content */}
                  <blockquote className="text-xl md:text-2xl text-white text-center leading-relaxed mb-8 font-medium">
                    "{testimonials[currentIndex].content}"
                  </blockquote>

                  {/* Author */}
                  <div className="flex items-center justify-center space-x-4">
                    <div className="w-16 h-16 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-2xl">
                      {testimonials[currentIndex].avatar}
                    </div>
                    <div className="text-left">
                      <div className="text-white font-semibold text-lg">
                        {testimonials[currentIndex].name}
                      </div>
                      <div className="text-gray-400">
                        {testimonials[currentIndex].role}
                      </div>
                      <div className="text-gray-500 text-sm">
                        {testimonials[currentIndex].company}
                      </div>
                    </div>
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>

            {/* Navigation Arrows */}
            <button
              onClick={prevTestimonial}
              className="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 backdrop-blur-sm border border-white/20 rounded-full flex items-center justify-center hover:bg-white/20 transition-all duration-300 group"
            >
              <ChevronLeft className="w-6 h-6 text-white group-hover:scale-110 transition-transform" />
            </button>
            
            <button
              onClick={nextTestimonial}
              className="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 backdrop-blur-sm border border-white/20 rounded-full flex items-center justify-center hover:bg-white/20 transition-all duration-300 group"
            >
              <ChevronRight className="w-6 h-6 text-white group-hover:scale-110 transition-transform" />
            </button>
          </motion.div>

          {/* Testimonial Indicators */}
          <motion.div
            className="flex justify-center mt-8 space-x-2"
            initial={{ opacity: 0, y: 20 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.5 }}
          >
            {testimonials.map((_, index) => (
              <button
                key={index}
                onClick={() => goToTestimonial(index)}
                className={`h-2 rounded-full transition-all duration-300 ${
                  index === currentIndex
                    ? 'w-8 bg-gradient-to-r from-purple-500 to-pink-500'
                    : 'w-2 bg-white/30 hover:bg-white/50'
                }`}
              />
            ))}
          </motion.div>

          {/* Mini Testimonials Grid */}
          <motion.div
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16"
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.7 }}
          >
            {testimonials.slice(0, 3).map((testimonial, index) => (
              <motion.div
                key={testimonial.id}
                className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-6 hover:border-white/20 transition-all duration-300 cursor-pointer"
                onClick={() => goToTestimonial(index)}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <div className="flex items-center space-x-3 mb-4">
                  <div className="w-10 h-10 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-sm">
                    {testimonial.avatar}
                  </div>
                  <div>
                    <div className="text-white font-medium text-sm">
                      {testimonial.name}
                    </div>
                    <div className="text-gray-400 text-xs">
                      {testimonial.role}
                    </div>
                  </div>
                </div>
                <p className="text-gray-300 text-sm leading-relaxed">
                  {testimonial.content.slice(0, 100)}...
                </p>
                <div className="flex mt-3">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-3 h-3 text-yellow-400" fill="currentColor" />
                  ))}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  )
}

export default Testimonials