'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { useInView } from 'react-intersection-observer'
import { Check, Star, Zap } from 'lucide-react'
import type { PricingPlan } from '@/types'

const plans: PricingPlan[] = [
  {
    name: 'Free',
    price: '$0',
    period: 'forever',
    description: 'Perfect for occasional travelers',
    features: [
      'Up to 3 active trips',
      'Basic packing templates',
      'Manual item management',
      'Basic weather integration',
      'iOS app access'
    ],
    cta: 'Get Started Free'
  },
  {
    name: 'Pro',
    price: '$4.99',
    period: 'per month',
    description: 'Ideal for frequent travelers',
    features: [
      'Unlimited trips',
      'AI-powered suggestions',
      'Advanced templates',
      'Real-time weather updates',
      'Cloud sync across devices',
      'Family sharing (up to 5)',
      'Custom categories',
      'Export & sharing'
    ],
    popular: true,
    cta: 'Start Free Trial'
  },
  {
    name: 'Family',
    price: '$9.99',
    period: 'per month',
    description: 'Best for families and groups',
    features: [
      'Everything in Pro',
      'Unlimited family members',
      'Group trip planning',
      'Advanced analytics',
      'Priority support',
      'Custom branding',
      'Bulk operations',
      'Team collaboration tools'
    ],
    cta: 'Start Free Trial'
  }
]

const Pricing: React.FC = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.2,
  })

  return (
    <section id="pricing" className="py-32 bg-gradient-to-b from-black to-purple-900/20 relative">
      {/* Background Effects */}
      <div className="absolute inset-0">
        <div className="absolute top-1/3 left-1/4 w-96 h-96 bg-purple-500/5 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-1/3 right-1/4 w-96 h-96 bg-pink-500/5 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '2s' }} />
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
            className="inline-flex items-center space-x-2 bg-green-500/10 border border-green-500/20 rounded-full px-4 py-2 mb-6"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
          >
            <Zap className="w-4 h-4 text-green-400" />
            <span className="text-sm text-green-300">Simple Pricing</span>
          </motion.div>

          <h2 className="text-5xl md:text-6xl font-bold mb-6 text-white">
            Choose your
            <br />
            <span className="bg-gradient-to-r from-green-400 to-blue-400 bg-clip-text text-transparent">
              travel plan
            </span>
          </h2>
          
          <p className="text-xl text-gray-400 max-w-3xl mx-auto mb-8">
            Start free and upgrade when you need more features. All plans include our core packing intelligence.
          </p>

          {/* Billing Toggle */}
          <motion.div
            className="inline-flex items-center bg-white/5 backdrop-blur-sm border border-white/10 rounded-full p-1"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={inView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.4 }}
          >
            <button className="px-4 py-2 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-medium">
              Monthly
            </button>
            <button className="px-4 py-2 rounded-full text-gray-400 text-sm font-medium hover:text-white transition-colors">
              Annual <span className="text-green-400">(Save 20%)</span>
            </button>
          </motion.div>
        </motion.div>

        <div className="grid lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
          {plans.map((plan, index) => (
            <motion.div
              key={index}
              className={`relative rounded-3xl p-8 border transition-all duration-300 hover:scale-105 ${
                plan.popular
                  ? 'bg-gradient-to-br from-purple-900/30 to-pink-900/30 border-purple-400/50 shadow-2xl shadow-purple-500/20'
                  : 'bg-white/5 backdrop-blur-sm border-white/10 hover:border-white/20 hover:bg-white/10'
              }`}
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: index * 0.1 }}
            >
              {/* Popular Badge */}
              {plan.popular && (
                <motion.div
                  className="absolute -top-4 left-1/2 -translate-x-1/2 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-4 py-2 rounded-full text-sm font-medium flex items-center space-x-1"
                  initial={{ opacity: 0, y: -10 }}
                  animate={inView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.5, delay: 0.3 }}
                >
                  <Star className="w-4 h-4" fill="currentColor" />
                  <span>Most Popular</span>
                </motion.div>
              )}

              {/* Background Glow */}
              {plan.popular && (
                <div className="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-pink-500/10 rounded-3xl blur-xl opacity-50" />
              )}

              <div className="relative">
                {/* Plan Header */}
                <div className="text-center mb-8">
                  <h3 className="text-2xl font-bold text-white mb-2">{plan.name}</h3>
                  <p className="text-gray-400 mb-6">{plan.description}</p>
                  
                  <div className="mb-6">
                    <span className={`text-5xl font-bold ${
                      plan.popular 
                        ? 'bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent'
                        : 'text-white'
                    }`}>
                      {plan.price}
                    </span>
                    <span className="text-gray-400 ml-2">/{plan.period}</span>
                  </div>
                </div>

                {/* Features */}
                <div className="mb-8">
                  <ul className="space-y-4">
                    {plan.features.map((feature, featureIndex) => (
                      <motion.li
                        key={featureIndex}
                        className="flex items-center space-x-3"
                        initial={{ opacity: 0, x: -20 }}
                        animate={inView ? { opacity: 1, x: 0 } : {}}
                        transition={{ duration: 0.4, delay: 0.5 + featureIndex * 0.1 }}
                      >
                        <div className={`w-5 h-5 rounded-full flex items-center justify-center ${
                          plan.popular 
                            ? 'bg-gradient-to-r from-purple-500 to-pink-500'
                            : 'bg-green-500'
                        }`}>
                          <Check className="w-3 h-3 text-white" />
                        </div>
                        <span className="text-gray-300">{feature}</span>
                      </motion.li>
                    ))}
                  </ul>
                </div>

                {/* CTA Button */}
                <motion.button
                  className={`w-full py-4 px-6 rounded-2xl font-semibold transition-all duration-300 ${
                    plan.popular
                      ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white hover:from-purple-700 hover:to-pink-700 shadow-lg shadow-purple-500/25'
                      : 'border border-white/20 text-white hover:bg-white/10 hover:border-white/30'
                  }`}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  {plan.cta}
                </motion.button>

                {/* Extra Info */}
                {plan.name === 'Pro' && (
                  <motion.p
                    className="text-center text-sm text-gray-400 mt-4"
                    initial={{ opacity: 0 }}
                    animate={inView ? { opacity: 1 } : {}}
                    transition={{ duration: 0.5, delay: 1 }}
                  >
                    7-day free trial, cancel anytime
                  </motion.p>
                )}
              </div>
            </motion.div>
          ))}
        </div>

        {/* FAQ Link */}
        <motion.div
          className="text-center mt-16"
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.8 }}
        >
          <p className="text-gray-400 mb-4">
            Have questions about our pricing?
          </p>
          <button className="text-purple-400 hover:text-purple-300 transition-colors font-medium">
            Check our FAQ →
          </button>
        </motion.div>

        {/* Money Back Guarantee */}
        <motion.div
          className="text-center mt-12"
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 1 }}
        >
          <div className="inline-flex items-center space-x-2 bg-green-500/10 border border-green-500/20 rounded-full px-4 py-2">
            <div className="w-4 h-4 bg-green-500 rounded-full flex items-center justify-center">
              <Check className="w-2 h-2 text-white" />
            </div>
            <span className="text-sm text-green-300">30-day money-back guarantee</span>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

export default Pricing