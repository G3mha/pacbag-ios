import React from 'react';
import Link from 'next/link';

export default function LabelsMarkingsPage() {
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
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Labels and Markings</h1>
        
        <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            Digital Services Act Compliance
          </h2>
          <p className="text-gray-600 mb-8">
            This page provides product safety and compliance information for PacBag as required by European Union Digital Services Act (DSA) regulations.
          </p>
          
          {/* App Information */}
          <div className="space-y-6">
            <div className="border-l-4 border-blue-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                App Information
              </h3>
              <div className="space-y-2 text-gray-600">
                <p><strong>App Name:</strong> PacBag - Digital Luggage</p>
                <p><strong>Version:</strong> 1.0</p>
                <p><strong>Developer:</strong> Enricco Gemha</p>
                <p><strong>Category:</strong> Travel & Productivity</p>
                <p><strong>Age Rating:</strong> 4+ (Suitable for all ages)</p>
              </div>
            </div>

            <div className="border-l-4 border-green-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Safety Information
              </h3>
              <div className="space-y-3 text-gray-600">
                <p>✅ <strong>No Safety Concerns:</strong> PacBag is a simple travel packing organization app with no safety risks.</p>
                <p>✅ <strong>No Age Restrictions:</strong> Suitable for users of all ages (4+).</p>
                <p>✅ <strong>No Health Risks:</strong> Does not provide medical advice or health-related functionality.</p>
                <p>✅ <strong>No Financial Risk:</strong> Free app with no in-app purchases or financial transactions.</p>
              </div>
            </div>

            <div className="border-l-4 border-purple-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Data & Privacy
              </h3>
              <div className="space-y-3 text-gray-600">
                <p>🔒 <strong>Privacy First:</strong> All data is stored privately in your iCloud account.</p>
                <p>🚫 <strong>No Data Collection:</strong> We do not collect, store, or access any personal information.</p>
                <p>☁️ <strong>iCloud Only:</strong> Uses Apple&apos;s secure iCloud infrastructure for data sync.</p>
                <p>📱 <strong>Local Storage:</strong> App data remains on your devices and iCloud account only.</p>
                <p>
                  For detailed privacy information, see our{' '}
                  <Link href="/privacy-policy.html" className="text-blue-600 hover:underline">
                    Privacy Policy
                  </Link>.
                </p>
              </div>
            </div>

            <div className="border-l-4 border-orange-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Compliance Status
              </h3>
              <div className="space-y-3 text-gray-600">
                <p>✅ <strong>EU DSA Compliant:</strong> This app complies with Digital Services Act requirements.</p>
                <p>✅ <strong>GDPR Compliant:</strong> No personal data collection ensures GDPR compliance.</p>
                <p>✅ <strong>App Store Guidelines:</strong> Meets all Apple App Store Review Guidelines.</p>
                <p>✅ <strong>Accessibility:</strong> Built with iOS accessibility features and VoiceOver support.</p>
              </div>
            </div>

            <div className="border-l-4 border-red-500 pl-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Important Disclaimers
              </h3>
              <div className="space-y-3 text-gray-600">
                <p><strong>Not a Substitute for Professional Planning:</strong> PacBag is a personal organization tool and should not replace professional travel planning or consultation.</p>
                <p><strong>User Responsibility:</strong> Users are responsible for ensuring they pack appropriate items for their specific travel needs and destinations.</p>
                <p><strong>No Warranty:</strong> The app is provided &quot;as is&quot; without warranty of any kind.</p>
              </div>
            </div>
          </div>
        </div>

        {/* Contact Section */}
        <div className="bg-blue-50 rounded-lg p-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-4">
            Questions or Concerns?
          </h2>
          <p className="text-gray-600 mb-6">
            If you have questions about compliance, safety, or any other aspect of PacBag, please contact us:
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
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <div>
                <h4 className="font-medium text-gray-900">Support</h4>
                <Link href="/support" className="text-blue-600 hover:underline">
                  Visit Support Center
                </Link>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-12 text-center text-gray-500">
          <p>Last Updated: July 2025</p>
          <p>PacBag - Digital Luggage v1.0</p>
          <p>Developed by Enricco Gemha</p>
        </div>
      </main>
    </div>
  );
}