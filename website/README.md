# PacBag Marketing Website

A modern, responsive React website for PacBag - Your Digital Travel Companion. Built with React, Framer Motion, and Tailwind-inspired styling.

## 🚀 Features

- **Modern Design**: Dark theme with glassmorphism effects and smooth animations
- **Responsive**: Fully responsive design that works on all devices
- **Performance**: Optimized for fast loading and smooth interactions
- **SEO Ready**: Proper meta tags and semantic HTML structure
- **Interactive**: Engaging animations and micro-interactions using Framer Motion

## 🛠️ Built With

- React 18
- Framer Motion (animations)
- Lucide React (icons)
- React Router DOM
- React Intersection Observer

## 📦 Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd pacbag/website
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

4. Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

## 🏗️ Build for Production

```bash
npm run build
```

This builds the app for production to the `build` folder.

## 📁 Project Structure

```
src/
├── components/
│   ├── Navbar.js          # Navigation with glassmorphism effect
│   ├── Hero.js            # Hero section with animated mockup
│   ├── Features.js        # Feature showcase with icons
│   ├── ProductDemo.js     # Interactive product demonstration
│   ├── Stats.js           # Statistics and social proof
│   ├── Testimonials.js    # Customer testimonials carousel
│   ├── Pricing.js         # Pricing plans comparison
│   ├── FAQ.js             # Frequently asked questions
│   ├── CTA.js             # Call-to-action section
│   └── Footer.js          # Footer with links and newsletter
├── App.js                 # Main app component with routing
├── index.js               # React entry point
└── index.css              # Global styles and utilities
```

## 🎨 Design System

### Colors
- Primary: Blue (#3B82F6) to Purple (#8B5CF6) gradient
- Background: Dark (#0A0A0A)
- Glass cards: Semi-transparent with backdrop blur
- Text: White with gray variations for hierarchy

### Typography
- Font: Inter (Google Fonts)
- Headings: Bold, large sizes with gradient text effects
- Body: Clean, readable with proper contrast

### Components
- Glass morphism cards with subtle borders
- Gradient buttons with hover animations
- Smooth page transitions and scroll animations
- Interactive elements with micro-animations

## 🔧 Customization

### Adding New Sections
1. Create a new component in `src/components/`
2. Import and add it to `App.js`
3. Update navigation links in `Navbar.js` if needed

### Updating Content
- **Hero Section**: Edit `src/components/Hero.js`
- **Features**: Modify the features array in `src/components/Features.js`
- **Testimonials**: Update testimonials array in `src/components/Testimonials.js`
- **FAQ**: Edit the faqs array in `src/components/FAQ.js`
- **Pricing**: Modify plans array in `src/components/Pricing.js`

### Styling
Global styles are in `src/index.css`. The project uses a utility-first approach similar to Tailwind CSS.

## 🚀 Deployment

### Netlify
1. Connect your repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `build`
4. Deploy!

### Vercel
1. Connect your repository to Vercel
2. Vercel will automatically detect it's a React app
3. Deploy!

### Custom Domain
Update the meta tags in `public/index.html` with your domain information.

## 📱 Performance Optimizations

- Lazy loading with React.lazy (can be added for code splitting)
- Optimized images and icons
- Minimal bundle size with tree shaking
- Efficient animations with Framer Motion
- Intersection Observer for scroll-triggered animations

## 🔍 SEO Optimizations

- Semantic HTML structure
- Proper meta tags in `public/index.html`
- Open Graph and Twitter Card meta tags
- Structured data ready (can be added)
- Fast loading times

## 📞 Support

For questions about the website:
- Email: hello@pacbag.app
- Issues: Create an issue in the repository

## 📄 License

This project is proprietary to PacBag. All rights reserved.

---

Built with ❤️ for travelers worldwide.