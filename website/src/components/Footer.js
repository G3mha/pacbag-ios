import React from 'react';
import { motion } from 'framer-motion';
import { Luggage, Mail, Twitter, Github, Heart } from 'lucide-react';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  const footerLinks = {
    Product: [
      { name: 'Features', href: '#features' },
      { name: 'Demo', href: '#demo' },
      { name: 'Pricing', href: '#pricing' },
      { name: 'Download', href: '#download' }
    ],
    Support: [
      { name: 'FAQ', href: '#faq' },
      { name: 'Help Center', href: '/help' },
      { name: 'Contact', href: 'mailto:support@pacbag.app' },
      { name: 'Bug Report', href: 'mailto:bugs@pacbag.app' }
    ],
    Company: [
      { name: 'About', href: '/about' },
      { name: 'Blog', href: '/blog' },
      { name: 'Press Kit', href: '/press' },
      { name: 'Privacy', href: '/privacy' }
    ],
    Legal: [
      { name: 'Terms of Service', href: '/terms' },
      { name: 'Privacy Policy', href: '/privacy' },
      { name: 'Cookie Policy', href: '/cookies' },
      { name: 'License', href: '/license' }
    ]
  };

  return (
    <footer className="bg-gradient-to-b from-black to-gray-900 border-t border-gray-800">
      <div className="container">
        {/* Main Footer Content */}
        <div className="py-16">
          <div className="grid grid-cols-1 lg:grid-cols-5 gap-12">
            {/* Brand Section */}
            <div className="lg:col-span-2">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6 }}
                viewport={{ once: true }}
                className="space-y-6"
              >
                {/* Logo */}
                <div className="flex items-center space-x-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                    <Luggage className="w-7 h-7 text-white" />
                  </div>
                  <span className="text-2xl font-bold text-gradient">PacBag</span>
                </div>

                {/* Description */}
                <p className="text-gray-300 leading-relaxed max-w-md">
                  Your digital travel companion that transforms how you pack for trips. 
                  Smart, organized, and beautifully designed for modern travelers.
                </p>

                {/* Social Links */}
                <div className="flex space-x-4">
                  {[
                    { icon: Mail, href: 'mailto:hello@pacbag.app', label: 'Email' },
                    { icon: Twitter, href: 'https://twitter.com/pacbagapp', label: 'Twitter' },
                    { icon: Github, href: 'https://github.com/pacbag', label: 'GitHub' }
                  ].map((social) => (
                    <motion.a
                      key={social.label}
                      href={social.href}
                      whileHover={{ scale: 1.1, y: -2 }}
                      whileTap={{ scale: 0.95 }}
                      className="w-10 h-10 bg-gray-800 rounded-lg flex items-center justify-center hover:bg-gray-700 transition-colors duration-300"
                      aria-label={social.label}
                    >
                      <social.icon className="w-5 h-5 text-gray-300" />
                    </motion.a>
                  ))}
                </div>
              </motion.div>
            </div>

            {/* Links Sections */}
            {Object.entries(footerLinks).map(([title, links], index) => (
              <motion.div
                key={title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                viewport={{ once: true }}
                className="space-y-4"
              >
                <h3 className="font-semibold text-white">{title}</h3>
                <ul className="space-y-3">
                  {links.map((link) => (
                    <li key={link.name}>
                      <motion.a
                        href={link.href}
                        whileHover={{ x: 4 }}
                        className="text-gray-400 hover:text-white transition-colors duration-300 text-sm"
                      >
                        {link.name}
                      </motion.a>
                    </li>
                  ))}
                </ul>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Newsletter Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="py-8 border-t border-gray-800"
        >
          <div className="glass-card p-8 text-center">
            <h3 className="text-2xl font-bold mb-4">Stay Updated</h3>
            <p className="text-gray-300 mb-6 max-w-2xl mx-auto">
              Get notified about new features, travel tips, and updates. 
              No spam, unsubscribe anytime.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto">
              <input
                type="email"
                placeholder="Enter your email"
                className="flex-1 px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500 transition-colors duration-300"
              />
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="button-primary px-6 py-3"
              >
                Subscribe
              </motion.button>
            </div>
          </div>
        </motion.div>

        {/* Bottom Bar */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="py-8 border-t border-gray-800"
        >
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2 text-gray-400 text-sm">
              <span>© {currentYear} PacBag. All rights reserved.</span>
            </div>

            <div className="flex items-center gap-2 text-gray-400 text-sm">
              <span>Made with</span>
              <Heart className="w-4 h-4 text-red-400 fill-current animate-pulse" />
              <span>for travelers worldwide</span>
            </div>

            <div className="flex flex-wrap gap-6 text-gray-400 text-sm">
              <a href="/terms" className="hover:text-white transition-colors duration-300">
                Terms
              </a>
              <a href="/privacy" className="hover:text-white transition-colors duration-300">
                Privacy
              </a>
              <a href="/cookies" className="hover:text-white transition-colors duration-300">
                Cookies
              </a>
            </div>
          </div>
        </motion.div>

        {/* App Store Badge Placeholder */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="pb-8 text-center"
        >
          <div className="inline-flex items-center gap-4 p-4 glass-card rounded-2xl">
            <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
              <Luggage className="w-6 h-6 text-white" />
            </div>
            <div className="text-left">
              <div className="text-sm text-gray-400">Download on the</div>
              <div className="text-lg font-bold">App Store</div>
            </div>
          </div>
        </motion.div>
      </div>
    </footer>
  );
};

export default Footer;