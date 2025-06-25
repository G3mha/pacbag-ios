import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { Play, Pause, RotateCcw } from 'lucide-react';

const ProductDemo = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const [currentDemo, setCurrentDemo] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);

  const demos = [
    {
      title: "Create Trip & Add Items",
      description: "Start by creating a new trip and adding items to your packing list with categories and weights.",
      mockupData: {
        screen: "trip-creation",
        items: [
          { name: "Business Shirts", category: "Clothes", weight: "0.2kg", packed: false },
          { name: "Laptop Charger", category: "Electronics", weight: "0.3kg", packed: false },
          { name: "Toothbrush", category: "Toiletries", weight: "0.1kg", packed: false }
        ]
      }
    },
    {
      title: "Smart Organization",
      description: "Items are automatically organized by categories with intelligent suggestions and weight tracking.",
      mockupData: {
        screen: "organization",
        items: [
          { name: "Business Shirts", category: "Clothes", weight: "0.2kg", packed: true },
          { name: "Laptop Charger", category: "Electronics", weight: "0.3kg", packed: true },
          { name: "Toothbrush", category: "Toiletries", weight: "0.1kg", packed: false }
        ]
      }
    },
    {
      title: "Real-time Analytics",
      description: "Track your packing progress with beautiful charts and get insights into your travel habits.",
      mockupData: {
        screen: "analytics",
        items: [
          { name: "Business Shirts", category: "Clothes", weight: "0.2kg", packed: true },
          { name: "Laptop Charger", category: "Electronics", weight: "0.3kg", packed: true },
          { name: "Toothbrush", category: "Toiletries", weight: "0.1kg", packed: true }
        ]
      }
    }
  ];

  const nextDemo = () => {
    setCurrentDemo((prev) => (prev + 1) % demos.length);
  };

  const prevDemo = () => {
    setCurrentDemo((prev) => (prev - 1 + demos.length) % demos.length);
  };

  React.useEffect(() => {
    let interval;
    if (isPlaying) {
      interval = setInterval(nextDemo, 4000);
    }
    return () => clearInterval(interval);
  }, [isPlaying]);

  return (
    <section id="demo" className="section-padding">
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
              See It In Action
            </span>
          </div>
          
          <h2 className="text-4xl md:text-6xl font-black mb-6">
            Experience
            <span className="text-gradient block">PacBag</span>
          </h2>
          
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Watch how PacBag transforms the way you pack for travel with intelligent 
            features and beautiful design.
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Demo Controls */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="space-y-8"
          >
            <div className="flex items-center gap-4 mb-8">
              <button
                onClick={() => setIsPlaying(!isPlaying)}
                className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center hover:scale-110 transition-transform duration-300"
              >
                {isPlaying ? <Pause className="w-5 h-5" /> : <Play className="w-5 h-5" />}
              </button>
              <span className="text-gray-300">
                {isPlaying ? 'Auto-playing demo' : 'Click to auto-play'}
              </span>
            </div>

            {demos.map((demo, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0.5 }}
                animate={{ opacity: currentDemo === index ? 1 : 0.5 }}
                className={`cursor-pointer p-6 rounded-2xl border transition-all duration-300 ${
                  currentDemo === index 
                    ? 'border-blue-500 bg-blue-500/10' 
                    : 'border-gray-800 hover:border-gray-700'
                }`}
                onClick={() => setCurrentDemo(index)}
              >
                <div className="flex items-start gap-4">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold ${
                    currentDemo === index 
                      ? 'bg-blue-500 text-white' 
                      : 'bg-gray-800 text-gray-400'
                  }`}>
                    {index + 1}
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold mb-2">{demo.title}</h3>
                    <p className="text-gray-300 text-sm">{demo.description}</p>
                  </div>
                </div>
              </motion.div>
            ))}

            <div className="flex gap-4">
              <button onClick={prevDemo} className="button-secondary">
                Previous
              </button>
              <button onClick={nextDemo} className="button-primary">
                Next Step
              </button>
            </div>
          </motion.div>

          {/* Phone Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="relative"
          >
            <div className="floating">
              <div className="glass-card p-8 max-w-md mx-auto">
                <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-3xl p-6 shadow-2xl">
                  {/* Phone Header */}
                  <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg"></div>
                      <span className="font-semibold text-sm">PacBag</span>
                    </div>
                    <div className="text-xs text-gray-400">9:41 AM</div>
                  </div>

                  {/* Dynamic Content */}
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={currentDemo}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -20 }}
                      transition={{ duration: 0.5 }}
                      className="space-y-4"
                    >
                      <div className="text-center mb-6">
                        <h3 className="font-bold text-lg">{demos[currentDemo].title}</h3>
                        <div className="w-full h-1 bg-gray-700 rounded-full mt-2 overflow-hidden">
                          <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${((currentDemo + 1) / demos.length) * 100}%` }}
                            className="h-full bg-gradient-to-r from-blue-500 to-purple-600 rounded-full"
                            transition={{ duration: 0.5 }}
                          />
                        </div>
                      </div>

                      {demos[currentDemo].mockupData.items.map((item, itemIndex) => (
                        <motion.div
                          key={itemIndex}
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: itemIndex * 0.1 }}
                          className={`flex items-center justify-between p-3 rounded-lg transition-all duration-300 ${
                            item.packed ? 'bg-green-500/20 border border-green-500/30' : 'bg-gray-800'
                          }`}
                        >
                          <div className="flex items-center gap-3">
                            <div className={`w-4 h-4 rounded-full border-2 ${
                              item.packed 
                                ? 'bg-green-500 border-green-500' 
                                : 'border-gray-500'
                            }`}>
                              {item.packed && (
                                <motion.div
                                  initial={{ scale: 0 }}
                                  animate={{ scale: 1 }}
                                  className="w-full h-full flex items-center justify-center"
                                >
                                  ✓
                                </motion.div>
                              )}
                            </div>
                            <div>
                              <div className={`text-sm font-medium ${item.packed ? 'line-through text-gray-400' : ''}`}>
                                {item.name}
                              </div>
                              <div className="text-xs text-gray-400">{item.category}</div>
                            </div>
                          </div>
                          <div className="text-xs text-gray-400">{item.weight}</div>
                        </motion.div>
                      ))}

                      <div className="text-center pt-4 border-t border-gray-700">
                        <div className="text-lg font-bold">
                          {demos[currentDemo].mockupData.items.reduce((acc, item) => 
                            acc + parseFloat(item.weight.replace('kg', '')), 0
                          ).toFixed(1)} kg
                        </div>
                        <div className="text-xs text-gray-400">Total Weight</div>
                      </div>
                    </motion.div>
                  </AnimatePresence>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default ProductDemo;