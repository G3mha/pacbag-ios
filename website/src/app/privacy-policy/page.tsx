import React from 'react';
import Link from 'next/link';

export default function PrivacyPolicyPage() {
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

      {/* Content */}
      <main className="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Privacy Policy</h1>
        
        <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
          <div className="text-sm text-gray-500 mb-6">
            Last Updated: July 2025
          </div>

          {/* Key Points Section */}
          <div className="bg-blue-50 rounded-lg p-6 mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Key Points</h2>
            <div className="grid md:grid-cols-2 gap-4">
              <div className="flex items-start">
                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2 mr-3"></div>
                <p className="text-gray-700"><strong>We don&apos;t collect any personal data</strong></p>
              </div>
              <div className="flex items-start">
                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2 mr-3"></div>
                <p className="text-gray-700"><strong>All data stays in your iCloud account</strong></p>
              </div>
              <div className="flex items-start">
                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2 mr-3"></div>
                <p className="text-gray-700"><strong>We cannot access your information</strong></p>
              </div>
              <div className="flex items-start">
                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2 mr-3"></div>
                <p className="text-gray-700"><strong>You have complete control</strong></p>
              </div>
            </div>
          </div>

          {/* Detailed Policy Sections */}
          <div className="space-y-8">
            {/* Information Collection */}
            <div className="border-l-4 border-green-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">1. Information Collection</h3>
              <p className="text-gray-600 mb-3">
                PacBag does NOT collect, transmit, or store any personal information on external servers:
              </p>
              <ul className="space-y-2 text-gray-600">
                <li>• No user accounts or registration required</li>
                <li>• No analytics or tracking</li>
                <li>• No advertising</li>
                <li>• No data mining</li>
                <li>• No third-party data sharing</li>
              </ul>
            </div>

            {/* Data Storage */}
            <div className="border-l-4 border-blue-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">2. Data Storage</h3>
              
              <h4 className="font-medium text-gray-900 mb-2">iCloud Storage (CloudKit)</h4>
              <ul className="space-y-2 text-gray-600 mb-4">
                <li>• All trips, bags, items, and packing lists are stored in your personal iCloud container</li>
                <li>• Data syncs automatically between your devices signed into the same iCloud account</li>
                <li>• Only you can access your data through your Apple ID</li>
                <li>• We cannot see, access, or retrieve any of your information</li>
              </ul>

              <h4 className="font-medium text-gray-900 mb-2">Local Storage</h4>
              <ul className="space-y-2 text-gray-600">
                <li>• App preferences and settings</li>
                <li>• Temporary cache data</li>
                <li>• Notification schedules</li>
              </ul>
            </div>

            {/* Photos and Media */}
            <div className="border-l-4 border-purple-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">3. Photos and Media</h3>
              <ul className="space-y-2 text-gray-600">
                <li>• Photos are stored in your iCloud Photo Library</li>
                <li>• The app only accesses photos you explicitly select</li>
                <li>• Photo access requires your explicit permission</li>
                <li>• You can revoke photo access anytime in iOS Settings</li>
              </ul>
            </div>

            {/* Notifications */}
            <div className="border-l-4 border-orange-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">4. Notifications</h3>
              <ul className="space-y-2 text-gray-600">
                <li>• All reminders are local notifications</li>
                <li>• No push notification servers are used</li>
                <li>• No notification data is transmitted externally</li>
                <li>• You control all notification settings</li>
              </ul>
            </div>

            {/* Data Security */}
            <div className="border-l-4 border-red-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">5. Data Security</h3>
              <p className="text-gray-600 mb-2">Your data is protected by:</p>
              <ul className="space-y-2 text-gray-600">
                <li>• Apple&apos;s iCloud security infrastructure</li>
                <li>• End-to-end encryption for iCloud data</li>
                <li>• Your device passcode/Face ID/Touch ID</li>
                <li>• iOS app sandboxing</li>
              </ul>
            </div>

            {/* Your Rights */}
            <div className="border-l-4 border-indigo-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">6. Your Rights</h3>
              <p className="text-gray-600 mb-2">You have complete control:</p>
              <ul className="space-y-2 text-gray-600">
                <li>• Delete individual items, bags, or trips at any time</li>
                <li>• Use &quot;Reset App&quot; in settings to delete all data</li>
                <li>• Disable iCloud sync in your device&apos;s iCloud settings</li>
                <li>• Deleting the app removes all local data</li>
              </ul>
            </div>

            {/* Children's Privacy */}
            <div className="border-l-4 border-pink-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">7. Children&apos;s Privacy</h3>
              <p className="text-gray-600">
                PacBag is rated 4+ and suitable for all ages. We do not collect personal information from anyone.
              </p>
            </div>

            {/* Third-Party Services */}
            <div className="border-l-4 border-teal-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">8. Third-Party Services</h3>
              <p className="text-gray-600 mb-2">PacBag only uses Apple&apos;s iOS frameworks:</p>
              <ul className="space-y-2 text-gray-600">
                <li>• CloudKit for data sync</li>
                <li>• PhotosUI for image selection</li>
                <li>• UserNotifications for local reminders</li>
              </ul>
            </div>

            {/* GDPR Compliance */}
            <div className="border-l-4 border-yellow-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-3">9. GDPR Compliance</h3>
              <p className="text-gray-600 mb-2">For EU users:</p>
              <ul className="space-y-2 text-gray-600">
                <li>• No personal data collection</li>
                <li>• Data minimization</li>
                <li>• User control over all data</li>
                <li>• Right to deletion</li>
                <li>• Data portability (via iCloud)</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Contact Section */}
        <div className="bg-blue-50 rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            Contact Us
          </h2>
          <p className="text-gray-600 mb-6">
            If you have any questions about this Privacy Policy or PacBag&apos;s privacy practices, please contact us:
          </p>
          
          <div className="space-y-4">
            <div className="flex items-start">
              <svg className="w-6 h-6 text-blue-600 mt-1 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Email</h4>
                <a href="mailto:me@enriccogemha.dev" className="text-blue-600 hover:underline">
                  me@enriccogemha.dev
                </a>
              </div>
            </div>
            
            <div className="flex items-start">
              <svg className="w-6 h-6 text-blue-600 mt-1 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" />
                <path d="M2 12h20" />
                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Website</h4>
                <a href="https://pacbag.app" className="text-blue-600 hover:underline">
                  https://pacbag.app
                </a>
              </div>
            </div>

            <div className="flex items-start">
              <svg className="w-6 h-6 text-blue-600 mt-1 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Developer</h4>
                <p className="text-gray-600">Enricco Gemha</p>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center text-gray-500">
          <p>PacBag - Digital Luggage v1.0</p>
          <p>Developed by Enricco Gemha</p>
        </div>
      </main>
    </div>
  );
}