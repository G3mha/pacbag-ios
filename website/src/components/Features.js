import React from 'react';
import { motion } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { 
  Luggage, 
  Folder, 
  Scale, 
  Cloud, 
  Smartphone, 
  BarChart3,
  Calendar,
  Bell,
  Share2
} from 'lucide-react';

const Features = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const features = [
    {
      icon: Luggage,
      title: "Smart Packing Lists",
      description: "Create intelligent packing lists with our digital twin technology. Track every item with precision and never forget essentials."
    },
    {
      icon: Folder,
      title: "Advanced Categories",
      description: "Organize items with smart categorization and subcategories. Get usage analytics and insights for better packing decisions."
    },
    {
      icon: Scale,
      title: "Weight Tracking",
      description: "Monitor luggage weight in real-time. Stay within airline limits and distribute weight efficiently across multiple bags."
    },
    {
      icon: Cloud,
      title: "CloudKit Sync",
      description: "Seamlessly sync your data across all Apple devices. Access your packing lists anywhere, anytime, automatically."
    },
    {
      icon: Calendar,
      title: "Trip Planning",
      description: "Plan multiple trips with ease. Organize bags per trip, duplicate successful packing lists, and prepare efficiently."
    },
    {
      icon: BarChart3,
      title: "Packing Analytics",
      description: "Get insights into your packing habits. See trends, optimize your lists, and become a more efficient traveler."
    },
    {
      icon: Bell,
      title: "Smart Reminders",
      description: "Never miss packing deadlines with intelligent notifications. Get reminded about essential items and departure times."
    },
    {
      icon: Share2,
      title: "Easy Sharing",
      description: "Share packing lists with travel companions. Export in multiple formats and collaborate on group travels."
    },
    {
      icon: Smartphone,
      title: "Native iOS App",
      description: "Built with SwiftUI for the best possible iOS experience. Fast, beautiful, and designed specifically for Apple devices."
    }
  ];

  const containerVariants = {
    hidden: {},
    visible: {
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: {
        duration: 0.6
      }
    }
  };

  return (
    <section id="features" className="section-padding bg-gradient-to-b from-gray-900/50 to-black">
      <div className="container">
        <motion.div
          ref={ref}
          initial="hidden"
          animate={inView ? "visible" : "hidden"}
          variants={containerVariants}
          className="text-center mb-16"
        >
          <motion.div variants={itemVariants} className="mb-6">
            <span className="text-blue-400 font-semibold uppercase tracking-wider text-sm">
              Powerful Features
            </span>
          </motion.div>
          
          <motion.h2 variants={itemVariants} className="text-4xl md:text-6xl font-black mb-6">
            Everything You Need for
            <span className="text-gradient block">Perfect Packing</span>
          </motion.h2>
          
          <motion.p variants={itemVariants} className="text-xl text-gray-300 max-w-3xl mx-auto">
            PacBag combines intelligent organization with beautiful design to create 
            the ultimate travel companion for modern travelers.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          animate={inView ? "visible" : "hidden"}
          variants={containerVariants}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{ y: -10, scale: 1.02 }}
              className="glass-card p-8 group hover:border-blue-500/50 transition-all duration-300"
            >
              <div className="mb-6">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                  <feature.icon className="w-8 h-8 text-white" />
                </div>
              </div>
              
              <h3 className="text-xl font-bold mb-4 group-hover:text-blue-400 transition-colors duration-300">
                {feature.title}
              </h3>
              
              <p className="text-gray-300 leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </motion.div>

        {/* Feature Highlight */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.5 }}
          className="mt-20 glass-card p-12 text-center"
        >
          <div className="max-w-4xl mx-auto">
            <h3 className="text-3xl md:text-4xl font-bold mb-6">
              Built for <span className="text-gradient">Apple Ecosystem</span>
            </h3>
            <p className="text-xl text-gray-300 mb-8">
              PacBag is designed from the ground up for iOS, leveraging the latest Apple technologies 
              including SwiftUI, Core Data, and CloudKit for the best possible user experience.
            </p>
            <div className="flex flex-wrap justify-center gap-6 text-sm text-gray-400">
              <span>✓ iOS 17+ Support</span>
              <span>✓ iPhone & iPad Compatible</span>
              <span>✓ CloudKit Integration</span>
              <span>✓ Native Performance</span>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default Features;