import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#a855f7" },
    { media: "(prefers-color-scheme: dark)", color: "#a855f7" },
  ],
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  metadataBase: new URL("https://pacbag.app"),
  title: {
    default: "PacBag - Smart Travel Packing Lists",
    template: "%s | PacBag",
  },
  description:
    "The intelligent packing companion that learns from your travel habits. AI-powered suggestions, smart templates, and seamless sync across all your devices.",
  keywords: [
    "travel packing",
    "packing list",
    "travel app",
    "iOS app",
    "smart packing",
    "travel organizer",
    "vacation planner",
    "business travel",
    "family travel",
    "packing assistant",
  ],
  authors: [{ name: "Enricco Gemha" }],
  creator: "Enricco Gemha",
  publisher: "PacBag",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    title: "PacBag - Smart Travel Packing Lists",
    description:
      "Never forget essential items again. AI-powered packing lists that learn from your travel habits.",
    url: "https://pacbag.app",
    siteName: "PacBag",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "PacBag - Smart Travel Packing Lists",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "PacBag - Smart Travel Packing Lists",
    description:
      "Never forget essential items again. AI-powered packing lists that learn from your travel habits.",
    images: ["/twitter-image.png"],
    creator: "@pacbagapp",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  icons: {
    icon: [
      { url: "/icon-raw.png", sizes: "32x32", type: "image/png" },
      { url: "/icon-raw.png", sizes: "16x16", type: "image/png" },
    ],
    apple: [
      { url: "/icon-raw.png", sizes: "180x180", type: "image/png" },
    ],
    other: [
      {
        rel: "mask-icon",
        url: "/icon-raw.png",
        color: "#a855f7",
      },
    ],
  },
  manifest: "/manifest.json",
  alternates: {
    canonical: "https://pacbag.app",
  },
  category: "travel",
  classification: "Travel & Tourism",
  referrer: "origin-when-cross-origin",
  colorScheme: "dark",
  appLinks: {
    ios: {
      url: "https://apps.apple.com/app/pacbag",
      app_store_id: "YOUR_APP_STORE_ID",
    },
    web: {
      url: "https://pacbag.app",
      should_fallback: true,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "SoftwareApplication",
              name: "PacBag",
              applicationCategory: "TravelApplication",
              operatingSystem: "iOS",
              description:
                "The intelligent packing companion that learns from your travel habits. AI-powered suggestions, smart templates, and seamless sync across all your devices.",
              offers: {
                "@type": "Offer",
                price: "0",
                priceCurrency: "USD",
              },
              aggregateRating: {
                "@type": "AggregateRating",
                ratingValue: "4.9",
                ratingCount: "2500",
              },
              author: {
                "@type": "Person",
                name: "Enricco Gemha",
              },
              datePublished: "2024-01-01",
              softwareVersion: "1.0",
              screenshot: "https://pacbag.app/screenshot.png",
              featureList: [
                "AI-powered packing suggestions",
                "Weather-based recommendations",
                "Cloud sync across devices",
                "Family sharing",
                "Custom packing templates",
                "Smart reminders",
              ],
              url: "https://pacbag.app",
              downloadUrl: "https://apps.apple.com/app/pacbag",
            }),
          }}
        />
      </head>
      <body className="antialiased font-sans bg-black text-white">
        {children}
        <script
          dangerouslySetInnerHTML={{
            __html: `
              // Smooth scroll polyfill
              if (!('scrollBehavior' in document.documentElement.style)) {
                import('https://unpkg.com/smoothscroll-polyfill@0.4.4/dist/smoothscroll.min.js');
              }
            `,
          }}
        />
      </body>
    </html>
  );
}