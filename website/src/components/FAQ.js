import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { Plus, Minus } from 'lucide-react';

const FAQ = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const [openItems, setOpenItems] = useState(new Set([0])); // First item open by default

  const faqs = [
    {
      question: "Is PacBag really free to use?",
      answer: "Yes! PacBag offers a comprehensive free plan that includes unlimited trips, items, smart categorization, weight tracking, and CloudKit sync. You can upgrade to Pro for advanced features like detailed analytics and custom categories, but the core functionality is completely free forever."
    },
    {
      question: "How does CloudKit sync work?",
      answer: "PacBag uses Apple's CloudKit to automatically sync your data across all your Apple devices. Once you're signed in with your Apple ID, your packing lists, trips, and preferences are seamlessly available on your iPhone, iPad, and other iOS devices. No additional setup required!"
    },
    {
      question: "Can I use PacBag offline?",
      answer: "Absolutely! PacBag works completely offline. You can create trips, add items, check off packed items, and view your analytics without an internet connection. Changes will sync automatically when you're back online."
    },
    {
      question: "What makes PacBag different from other packing apps?",
      answer: "PacBag is built specifically for iOS using the latest Apple technologies, offering a native experience that's fast and intuitive. Our unique features include advanced analytics, smart categorization with subcategories, weight distribution tracking, and seamless CloudKit integration."
    },
    {
      question: "Can I share packing lists with travel companions?",
      answer: "Yes! PacBag allows you to export your packing lists in multiple formats (text, markdown, PDF) that you can easily share via Messages, Mail, or any other app. Pro users get additional sharing options including formatted PDF exports with photos."
    },
    {
      question: "How accurate is the weight tracking feature?",
      answer: "The weight tracking in PacBag is based on the weights you input for each item. You can set precise weights for individual items and quantities, and PacBag will calculate total weights for categories, bags, and entire trips. This helps you stay within airline weight limits."
    },
    {
      question: "Does PacBag work on Android or other platforms?",
      answer: "Currently, PacBag is exclusively designed for iOS devices (iPhone and iPad). We've focused on creating the best possible experience for Apple users by leveraging iOS-specific features like CloudKit, SwiftUI, and Core Data."
    },
    {
      question: "What's included in the Pro version?",
      answer: "Pro includes everything in the free version plus: advanced analytics and insights, custom categories with icons and colors, PDF export with photos, priority support, early access to new features, backup & restore capabilities, and enhanced sharing options."
    },
    {
      question: "Is there a limit to how many trips or items I can create?",
      answer: "No limits! Both free and Pro users can create unlimited trips, bags, and items. The only limitation is the storage capacity of your device and iCloud account."
    },
    {
      question: "How do I get support if I have issues?",
      answer: "Free users get community support through our help center and documentation. Pro users receive priority email support with faster response times. We also have comprehensive in-app help and tutorials to get you started."
    }
  ];

  const toggleItem = (index) => {
    const newOpenItems = new Set(openItems);
    if (newOpenItems.has(index)) {
      newOpenItems.delete(index);
    } else {
      newOpenItems.add(index);
    }
    setOpenItems(newOpenItems);
  };

  return (
    <section id="faq" className="section-padding">
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
              Frequently Asked Questions
            </span>
          </div>
          
          <h2 className="text-4xl md:text-6xl font-black mb-6">
            Got
            <span className="text-gradient block">Questions?</span>
          </h2>
          
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Find answers to common questions about PacBag features, pricing, 
            and how to get the most out of your digital travel companion.
          </p>
        </motion.div>

        <div className="max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="space-y-4"
          >
            {faqs.map((faq, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="glass-card overflow-hidden"
              >
                <motion.button
                  onClick={() => toggleItem(index)}
                  className="w-full p-6 text-left flex items-center justify-between hover:bg-gray-800/50 transition-colors duration-300"
                  whileHover={{ backgroundColor: "rgba(55, 65, 81, 0.1)" }}
                >
                  <h3 className="text-lg font-semibold pr-4">{faq.question}</h3>
                  <motion.div
                    animate={{ rotate: openItems.has(index) ? 45 : 0 }}
                    transition={{ duration: 0.3 }}
                    className="flex-shrink-0"
                  >
                    {openItems.has(index) ? (
                      <Minus className="w-5 h-5 text-blue-400" />
                    ) : (
                      <Plus className="w-5 h-5 text-gray-400" />
                    )}
                  </motion.div>
                </motion.button>
                
                <AnimatePresence>
                  {openItems.has(index) && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.3 }}
                      className="overflow-hidden"
                    >
                      <div className="px-6 pb-6">
                        <div className="border-t border-gray-800 pt-4">
                          <p className="text-gray-300 leading-relaxed">{faq.answer}</p>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            ))}
          </motion.div>

          {/* Still have questions? */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="mt-16 text-center"
          >
            <div className="glass-card p-8">
              <h3 className="text-2xl font-bold mb-4">Still have questions?</h3>
              <p className="text-gray-300 mb-6">
                Can't find the answer you're looking for? We're here to help!
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <motion.a
                  href="mailto:support@pacbag.app"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="button-primary"
                >
                  Contact Support
                </motion.a>
                <motion.a
                  href="#demo"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="button-secondary"
                >
                  Watch Demo
                </motion.a>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default FAQ;