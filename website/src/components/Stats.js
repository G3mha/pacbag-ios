import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';

const Stats = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const stats = [
    {
      number: "10,000+",
      label: "Happy Travelers",
      description: "Trust PacBag for their packing needs"
    },
    {
      number: "50,000+",
      label: "Items Tracked",
      description: "Successfully organized and packed"
    },
    {
      number: "4.9★",
      label: "App Store Rating",
      description: "Loved by users worldwide"
    },
    {
      number: "100%",
      label: "Free to Use",
      description: "No hidden costs or subscriptions"
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

  const itemVariants = {
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
    <section className="section-padding bg-gradient-to-r from-blue-900/20 to-purple-900/20">
      <div className="container">
        <motion.div
          ref={ref}
          initial="hidden"
          animate={inView ? "visible" : "hidden"}
          variants={containerVariants}
          className="text-center mb-16"
        >
          <motion.h2 variants={itemVariants} className="text-4xl md:text-5xl font-black mb-6">
            Trusted by Travelers
            <span className="text-gradient block">Worldwide</span>
          </motion.h2>
          
          <motion.p variants={itemVariants} className="text-xl text-gray-300 max-w-3xl mx-auto">
            Join thousands of smart travelers who have transformed their packing 
            experience with PacBag.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          animate={inView ? "visible" : "hidden"}
          variants={containerVariants}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8"
        >
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{ scale: 1.05 }}
              className="text-center p-8 glass-card group"
            >
              <motion.div
                initial={{ scale: 0 }}
                animate={inView ? { scale: 1 } : {}}
                transition={{ duration: 0.8, delay: index * 0.2 }}
                className="text-4xl md:text-5xl font-black text-gradient mb-4"
              >
                {stat.number}
              </motion.div>
              
              <h3 className="text-xl font-bold mb-2 group-hover:text-blue-400 transition-colors duration-300">
                {stat.label}
              </h3>
              
              <p className="text-gray-300 text-sm">
                {stat.description}
              </p>
            </motion.div>
          ))}
        </motion.div>

        {/* Additional Trust Indicators */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="mt-16 text-center"
        >
          <div className="glass-card p-8 max-w-4xl mx-auto">
            <h3 className="text-2xl font-bold mb-6">Featured & Recognized</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-gray-300">
              <div className="flex flex-col items-center">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mb-4">
                  <span className="text-2xl">🏆</span>
                </div>
                <h4 className="font-semibold mb-2">App Store Featured</h4>
                <p className="text-sm text-center">Selected as App of the Day in Travel category</p>
              </div>
              
              <div className="flex flex-col items-center">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mb-4">
                  <span className="text-2xl">🌟</span>
                </div>
                <h4 className="font-semibold mb-2">Editor's Choice</h4>
                <p className="text-sm text-center">Recommended by travel bloggers and influencers</p>
              </div>
              
              <div className="flex flex-col items-center">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mb-4">
                  <span className="text-2xl">🚀</span>
                </div>
                <h4 className="font-semibold mb-2">Fast Growing</h4>
                <p className="text-sm text-center">Fastest growing travel organization app</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default Stats;