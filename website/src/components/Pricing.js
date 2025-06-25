import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { Check, Download, Zap, Crown } from 'lucide-react';

const Pricing = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const plans = [
    {
      name: "Free",
      price: "$0",
      period: "Forever",
      description: "Perfect for casual travelers",
      icon: Download,
      features: [
        "Unlimited trips and items",
        "Smart categorization",
        "Weight tracking",
        "CloudKit sync",
        "Basic analytics",
        "Export to text/markdown",
        "Community support"
      ],
      buttonText: "Download Free",
      buttonStyle: "button-secondary",
      popular: false
    },
    {
      name: "Pro",
      price: "$4.99",
      period: "One-time",
      description: "For power travelers who want everything",
      icon: Crown,
      features: [
        "Everything in Free",
        "Advanced analytics & insights",
        "Custom categories & icons",
        "PDF export with photos",
        "Priority customer support",
        "Early access to new features",
        "Backup & restore",
        "Multiple device management"
      ],
      buttonText: "Get Pro Features",
      buttonStyle: "button-primary",
      popular: true
    },
    {
      name: "Family",
      price: "$9.99",
      period: "One-time",
      description: "Share with your whole family",
      icon: Zap,
      features: [
        "Everything in Pro",
        "Up to 6 family members",
        "Shared packing lists",
        "Family trip coordination",
        "Individual profiles",
        "Parental controls",
        "Group notifications",
        "Family analytics dashboard"
      ],
      buttonText: "Get Family Plan",
      buttonStyle: "button-primary",
      popular: false
    }
  ];

  const containerVariants = {
    hidden: {},
    visible: {
      transition: {
        staggerChildren: 0.2
      }
    }
  };

  const cardVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: {
        duration: 0.8
      }
    }
  };

  return (
    <section id="pricing" className="section-padding bg-gradient-to-b from-gray-900/50 to-black">
      <div className="container">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <div className="mb-6">
            <span className="text-blue-400 font-semibold uppercase tracking-wider text-sm">
              Simple Pricing
            </span>
          </div>
          
          <h2 className="text-4xl md:text-6xl font-black mb-6">
            Choose Your
            <span className="text-gradient block">Perfect Plan</span>
          </h2>
          
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Start with our generous free plan, or unlock premium features with a 
            simple one-time purchase. No subscriptions, no hidden fees.
          </p>
        </motion.div>

        <motion.div
          initial="hidden"
          animate={inView ? "visible" : "hidden"}
          variants={containerVariants}
          className="grid grid-cols-1 lg:grid-cols-3 gap-8 max-w-6xl mx-auto"
        >
          {plans.map((plan, index) => (
            <motion.div
              key={index}
              variants={cardVariants}
              whileHover={{ y: -10, scale: 1.02 }}
              className={`relative glass-card p-8 ${
                plan.popular 
                  ? 'border-2 border-blue-500 bg-gradient-to-b from-blue-500/10 to-purple-500/10' 
                  : 'border border-gray-800'
              }`}
            >
              {/* Popular Badge */}
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                  <div className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-6 py-2 rounded-full text-sm font-semibold">
                    Most Popular
                  </div>
                </div>
              )}

              {/* Plan Header */}
              <div className="text-center mb-8">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                  <plan.icon className="w-8 h-8 text-white" />
                </div>
                
                <h3 className="text-2xl font-bold mb-2">{plan.name}</h3>
                <p className="text-gray-400 text-sm mb-4">{plan.description}</p>
                
                <div className="mb-4">
                  <span className="text-4xl font-black text-gradient">{plan.price}</span>
                  <span className="text-gray-400 ml-2">{plan.period}</span>
                </div>
              </div>

              {/* Features */}
              <div className="space-y-4 mb-8">
                {plan.features.map((feature, featureIndex) => (
                  <div key={featureIndex} className="flex items-start gap-3">
                    <Check className="w-5 h-5 text-green-400 mt-0.5 flex-shrink-0" />
                    <span className="text-gray-300 text-sm">{feature}</span>
                  </div>
                ))}
              </div>

              {/* CTA Button */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className={`${plan.buttonStyle} w-full justify-center ${
                  plan.popular ? 'text-lg py-4' : ''
                }`}
              >
                {plan.buttonText}
              </motion.button>

              {/* Money Back Guarantee */}
              {plan.price !== "$0" && (
                <div className="text-center mt-4">
                  <p className="text-xs text-gray-400">
                    30-day money back guarantee
                  </p>
                </div>
              )}
            </motion.div>
          ))}
        </motion.div>

        {/* Value Proposition */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="mt-16 text-center"
        >
          <div className="glass-card p-8 max-w-4xl mx-auto">
            <h3 className="text-2xl font-bold mb-4">Why Choose PacBag?</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-sm text-gray-300">
              <div className="flex flex-col items-center">
                <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center mb-3">
                  <Check className="w-6 h-6 text-white" />
                </div>
                <h4 className="font-semibold mb-2">No Subscriptions</h4>
                <p className="text-center">Pay once, use forever. No monthly fees or recurring charges.</p>
              </div>
              
              <div className="flex flex-col items-center">
                <div className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center mb-3">
                  <Crown className="w-6 h-6 text-white" />
                </div>
                <h4 className="font-semibold mb-2">Premium Experience</h4>
                <p className="text-center">Native iOS app built with latest technologies for best performance.</p>
              </div>
              
              <div className="flex flex-col items-center">
                <div className="w-12 h-12 bg-purple-500 rounded-full flex items-center justify-center mb-3">
                  <Zap className="w-6 h-6 text-white" />
                </div>
                <h4 className="font-semibold mb-2">Constant Updates</h4>
                <p className="text-center">Regular feature updates and improvements at no extra cost.</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default Pricing;