import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useInView } from 'react-intersection-observer';
import { Star, ChevronLeft, ChevronRight, Quote } from 'lucide-react';

const Testimonials = () => {
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });

  const [currentTestimonial, setCurrentTestimonial] = useState(0);

  const testimonials = [
    {
      name: "Sarah Chen",
      role: "Digital Nomad",
      image: "👩‍💻",
      rating: 5,
      text: "PacBag has completely transformed how I pack for my travels. As someone who moves between countries frequently, having everything organized digitally is a game-changer. The weight tracking feature alone has saved me hundreds in excess baggage fees!"
    },
    {
      name: "Marcus Rodriguez",
      role: "Business Traveler",
      image: "👨‍💼",
      rating: 5,
      text: "I travel for work 2-3 times a month, and PacBag helps me stay organized every single trip. The category analytics show me exactly what I use most, and the CloudKit sync means I can pack on my iPad and check off items on my iPhone."
    },
    {
      name: "Emma Thompson",
      role: "Adventure Photographer",
      image: "📸",
      rating: 5,
      text: "Managing gear for photography expeditions used to be chaos. Now with PacBag's subcategories and weight distribution features, I can perfectly organize my camera equipment, batteries, and personal items. It's incredibly intuitive!"
    },
    {
      name: "David Kim",
      role: "Family Travel Blogger",
      image: "👨‍👩‍👧‍👦",
      rating: 5,
      text: "Packing for a family of four was always stressful until we found PacBag. Now each family member has their own categories, and we can track everything from baby supplies to entertainment. The sharing feature is perfect for family trips!"
    },
    {
      name: "Lisa Anderson",
      role: "Solo Traveler",
      image: "🎒",
      rating: 5,
      text: "As a solo female traveler, being organized and prepared is crucial for my safety and peace of mind. PacBag's reminder system ensures I never forget important documents or safety items. It's like having a travel assistant in my pocket!"
    }
  ];

  const nextTestimonial = () => {
    setCurrentTestimonial((prev) => (prev + 1) % testimonials.length);
  };

  const prevTestimonial = () => {
    setCurrentTestimonial((prev) => (prev - 1 + testimonials.length) % testimonials.length);
  };

  return (
    <section className="section-padding">
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
              Testimonials
            </span>
          </div>
          
          <h2 className="text-4xl md:text-6xl font-black mb-6">
            Loved by
            <span className="text-gradient block">Travelers</span>
          </h2>
          
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            See what our users say about their experience with PacBag and how 
            it has transformed their travel preparation.
          </p>
        </motion.div>

        <div className="max-w-4xl mx-auto">
          {/* Main Testimonial */}
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="glass-card p-12 mb-8 relative overflow-hidden"
          >
            {/* Quote decoration */}
            <Quote className="absolute top-6 left-6 w-12 h-12 text-blue-500/20" />
            
            <AnimatePresence mode="wait">
              <motion.div
                key={currentTestimonial}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.5 }}
                className="text-center"
              >
                {/* Stars */}
                <div className="flex justify-center mb-6">
                  {[...Array(testimonials[currentTestimonial].rating)].map((_, i) => (
                    <Star key={i} className="w-6 h-6 text-yellow-400 fill-current" />
                  ))}
                </div>

                {/* Testimonial Text */}
                <blockquote className="text-xl md:text-2xl leading-relaxed mb-8 text-gray-100">
                  "{testimonials[currentTestimonial].text}"
                </blockquote>

                {/* Author */}
                <div className="flex items-center justify-center gap-4">
                  <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-2xl">
                    {testimonials[currentTestimonial].image}
                  </div>
                  <div className="text-left">
                    <div className="font-bold text-lg">{testimonials[currentTestimonial].name}</div>
                    <div className="text-gray-400">{testimonials[currentTestimonial].role}</div>
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>

            {/* Navigation */}
            <div className="flex justify-center items-center gap-4 mt-8">
              <button
                onClick={prevTestimonial}
                className="w-12 h-12 bg-gray-800 hover:bg-gray-700 rounded-full flex items-center justify-center transition-colors duration-300"
              >
                <ChevronLeft className="w-5 h-5" />
              </button>

              {/* Dots */}
              <div className="flex gap-2">
                {testimonials.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setCurrentTestimonial(index)}
                    className={`w-3 h-3 rounded-full transition-colors duration-300 ${
                      index === currentTestimonial ? 'bg-blue-500' : 'bg-gray-600'
                    }`}
                  />
                ))}
              </div>

              <button
                onClick={nextTestimonial}
                className="w-12 h-12 bg-gray-800 hover:bg-gray-700 rounded-full flex items-center justify-center transition-colors duration-300"
              >
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          </motion.div>

          {/* Testimonial Grid */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6"
          >
            {testimonials.slice(0, 3).map((testimonial, index) => (
              <motion.div
                key={index}
                whileHover={{ y: -5 }}
                className={`glass-card p-6 cursor-pointer transition-all duration-300 ${
                  index === currentTestimonial ? 'border-blue-500' : 'hover:border-gray-600'
                }`}
                onClick={() => setCurrentTestimonial(index)}
              >
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-sm">
                    {testimonial.image}
                  </div>
                  <div>
                    <div className="font-semibold text-sm">{testimonial.name}</div>
                    <div className="text-gray-400 text-xs">{testimonial.role}</div>
                  </div>
                </div>
                
                <div className="flex mb-3">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-4 h-4 text-yellow-400 fill-current" />
                  ))}
                </div>
                
                <p className="text-gray-300 text-sm line-clamp-3">
                  {testimonial.text}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;