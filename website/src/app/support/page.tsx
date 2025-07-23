import React from 'react';
import Link from 'next/link';

export default function SupportPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
      {/* Navigation */}
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <Link href="/" className="flex items-center">
              <span className="text-2xl font-bold text-blue-600">PacBag</span>
            </Link>
            <Link href="/" className="text-gray-600 hover:text-gray-900">
              Back to Home
            </Link>
          </div>
        </div>
      </nav>

      {/* Support Content */}
      <main className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Support Center</h1>
        
        <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            How can we help you?
          </h2>
          <p className="text-gray-600 mb-8">
            Welcome to PacBag Support. Find answers to common questions or get in touch with us.
          </p>
          
          {/* FAQ Section */}
          <div className="space-y-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">
              Frequently Asked Questions
            </h3>
            
            <div className="space-y-4">
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  How do I sync my data across devices?
                </summary>
                <p className="mt-2 text-gray-600">
                  PacBag automatically syncs through iCloud. Make sure you're signed into the same Apple ID on all devices and have iCloud enabled for PacBag in Settings → [Your Name] → iCloud.
                </p>
              </details>
              
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  Can I create custom packing templates?
                </summary>
                <p className="mt-2 text-gray-600">
                  Yes! Go to the Templates section and tap the + button to create your own custom template. You can save frequently used item combinations for different trip types.
                </p>
              </details>
              
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  How do I track luggage weight?
                </summary>
                <p className="mt-2 text-gray-600">
                  When adding items, enter their weight in the item details. PacBag will automatically calculate the total weight for each bag, helping you stay within airline limits.
                </p>
              </details>
              
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  Can I share my packing lists?
                </summary>
                <p className="mt-2 text-gray-600">
                  Yes! Tap the share button on any trip or bag to export your packing list. You can share it via Messages, Email, or save it as a PDF.
                </p>
              </details>
              
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  How do I set trip reminders?
                </summary>
                <p className="mt-2 text-gray-600">
                  When creating or editing a trip, you can set reminder notifications. PacBag will alert you before your trip so you never forget to pack.
                </p>
              </details>
              
              <details className="border-b pb-4">
                <summary className="font-medium text-gray-900 cursor-pointer">
                  Is my data private?
                </summary>
                <p className="mt-2 text-gray-600">
                  Absolutely! All your data is stored privately in your iCloud account. We don't have access to any of your information. Read our{' '}
                  <Link href="/privacy-policy.html" className="text-blue-600 hover:underline">
                    Privacy Policy
                  </Link>{' '}
                  for details.
                </p>
              </details>
            </div>
          </div>
        </div>

        {/* Contact Section */}
        <div className="bg-blue-50 rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            Still need help?
          </h2>
          <p className="text-gray-600 mb-6">
            We're here to assist you. Choose the best way to reach us:
          </p>
          
          <div className="space-y-4">
            <div className="flex items-start">
              <svg className="w-6 h-6 text-blue-600 mt-1 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Email Support</h4>
                <p className="text-gray-600">Get help via email</p>
                <a href="mailto:me@enriccogemha.dev" className="text-blue-600 hover:underline">
                  me@enriccogemha.dev
                </a>
              </div>
            </div>
            
            <div className="flex items-start">
              <svg className="w-6 h-6 text-blue-600 mt-1 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Response Time</h4>
                <p className="text-gray-600">
                  We typically respond within 24-48 hours during business days.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* App Info */}
        <div className="mt-12 text-center text-gray-500">
          <p>PacBag - Digital Luggage</p>
          <p>Version 1.0</p>
        </div>
      </main>
    </div>
  );
}